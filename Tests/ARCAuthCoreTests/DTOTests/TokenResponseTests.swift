import Foundation
import Testing

@testable import ARCAuthCore

@Suite("TokenResponse Tests")
struct TokenResponseTests {
    @Test("Init with all parameters")
    func initWithAllParameters() {
        let user = UserDTO(
            id: UUID(),
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )

        let response = TokenResponse(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expiresIn: 3600,
            tokenType: "Bearer",
            user: user
        )

        #expect(response.accessToken == "access_token")
        #expect(response.refreshToken == "refresh_token")
        #expect(response.expiresIn == 3600)
        #expect(response.tokenType == "Bearer")
        #expect(response.user.email == "test@example.com")
    }

    @Test("Default tokenType is Bearer")
    func defaultTokenType() {
        let user = UserDTO(
            id: UUID(),
            email: nil,
            displayName: nil,
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )

        let response = TokenResponse(
            accessToken: "access",
            refreshToken: "refresh",
            expiresIn: 3600,
            user: user
        )

        #expect(response.tokenType == "Bearer")
    }

    @Test("expiresAt calculated correctly")
    func expiresAtCalculation() {
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)
        let user = UserDTO(
            id: UUID(),
            email: nil,
            displayName: nil,
            provider: .apple,
            createdAt: fixedDate,
            updatedAt: fixedDate
        )

        let response = TokenResponse(
            accessToken: "access",
            refreshToken: "refresh",
            expiresIn: 3600,
            user: user
        )

        // expiresAt is a computed property that uses Date() internally
        // We verify it returns a date approximately expiresIn seconds in the future
        let now = Date()
        let expectedApprox = now.addingTimeInterval(3600)

        // Allow 5 seconds tolerance for test execution time
        let tolerance: TimeInterval = 5
        #expect(abs(response.expiresAt.timeIntervalSince(expectedApprox)) < tolerance)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let user = UserDTO(
            id: UUID(),
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )

        let original = TokenResponse(
            accessToken: "access_token",
            refreshToken: "refresh_token",
            expiresIn: 3600,
            user: user
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TokenResponse.self, from: data)

        #expect(decoded.accessToken == original.accessToken)
        #expect(decoded.refreshToken == original.refreshToken)
        #expect(decoded.expiresIn == original.expiresIn)
        #expect(decoded.tokenType == original.tokenType)
    }
}

@Suite("UserDTO Tests")
struct UserDTOTests {
    @Test("Identifiable conformance")
    func identifiableConformance() {
        let id = UUID()
        let user = UserDTO(
            id: id,
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )

        #expect(user.id == id)
    }

    @Test("Equatable conformance")
    func equatableConformance() {
        let id = UUID()
        let date = Date()

        let user1 = UserDTO(
            id: id,
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: date,
            updatedAt: date
        )

        let user2 = UserDTO(
            id: id,
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: date,
            updatedAt: date
        )

        #expect(user1 == user2)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        // Use fixed dates with whole seconds to avoid ISO8601 precision loss
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        guard let fixedID = UUID(uuidString: "12345678-1234-1234-1234-123456789012") else {
            Issue.record("Invalid UUID string")
            return
        }

        let original = UserDTO(
            id: fixedID,
            email: "test@example.com",
            displayName: "Test User",
            profileImageURL: URL(string: "https://example.com/image.jpg"),
            provider: .google,
            createdAt: fixedDate,
            updatedAt: fixedDate
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserDTO.self, from: data)

        #expect(decoded == original)
    }
}
