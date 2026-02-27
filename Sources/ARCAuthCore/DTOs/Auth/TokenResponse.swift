import Foundation

/// Server response after successful authentication.
///
/// Contains the session tokens and user information.
public struct TokenResponse: Sendable, Codable {
    /// Access JWT for authenticating requests.
    public let accessToken: String

    /// Token for renewing the access token.
    public let refreshToken: String

    /// Seconds until the access token expires.
    public let expiresIn: Int

    /// Token type (always "Bearer").
    public let tokenType: String

    /// Authenticated user information.
    public let user: UserDTO

    public init(
        accessToken: String,
        refreshToken: String,
        expiresIn: Int,
        tokenType: String = "Bearer",
        user: UserDTO
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
        self.user = user
    }

    /// Calculates the expiration date based on `expiresIn`.
    public var expiresAt: Date {
        Date().addingTimeInterval(TimeInterval(expiresIn))
    }
}
