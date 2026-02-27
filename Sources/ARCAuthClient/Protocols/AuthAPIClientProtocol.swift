import ARCAuthCore
import Foundation

/// Protocol for communication with the authentication backend.
public protocol AuthAPIClientProtocol: Sendable {
    /// Sends Apple credentials to the server for verification.
    /// - Parameter payload: Apple authentication payload.
    /// - Returns: Response with server tokens.
    func verifyAppleCredential(_ payload: AppleAuthPayload) async throws -> TokenResponse

    /// Renews the access token using the refresh token.
    /// - Parameter request: Request with the refresh token.
    /// - Returns: New token response.
    func refreshToken(_ request: RefreshTokenRequest) async throws -> TokenResponse

    /// Signs out the session on the server.
    /// - Parameter accessToken: Current access token.
    func signOut(accessToken: String) async throws
}
