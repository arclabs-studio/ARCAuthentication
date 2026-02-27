import Foundation

/// Represents the credentials of an authenticated user.
///
/// This structure is the result of any successful authentication,
/// regardless of the provider used (Apple, Google, Email, etc.).
///
/// ## Usage
/// ```swift
/// let credential = AuthCredential(
///     userID: "001234.abc...",
///     email: "user@example.com",
///     displayName: "John Doe",
///     provider: .apple,
///     identityToken: tokenData,
///     authorizationCode: codeData
/// )
/// ```
///
/// ## Important
/// - `email` and `displayName` are only provided on the **first** Sign in with Apple
/// - Store these values immediately as Apple does not send them again
/// - `identityToken` is a JWT that must be sent to the backend for verification
public struct AuthCredential: Sendable, Codable, Equatable, Hashable, Identifiable {
    // MARK: - Properties

    /// Unique identifier for Identifiable conformance.
    public var id: String {
        userID
    }

    /// Unique user identifier provided by the provider.
    /// For SIWA: opaque string of ~44 characters that persists across sessions.
    public let userID: String

    /// User email (may be an Apple relay: xxx@privaterelay.appleid.com).
    /// Only available on the first Sign in with Apple.
    public let email: String?

    /// User display name.
    /// Only available on the first Sign in with Apple.
    public let displayName: String?

    /// Profile image URL (if available).
    public let profileImageURL: URL?

    /// Authentication provider used.
    public let provider: AuthProvider

    /// JWT containing verifiable user information.
    /// Must be sent to the backend for validation.
    public let identityToken: Data?

    /// Authorization code for server-to-server exchange with Apple.
    /// Only valid for 5 minutes.
    public let authorizationCode: Data?

    /// Server access tokens (populated after backend verification).
    public var serverTokens: ServerTokens?

    /// Credential creation date.
    public let createdAt: Date

    // MARK: - Initialization

    public init(
        userID: String,
        email: String? = nil,
        displayName: String? = nil,
        profileImageURL: URL? = nil,
        provider: AuthProvider,
        identityToken: Data? = nil,
        authorizationCode: Data? = nil,
        serverTokens: ServerTokens? = nil,
        createdAt: Date = Date()
    ) {
        self.userID = userID
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.provider = provider
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.serverTokens = serverTokens
        self.createdAt = createdAt
    }
}

// MARK: - Supporting Types

/// Supported authentication providers.
public enum AuthProvider: String, Sendable, Codable, CaseIterable {
    case apple
    case google
    case email

    public var displayName: String {
        switch self {
        case .apple: "Apple"
        case .google: "Google"
        case .email: "Email"
        }
    }
}

/// Tokens provided by the server backend.
public struct ServerTokens: Sendable, Codable, Equatable, Hashable {
    /// Short-lived access JWT (15-60 min).
    public let accessToken: String

    /// Long-lived refresh token (30 days).
    public let refreshToken: String

    /// Access token expiration date.
    public let expiresAt: Date

    public init(accessToken: String, refreshToken: String, expiresAt: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    /// Whether the access token has expired.
    public var isExpired: Bool {
        Date() >= expiresAt
    }

    /// Whether the token will expire soon (within 5 minutes).
    public var willExpireSoon: Bool {
        Date().addingTimeInterval(300) >= expiresAt
    }
}
