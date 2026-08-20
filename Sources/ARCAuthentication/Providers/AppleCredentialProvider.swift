#if canImport(AuthenticationServices)
import AuthenticationServices

// MARK: - Error Mapping (available on all Apple platforms)

/// Maps ASAuthorizationError codes to ``AuthenticationError``.
///
/// Extracted as a standalone enum for testability on all platforms
/// including macOS where UIKit is not available.
public enum AppleAuthErrorMapper {
    /// Maps an ASAuthorizationError to an AuthenticationError.
    /// - Parameter error: The error from ASAuthorizationController.
    /// - Returns: The corresponding ``AuthenticationError``.
    public static func mapError(_ error: Error) -> AuthenticationError {
        guard let authorizationError = error as? ASAuthorizationError else {
            return .systemError(error.localizedDescription)
        }

        switch authorizationError.code {
        case .canceled:
            return .userCancelled
        case .invalidResponse:
            return .invalidIdentityToken
        default:
            return .systemError(error.localizedDescription)
        }
    }
}
#endif

#if canImport(AuthenticationServices) && canImport(UIKit)
import UIKit

/// Credential provider for Sign in with Apple.
///
/// Implements the complete Sign in with Apple flow using
/// `ASAuthorizationController` and returns an ``AppleCredential``
/// wrapped in ``AuthCredential/apple(_:)``.
///
/// ## Usage
/// ```swift
/// let provider = AppleCredentialProvider()
/// let credential = try await provider.requestCredential()
/// ```
///
/// ## Important Notes
/// - `email` and `fullName` are only provided on the **first** sign-in.
/// - The `identityToken` is a JWT that must be verified on the server.
/// - The `authorizationCode` expires in 5 minutes.
@MainActor
public final class AppleCredentialProvider: NSObject, CredentialProviding, @unchecked Sendable {
    // MARK: - Properties

    public let providerType: AuthProviderType = .apple

    private let scopes: [ASAuthorization.Scope]
    private var authContinuation: CheckedContinuation<AuthCredential, Error>?
    private var currentNonce: String?
    /// Identificador del último usuario que completó el flujo de sign-in.
    /// Protegido por @MainActor. Se usa en `checkCredentialState()`.
    private var lastUserIdentifier: String?

    // MARK: - Initialization

    /// Creates an Apple credential provider.
    /// - Parameter scopes: The authorization scopes to request (default: fullName, email).
    public init(scopes: [ASAuthorization.Scope] = [.fullName, .email]) {
        self.scopes = scopes
        super.init()
    }

    // MARK: - CredentialProviding

    public func requestCredential() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            self.performAppleSignIn()
        }
    }

    // MARK: - Private Methods

    private func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = scopes

        let nonce = CryptoUtils.randomNonceString()
        currentNonce = nonce
        request.nonce = CryptoUtils.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleCredentialProvider: ASAuthorizationControllerDelegate {
    public nonisolated func authorizationController(controller _: ASAuthorizationController,
                                                    didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                authContinuation?.resume(throwing: AuthenticationError.unexpectedCredentialType)
                authContinuation = nil
                return
            }

            guard let identityTokenData = appleCredential.identityToken else {
                authContinuation?.resume(throwing: AuthenticationError.invalidIdentityToken)
                authContinuation = nil
                return
            }

            guard let authorizationCodeData = appleCredential.authorizationCode else {
                authContinuation?.resume(throwing: AuthenticationError.missingAuthorizationCode)
                authContinuation = nil
                return
            }

            guard let nonce = currentNonce else {
                authContinuation?.resume(throwing: AuthenticationError.nonceMismatch)
                authContinuation = nil
                return
            }

            let credential = AppleCredential(identityToken: identityTokenData,
                                             authorizationCode: authorizationCodeData,
                                             nonce: nonce,
                                             fullName: appleCredential.fullName,
                                             email: appleCredential.email,
                                             userIdentifier: appleCredential.user)

            lastUserIdentifier = appleCredential.user
            authContinuation?.resume(returning: .apple(credential))
            authContinuation = nil
            currentNonce = nil
        }
    }

    public nonisolated func authorizationController(controller _: ASAuthorizationController,
                                                    didCompleteWithError error: Error) {
        Task { @MainActor in
            authContinuation?.resume(throwing: AppleAuthErrorMapper.mapError(error))
            authContinuation = nil
            currentNonce = nil
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleCredentialProvider: ASAuthorizationControllerPresentationContextProviding {
    public nonisolated func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            // arcKeyWindow traverses foreground-active scenes first via UIWindowScene.keyWindow,
            // then falls back to any available window.
            // The UIWindow() fallback is unreachable in a running foreground iOS 17+ app; it
            // satisfies the non-optional return type required by ASAuthorizationControllerPresentationContextProviding.
            UIApplication.shared.arcKeyWindow ?? UIWindow()
        }
    }
}

// MARK: - SessionManaging

extension AppleCredentialProvider: SessionManaging {
    /// Limpia el estado de sesión en memoria del provider.
    ///
    /// Sign in with Apple no ofrece una llamada de cierre de sesión en el SDK del cliente.
    /// Para revocar el acceso completamente, el backend debe llamar a la API de revocación de Apple.
    /// Este método limpia el `userIdentifier` en memoria para que `checkCredentialState()`
    /// devuelva `.notFound` hasta el próximo sign-in exitoso.
    public func signOut() {
        lastUserIdentifier = nil
    }

    /// Comprueba el estado de la credencial del último usuario que inició sesión.
    ///
    /// Si no hay ningún `userIdentifier` en memoria (primera ejecución o tras `signOut()`),
    /// devuelve `.notFound` sin consultar a Apple. Si hay un identificador disponible, consulta
    /// `ASAuthorizationAppleIDProvider` para verificar el estado actual.
    ///
    /// - Returns: ``CredentialState/authorized``, ``CredentialState/notFound``,
    ///   o ``CredentialState/revoked``.
    public func checkCredentialState() async -> CredentialState {
        guard let userID = lastUserIdentifier else {
            return .notFound
        }

        return await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                switch state {
                case .authorized:
                    continuation.resume(returning: .authorized)
                case .revoked:
                    continuation.resume(returning: .revoked)
                case .notFound, .transferred:
                    continuation.resume(returning: .notFound)
                @unknown default:
                    continuation.resume(returning: .notFound)
                }
            }
        }
    }
}
#endif
