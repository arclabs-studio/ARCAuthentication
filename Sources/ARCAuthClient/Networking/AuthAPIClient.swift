import ARCAuthCore
import Foundation

/// API client for backend authentication.
///
/// This implementation is a placeholder that will be completed
/// when the Vapor backend is developed.
public final class AuthAPIClient: AuthAPIClientProtocol, Sendable {
    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder = .init()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private let timeoutInterval: TimeInterval

    // MARK: - Initialization

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.session = session
        self.timeoutInterval = timeoutInterval
    }

    // MARK: - AuthAPIClientProtocol

    public func verifyAppleCredential(_ payload: AppleAuthPayload) async throws -> TokenResponse {
        let url = baseURL.appending(path: "auth/apple/verify")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeoutInterval
        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.networkError(underlying: nil)
        }

        guard httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8)
            throw AuthenticationError.serverError(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }

        return try decoder.decode(TokenResponse.self, from: data)
    }

    public func refreshToken(_ request: RefreshTokenRequest) async throws -> TokenResponse {
        let url = baseURL.appending(path: "auth/refresh")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = timeoutInterval
        urlRequest.httpBody = try encoder.encode(request)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.networkError(underlying: nil)
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw AuthenticationError.tokenExpired
            }
            let message = String(data: data, encoding: .utf8)
            throw AuthenticationError.serverError(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }

        return try decoder.decode(TokenResponse.self, from: data)
    }

    public func signOut(accessToken: String) async throws {
        let url = baseURL.appending(path: "auth/signout")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeoutInterval

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.networkError(underlying: nil)
        }

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw AuthenticationError.serverError(
                statusCode: httpResponse.statusCode,
                message: nil
            )
        }
    }
}
