#if canImport(AuthenticationServices) && canImport(UIKit)
import ARCAuthCore
import AuthenticationServices
import CommonCrypto
import UIKit

/// Provider de autenticación para Sign in with Apple.
///
/// Implementa el flujo completo de autenticación con Apple ID usando
/// el framework `AuthenticationServices`.
///
/// ## Uso
/// ```swift
/// let provider = AppleAuthProvider()
/// let credential = try await provider.authenticate()
/// ```
///
/// ## Notas Importantes
/// - `email` y `fullName` solo se proporcionan en el **primer** Sign in
/// - El `identityToken` es un JWT que debe verificarse en el servidor
/// - El `authorizationCode` expira en 5 minutos
@MainActor
public final class AppleAuthProvider: NSObject, AuthenticationProvider {
    // MARK: - Properties

    public let providerID: String = AuthProvider.apple.rawValue
    public let displayName: String = "Apple"

    private var authContinuation: CheckedContinuation<AuthCredential, Error>?
    private var currentNonce: String?

    // MARK: - Initialization

    override public init() {
        super.init()
    }

    // MARK: - AuthenticationProvider

    public var isAvailable: Bool {
        true
    }

    public func authenticate() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.authContinuation = continuation
            self.performAppleSignIn()
        }
    }

    public func signOut() async throws {
        // Apple no requiere sign out explícito
        // El sign out se maneja eliminando las credenciales almacenadas
    }

    public func checkCredentialState() async -> CredentialState {
        // Necesitamos un userID guardado para verificar
        // Esto normalmente se obtendría del storage
        .notFound
    }

    /// Verifica el estado de credenciales para un userID específico.
    /// - Parameter userID: El identificador de usuario de Apple.
    /// - Returns: Estado actual de las credenciales.
    public func checkCredentialState(for userID: String) async -> CredentialState {
        await withCheckedContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                let credentialState: CredentialState = switch state {
                case .authorized:
                    .authorized
                case .revoked:
                    .revoked
                case .notFound:
                    .notFound
                case .transferred:
                    .transferred
                @unknown default:
                    .notFound
                }
                continuation.resume(returning: credentialState)
            }
        }
    }

    // MARK: - Private Methods

    private func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // Generar nonce para seguridad adicional (recomendado para backend)
        let nonce = Self.generateNonce()
        currentNonce = nonce
        request.nonce = nonce.sha256Hash

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func handleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        let fullName = credential.fullName.map { name in
            FullName(
                givenName: name.givenName,
                familyName: name.familyName,
                nickname: name.nickname
            )
        }

        let authCredential = AuthCredential(
            userID: credential.user,
            email: credential.email,
            displayName: fullName?.formatted,
            provider: .apple,
            identityToken: credential.identityToken,
            authorizationCode: credential.authorizationCode
        )

        authContinuation?.resume(returning: authCredential)
        authContinuation = nil
    }

    private func handleError(_ error: Error) {
        let authError: AuthenticationError = if let authorizationError = error as? ASAuthorizationError {
            switch authorizationError.code {
            case .canceled:
                .userCancelled
            case .invalidResponse:
                .invalidCredentials
            case .notHandled, .failed:
                .appleSignInFailed(underlying: error)
            case .notInteractive:
                .appleSignInFailed(underlying: error)
            case .matchedExcludedCredential:
                .appleSignInFailed(underlying: error)
            @unknown default:
                .unknown(underlying: error)
            }
        } else {
            .unknown(underlying: error)
        }

        authContinuation?.resume(throwing: authError)
        authContinuation = nil
    }

    // MARK: - Nonce Generation

    private static func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthProvider: ASAuthorizationControllerDelegate {
    public nonisolated func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        Task { @MainActor in
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                handleCredential(credential)
            } else {
                handleError(AuthenticationError.invalidCredentials)
            }
        }
    }

    public nonisolated func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            handleError(error)
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthProvider: ASAuthorizationControllerPresentationContextProviding {
    public nonisolated func presentationAnchor(
        for _: ASAuthorizationController
    ) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            fatalError("No active window found for presenting Sign in with Apple")
        }
        return window
    }
}

// MARK: - String Extension for SHA256

extension String {
    fileprivate var sha256Hash: String {
        guard let data = data(using: .utf8) else { return self }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
#endif
