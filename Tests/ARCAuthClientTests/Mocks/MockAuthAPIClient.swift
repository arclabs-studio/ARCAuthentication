import ARCAuthClient
import ARCAuthCore
import Foundation

@MainActor
final class MockAuthAPIClient: AuthAPIClientProtocol {
    var verifyAppleResult: Result<TokenResponse, Error>?
    var refreshTokenResult: Result<TokenResponse, Error>?
    var signOutError: Error?

    var verifyAppleCallCount = 0
    var refreshTokenCallCount = 0
    var signOutCallCount = 0

    func verifyAppleCredential(_: AppleAuthPayload) async throws -> TokenResponse {
        verifyAppleCallCount += 1
        guard let result = verifyAppleResult else {
            throw AuthenticationError.networkError(underlying: nil)
        }
        return try result.get()
    }

    func refreshToken(_: RefreshTokenRequest) async throws -> TokenResponse {
        refreshTokenCallCount += 1
        guard let result = refreshTokenResult else {
            throw AuthenticationError.tokenRefreshFailed(underlying: nil)
        }
        return try result.get()
    }

    func signOut(accessToken _: String) async throws {
        signOutCallCount += 1
        if let error = signOutError {
            throw error
        }
    }
}
