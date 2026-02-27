import Foundation

/// Request to renew the access token using the refresh token.
public struct RefreshTokenRequest: Sendable, Codable {
    /// Valid refresh token.
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
