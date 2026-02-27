import Foundation
import Testing
@testable import ARCAuthClient
@testable import ARCAuthCore

@Suite("AuthAPIClient Tests", .serialized)
struct AuthAPIClientTests {
    // MARK: - Factory

    // swiftlint:disable:next force_unwrapping
    private static let baseURL = URL(string: "https://api.example.com")!

    private func makeSUT() -> AuthAPIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return AuthAPIClient(baseURL: Self.baseURL, session: session)
    }

    private func makeTokenResponseJSON() throws -> (data: Data, response: TokenResponse) {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let uuid = try #require(UUID(uuidString: "12345678-1234-1234-1234-123456789012"))
        let userDTO = UserDTO(
            id: uuid,
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: fixedDate,
            updatedAt: fixedDate
        )
        let tokenResponse = TokenResponse(
            accessToken: "access_token_123",
            refreshToken: "refresh_token_456",
            expiresIn: 3600,
            tokenType: "Bearer",
            user: userDTO
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(tokenResponse)
        return (data, tokenResponse)
    }

    private func makeHTTPResponse(
        path: String,
        statusCode: Int
    ) throws -> HTTPURLResponse {
        try #require(HTTPURLResponse(
            url: Self.baseURL.appending(path: path),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        ))
    }

    // MARK: - verifyAppleCredential

    @Test("Should decode successful response for verifyAppleCredential", .tags(.unit))
    func verifyAppleCredentialSuccess() async throws {
        // Given
        let sut = makeSUT()
        let (responseData, _) = try makeTokenResponseJSON()

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.path.contains("auth/apple/verify") == true)
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            let response = try makeHTTPResponse(path: "auth/apple/verify", statusCode: 200)
            return (response, responseData)
        }

        let payload = AppleAuthPayload(
            identityToken: "token",
            authorizationCode: "code",
            userIdentifier: "user.001",
            realUserStatus: .likelyReal
        )

        // When
        let result = try await sut.verifyAppleCredential(payload)

        // Then
        #expect(result.accessToken == "access_token_123")
        #expect(result.refreshToken == "refresh_token_456")
        #expect(result.expiresIn == 3600)
    }

    @Test("Should throw serverError on non-200 status for verifyAppleCredential", .tags(.unit))
    func verifyAppleCredentialServerError() async throws {
        // Given
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            let response = try makeHTTPResponse(path: "auth/apple/verify", statusCode: 500)
            let body = Data("Internal Server Error".utf8)
            return (response, body)
        }

        let payload = AppleAuthPayload(
            identityToken: "token",
            authorizationCode: "code",
            userIdentifier: "user.001",
            realUserStatus: .likelyReal
        )

        // When / Then
        await #expect(throws: AuthenticationError.self) {
            try await sut.verifyAppleCredential(payload)
        }
    }

    // MARK: - refreshToken

    @Test("Should decode successful response for refreshToken", .tags(.unit))
    func refreshTokenSuccess() async throws {
        // Given
        let sut = makeSUT()
        let (responseData, _) = try makeTokenResponseJSON()

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.path.contains("auth/refresh") == true)
            #expect(request.httpMethod == "POST")
            let response = try makeHTTPResponse(path: "auth/refresh", statusCode: 200)
            return (response, responseData)
        }

        let request = RefreshTokenRequest(refreshToken: "old_refresh_token")

        // When
        let result = try await sut.refreshToken(request)

        // Then
        #expect(result.accessToken == "access_token_123")
    }

    @Test("Should throw tokenExpired on 401 for refreshToken", .tags(.unit))
    func refreshTokenExpired() async throws {
        // Given
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            let response = try makeHTTPResponse(path: "auth/refresh", statusCode: 401)
            return (response, nil)
        }

        let request = RefreshTokenRequest(refreshToken: "expired_token")

        // When / Then
        await #expect {
            try await sut.refreshToken(request)
        } throws: { error in
            (error as? AuthenticationError) == .tokenExpired
        }
    }

    @Test("Should throw serverError on non-200/non-401 for refreshToken", .tags(.unit))
    func refreshTokenServerError() async throws {
        // Given
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            let response = try makeHTTPResponse(path: "auth/refresh", statusCode: 503)
            let body = Data("Service Unavailable".utf8)
            return (response, body)
        }

        let request = RefreshTokenRequest(refreshToken: "some_token")

        // When / Then
        await #expect(throws: AuthenticationError.self) {
            try await sut.refreshToken(request)
        }
    }

    // MARK: - signOut

    @Test("Should succeed on 200 for signOut", .tags(.unit))
    func signOutSuccess200() async throws {
        // Given
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.path.contains("auth/signout") == true)
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test_access_token")
            let response = try makeHTTPResponse(path: "auth/signout", statusCode: 200)
            return (response, nil)
        }

        // When / Then — should not throw
        try await sut.signOut(accessToken: "test_access_token")
    }

    @Test("Should succeed on 204 for signOut", .tags(.unit))
    func signOutSuccess204() async throws {
        // Given
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            let response = try makeHTTPResponse(path: "auth/signout", statusCode: 204)
            return (response, nil)
        }

        // When / Then — should not throw
        try await sut.signOut(accessToken: "test_access_token")
    }

    @Test("Should throw serverError on failure for signOut", .tags(.unit))
    func signOutServerError() async throws {
        // Given
        let sut = makeSUT()

        MockURLProtocol.requestHandler = { _ in
            let response = try makeHTTPResponse(path: "auth/signout", statusCode: 500)
            return (response, nil)
        }

        // When / Then
        await #expect(throws: AuthenticationError.self) {
            try await sut.signOut(accessToken: "test_access_token")
        }
    }
}
