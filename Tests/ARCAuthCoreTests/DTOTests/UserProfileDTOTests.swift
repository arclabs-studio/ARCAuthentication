import Foundation
import Testing
@testable import ARCAuthCore

@Suite("UserProfileDTO Tests")
struct UserProfileDTOTests {
    // MARK: - Factory

    private func makeSUT(
        id: UUID = UUID(),
        email: String? = "test@example.com",
        displayName: String? = "Test User",
        firstName: String? = nil,
        lastName: String? = nil,
        profileImageURL: URL? = nil,
        provider: AuthProvider = .apple,
        isEmailVerified: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> UserProfileDTO {
        UserProfileDTO(
            id: id,
            email: email,
            displayName: displayName,
            firstName: firstName,
            lastName: lastName,
            profileImageURL: profileImageURL,
            provider: provider,
            isEmailVerified: isEmailVerified,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Initialization

    @Test("Should initialize with all parameters", .tags(.unit))
    func initWithAllParameters() {
        // Given
        let id = UUID()

        // When
        let sut = makeSUT(
            id: id,
            firstName: "John",
            lastName: "Doe",
            profileImageURL: URL(string: "https://example.com/img.jpg"),
            isEmailVerified: true
        )

        // Then
        #expect(sut.id == id)
        #expect(sut.email == "test@example.com")
        #expect(sut.displayName == "Test User")
        #expect(sut.firstName == "John")
        #expect(sut.lastName == "Doe")
        #expect(sut.profileImageURL != nil)
        #expect(sut.isEmailVerified == true)
    }

    // MARK: - Full Name

    @Test("Should return full name with both first and last name", .tags(.unit))
    func fullNameBothNames() {
        // Given
        let sut = makeSUT(firstName: "John", lastName: "Doe")

        // When / Then
        #expect(sut.fullName == "John Doe")
    }

    @Test("Should return full name with only first name", .tags(.unit))
    func fullNameFirstOnly() {
        // Given
        let sut = makeSUT(firstName: "John", lastName: nil)

        // When / Then
        #expect(sut.fullName == "John")
    }

    @Test("Should return full name with only last name", .tags(.unit))
    func fullNameLastOnly() {
        // Given
        let sut = makeSUT(firstName: nil, lastName: "Doe")

        // When / Then
        #expect(sut.fullName == "Doe")
    }

    @Test("Should return nil full name when no names provided", .tags(.unit))
    func fullNameNil() {
        // Given
        let sut = makeSUT(firstName: nil, lastName: nil)

        // When / Then
        #expect(sut.fullName == nil)
    }

    @Test("Should return nil full name when names are empty", .tags(.unit))
    func fullNameEmptyStrings() {
        // Given
        let sut = makeSUT(firstName: "", lastName: "")

        // When / Then
        #expect(sut.fullName == nil)
    }

    // MARK: - Identifiable

    @Test("Should conform to Identifiable", .tags(.unit))
    func identifiable() {
        // Given
        let id = UUID()

        // When
        let sut = makeSUT(id: id)

        // Then
        #expect(sut.id == id)
    }

    // MARK: - Equatable

    @Test("Should be equal when properties match", .tags(.unit))
    func equatable() {
        // Given
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_000_000)

        let profile1 = makeSUT(id: id, createdAt: date, updatedAt: date)
        let profile2 = makeSUT(id: id, createdAt: date, updatedAt: date)

        // When / Then
        #expect(profile1 == profile2)
    }

    @Test("Should not be equal when IDs differ", .tags(.unit))
    func notEqualDifferentID() {
        // Given
        let date = Date(timeIntervalSince1970: 1_000_000)

        let profile1 = makeSUT(id: UUID(), createdAt: date, updatedAt: date)
        let profile2 = makeSUT(id: UUID(), createdAt: date, updatedAt: date)

        // When / Then
        #expect(profile1 != profile2)
    }

    // MARK: - Codable

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let id = UUID()

        let sut = makeSUT(
            id: id,
            firstName: "John",
            lastName: "Doe",
            profileImageURL: URL(string: "https://example.com/img.jpg"),
            isEmailVerified: true,
            createdAt: fixedDate,
            updatedAt: fixedDate
        )

        // When
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(sut)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(UserProfileDTO.self, from: data)

        // Then
        #expect(decoded == sut)
    }
}
