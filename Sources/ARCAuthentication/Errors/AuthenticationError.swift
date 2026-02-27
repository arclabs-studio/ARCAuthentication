import Foundation

/// Errors that can occur during credential acquisition.
///
/// These errors cover only the credential-provider layer. Backend-specific
/// errors (network, token refresh, storage) are the responsibility of the
/// consuming application.
public enum AuthenticationError: LocalizedError, Sendable, Equatable {
    /// The user cancelled the authentication flow.
    case userCancelled

    /// The requested provider is not available on this device.
    case providerNotAvailable(AuthProviderType)

    /// The identity token returned by the provider is invalid.
    case invalidIdentityToken

    /// The provider did not return an authorization code.
    case missingAuthorizationCode

    /// The authorization returned an unexpected credential type.
    case unexpectedCredentialType

    /// The nonce in the response does not match the request.
    case nonceMismatch

    /// The provider configuration is invalid.
    case invalidConfiguration(String)

    /// An underlying system error occurred.
    case systemError(String)

    /// An unknown error occurred.
    case unknown(String)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .userCancelled:
            "Authentication was cancelled by the user"
        case let .providerNotAvailable(provider):
            "Authentication provider '\(provider.rawValue)' is not available on this device"
        case .invalidIdentityToken:
            "The identity token is invalid or corrupted"
        case .missingAuthorizationCode:
            "The provider did not return an authorization code"
        case .unexpectedCredentialType:
            "Received an unexpected credential type"
        case .nonceMismatch:
            "Security nonce mismatch — the response may have been tampered with"
        case let .invalidConfiguration(message):
            "Invalid provider configuration: \(message)"
        case let .systemError(message):
            "System error: \(message)"
        case let .unknown(message):
            "Unknown error: \(message)"
        }
    }
}
