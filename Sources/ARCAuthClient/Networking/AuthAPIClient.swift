import ARCAuthCore
import Foundation

/// Cliente de API para autenticación con backend.
///
/// Esta implementación es un placeholder que será completado
/// cuando se desarrolle el backend Vapor.
@MainActor
public final class AuthAPIClient: AuthAPIClientProtocol {
    // MARK: - Properties

    private let baseURL: URL
    private let session: URLSession

    // MARK: - Initialization

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // MARK: - AuthAPIClientProtocol

    public func verifyAppleCredential(_ payload: AppleAuthPayload) async throws -> TokenResponse {
        let url = baseURL.appendingPathComponent("auth/apple/verify")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
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

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TokenResponse.self, from: data)
    }

    public func refreshToken(_ request: RefreshTokenRequest) async throws -> TokenResponse {
        let url = baseURL.appendingPathComponent("auth/refresh")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
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

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TokenResponse.self, from: data)
    }

    public func signOut(accessToken: String) async throws {
        let url = baseURL.appendingPathComponent("auth/signout")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

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
