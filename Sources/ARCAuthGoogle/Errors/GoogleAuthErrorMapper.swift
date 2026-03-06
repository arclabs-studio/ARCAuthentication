#if canImport(UIKit)
import ARCAuthentication
import GoogleSignIn

/// Maps GIDSignInError codes to ``AuthenticationError``.
///
/// Extracted as a standalone type for testability and parallel structure
/// with ``AppleAuthErrorMapper`` in the core module.
public enum GoogleAuthErrorMapper {
    /// Maps a GIDSignIn error to an ``AuthenticationError``.
    /// - Parameter error: The error thrown by `GIDSignIn`.
    /// - Returns: The corresponding ``AuthenticationError``.
    public static func mapError(_ error: Error) -> AuthenticationError {
        let nsError = error as NSError

        guard nsError.domain == GIDSignInError.errorDomain else {
            return .systemError(error.localizedDescription)
        }

        guard let code = GIDSignInError.Code(rawValue: nsError.code) else {
            return .unknown(error.localizedDescription)
        }

        switch code {
        case .canceled:
            return .userCancelled
        case .hasNoAuthInKeychain:
            return .providerNotAvailable(.google)
        case .scopesAlreadyGranted:
            return .systemError("Requested scopes were already granted")
        case .EMM:
            return .systemError("Enterprise Mobility Management error")
        @unknown default:
            return .unknown(error.localizedDescription)
        }
    }
}
#endif
