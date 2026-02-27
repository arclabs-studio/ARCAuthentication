import Foundation
import Testing
@testable import ARCAuthCore

@Suite("TokenResponse Tests")
struct TokenResponseTests {
    // MARK: - Factory

    private func makeSUT(
        accessToken: String = "access_token",
        refreshToken: String = "refresh_token",
        expiresIn: Int = 3600,
        tokenType: String = "Bearer",
        user: UserDTO? = nil
    ) -> TokenResponse {
        let userDTO = user ?? UserDTO(
            id: UUID(),
            email: nil,
            displayName: nil,
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )
        return TokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            tokenType: tokenType,
            user: userDTO
        )
    }

    // MARK: - Initialization

    @Test("Should initialize with all parameters", .tags(.unit))
    func initWithAllParameters() {
        // Given
        let user = UserDTO(
            id: UUID(),
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )

        // When
        let sut = makeSUT(user: user)

        // Then
        #expect(sut.accessToken == "access_token")
        #expect(sut.refreshToken == "refresh_token")
        #expect(sut.expiresIn == 3600)
        #expect(sut.tokenType == "Bearer")
        #expect(sut.user.email == "test@example.com")
    }

    @Test("Should default tokenType to Bearer", .tags(.unit))
    func defaultTokenType() {
        // Given / When
        let sut = makeSUT()

        // Then
        #expect(sut.tokenType == "Bearer")
    }

    @Test("Should calculate expiresAt correctly", .tags(.unit))
    func expiresAtCalculation() {
        // Given
        let sut = makeSUT(expiresIn: 3600)

        // When
        let now = Date()
        let expectedApprox = now.addingTimeInterval(3600)

        // Then - Allow 5 seconds tolerance for test execution time
        let tolerance: TimeInterval = 5
        #expect(abs(sut.expiresAt.timeIntervalSince(expectedApprox)) < tolerance)
    }

    // MARK: - Codable

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let user = UserDTO(
            id: UUID(),
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            createdAt: Date(),
            updatedAt: Date()
        )
        let sut = makeSUT(user: user)

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(sut)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TokenResponse.self, from: data)

        // Then
        #expect(decoded.accessToken == sut.accessToken)
        #expect(decoded.refreshToken == sut.refreshToken)
        #expect(decoded.expiresIn == sut.expiresIn)
        #expect(decoded.tokenType == sut.tokenType)
    }
}

@Suite("UserDTO Tests")
struct UserDTOTests {
    // MARK: - Factory

    private func makeSUT(
        id: UUID = UUID(),
        email: String? = "test@example.com",
        displayName: String? = "Test User",
        profileImageURL: URL? = nil,
        provider: AuthProvider = .apple,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> UserDTO {
        UserDTO(
            id: id,
            email: email,
            displayName: displayName,
            profileImageURL: profileImageURL,
            provider: provider,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Identifiable

    @Test("Should conform to Identifiable", .tags(.unit))
    func identifiableConformance() {
        // Given
        let id = UUID()

        // When
        let sut = makeSUT(id: id)

        // Then
        #expect(sut.id == id)
    }

    // MARK: - Equatable

    @Test("Should be equal when properties match", .tags(.unit))
    func equatableConformance() {
        // Given
        let id = UUID()
        let date = Date()

        let user1 = makeSUT(id: id, createdAt: date, updatedAt: date)
        let user2 = makeSUT(id: id, createdAt: date, updatedAt: date)

        // When / Then
        #expect(user1 == user2)
    }

    // MARK: - Codable

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        guard let fixedID = UUID(uuidString: "12345678-1234-1234-1234-123456789012") else {
            Issue.record("Invalid UUID string")
            return
        }

        let sut = makeSUT(
            id: fixedID,
            profileImageURL: URL(string: "https://example.com/image.jpg"),
            provider: .google,
            createdAt: fixedDate,
            updatedAt: fixedDate
        )

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(sut)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserDTO.self, from: data)

        // Then
        #expect(decoded == sut)
    }
}
