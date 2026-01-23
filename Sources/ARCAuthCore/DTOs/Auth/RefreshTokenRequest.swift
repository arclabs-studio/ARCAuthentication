import Foundation

/// Request para renovar el access token usando el refresh token.
public struct RefreshTokenRequest: Sendable, Codable {
    /// Refresh token válido.
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}
