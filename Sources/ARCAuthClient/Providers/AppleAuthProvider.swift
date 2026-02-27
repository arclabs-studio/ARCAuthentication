#if canImport(AuthenticationServices) && canImport(UIKit)
import ARCAuthCore
import AuthenticationServices
import CryptoKit
import UIKit

/// Authentication provider for Sign in with Apple.
///
/// Implements the complete authentication flow with Apple ID using
/// the `AuthenticationServices` framework.
///
/// ## Usage
/// ```swift
/// let provider = AppleAuthProvider()
/// let credential = try await provider.authenticate()
/// ```
///
/// ## Important Notes
/// - `email` and `fullName` are only provided on the **first** Sign in
/// - The `identityToken` is a JWT that must be verified on the server
/// - The `authorizationCode` expires in 5 minutes
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
        // Apple does not require explicit sign out
        // Sign out is handled by deleting stored credentials
    }

    public func checkCredentialState() async -> CredentialState {
        // We need a saved userID to verify
        // This would normally be obtained from storage
        .notFound
    }

    /// Checks credential state for a specific userID.
    /// - Parameter userID: The Apple user identifier.
    /// - Returns: Current credential state.
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

        // Generate nonce for additional security (recommended for backend)
        do {
            let nonce = try Self.generateNonce()
            currentNonce = nonce
            request.nonce = Self.sha256Hash(of: nonce)
        } catch {
            authContinuation?.resume(throwing: AuthenticationError.unknown(underlying: error))
            authContinuation = nil
            return
        }

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

    private static func generateNonce(length: Int = 32) throws -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        guard errorCode == errSecSuccess else {
            throw AuthenticationError.unknown(
                underlying: NSError(
                    domain: NSOSStatusErrorDomain,
                    code: Int(errorCode),
                    userInfo: [NSLocalizedDescriptionKey: "SecRandomCopyBytes failed with OSStatus \(errorCode)"]
                )
            )
        }

        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    // MARK: - SHA256

    private static func sha256Hash(of input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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
            return UIWindow()
        }
        return window
    }
}
#endif
