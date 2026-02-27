import Foundation
import Testing
@testable import ARCAuthCore

@Suite("AppleAuthPayload Tests")
struct AppleAuthPayloadTests {
    // MARK: - Factory

    private func makeSUT(
        identityToken: String = "token123",
        authorizationCode: String = "code123",
        fullName: FullName? = nil,
        email: String? = nil,
        userIdentifier: String = "user.001",
        realUserStatus: RealUserStatus = .likelyReal
    ) -> AppleAuthPayload {
        AppleAuthPayload(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            fullName: fullName,
            email: email,
            userIdentifier: userIdentifier,
            realUserStatus: realUserStatus
        )
    }

    // MARK: - Initialization

    @Test("Should initialize with all parameters", .tags(.unit))
    func initWithAllParameters() {
        // Given
        let fullName = FullName(givenName: "John", familyName: "Doe")

        // When
        let sut = makeSUT(
            fullName: fullName,
            email: "john@example.com"
        )

        // Then
        #expect(sut.identityToken == "token123")
        #expect(sut.authorizationCode == "code123")
        #expect(sut.fullName != nil)
        #expect(sut.email == "john@example.com")
        #expect(sut.userIdentifier == "user.001")
        #expect(sut.realUserStatus == .likelyReal)
    }

    @Test("Should initialize with minimal parameters", .tags(.unit))
    func initWithMinimalParameters() {
        // Given / When
        let sut = makeSUT()

        // Then
        #expect(sut.fullName == nil)
        #expect(sut.email == nil)
    }

    // MARK: - Codable

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let fullName = FullName(givenName: "Jane", familyName: "Smith", nickname: "JS")
        let sut = makeSUT(fullName: fullName, email: "jane@example.com")

        // When
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(AppleAuthPayload.self, from: data)

        // Then
        #expect(decoded.identityToken == sut.identityToken)
        #expect(decoded.authorizationCode == sut.authorizationCode)
        #expect(decoded.email == sut.email)
        #expect(decoded.userIdentifier == sut.userIdentifier)
        #expect(decoded.realUserStatus == sut.realUserStatus)
        #expect(decoded.fullName?.givenName == sut.fullName?.givenName)
        #expect(decoded.fullName?.familyName == sut.fullName?.familyName)
        #expect(decoded.fullName?.nickname == sut.fullName?.nickname)
    }
}

// MARK: - FullName Tests

@Suite("FullName Tests")
struct FullNameTests {
    @Test("Should format with both names", .tags(.unit))
    func formattedBothNames() {
        // Given
        let sut = FullName(givenName: "John", familyName: "Doe")

        // When / Then
        #expect(sut.formatted == "John Doe")
    }

    @Test("Should format with only given name", .tags(.unit))
    func formattedGivenNameOnly() {
        // Given
        let sut = FullName(givenName: "John", familyName: nil)

        // When / Then
        #expect(sut.formatted == "John")
    }

    @Test("Should format with only family name", .tags(.unit))
    func formattedFamilyNameOnly() {
        // Given
        let sut = FullName(givenName: nil, familyName: "Doe")

        // When / Then
        #expect(sut.formatted == "Doe")
    }

    @Test("Should return nil when both names are nil", .tags(.unit))
    func formattedNoNames() {
        // Given
        let sut = FullName(givenName: nil, familyName: nil)

        // When / Then
        #expect(sut.formatted == nil)
    }

    @Test("Should return nil when both names are empty", .tags(.unit))
    func formattedEmptyStrings() {
        // Given
        let sut = FullName(givenName: "", familyName: "")

        // When / Then
        #expect(sut.formatted == nil)
    }

    @Test("Should store nickname", .tags(.unit))
    func nicknameStored() {
        // Given / When
        let sut = FullName(givenName: "John", familyName: "Doe", nickname: "JD")

        // Then
        #expect(sut.nickname == "JD")
    }

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let sut = FullName(givenName: "John", familyName: "Doe", nickname: "JD")

        // When
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(FullName.self, from: data)

        // Then
        #expect(decoded.givenName == sut.givenName)
        #expect(decoded.familyName == sut.familyName)
        #expect(decoded.nickname == sut.nickname)
    }
}

// MARK: - RealUserStatus Tests

@Suite("RealUserStatus Tests")
struct RealUserStatusTests {
    @Test("Should have correct raw values", .tags(.unit))
    func rawValues() {
        // Given / When / Then
        #expect(RealUserStatus.unsupported.rawValue == 0)
        #expect(RealUserStatus.unknown.rawValue == 1)
        #expect(RealUserStatus.likelyReal.rawValue == 2)
    }

    @Test("Should initialize from raw value", .tags(.unit))
    func initFromRaw() {
        // Given / When / Then
        #expect(RealUserStatus(rawValue: 0) == .unsupported)
        #expect(RealUserStatus(rawValue: 1) == .unknown)
        #expect(RealUserStatus(rawValue: 2) == .likelyReal)
        #expect(RealUserStatus(rawValue: 99) == nil)
    }

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let sut = RealUserStatus.likelyReal

        // When
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(RealUserStatus.self, from: data)

        // Then
        #expect(decoded == sut)
    }
}

// MARK: - String.nilIfEmpty Tests

@Suite("String.nilIfEmpty Tests")
struct StringNilIfEmptyTests {
    @Test("Should return nil for empty string", .tags(.unit))
    func emptyReturnsNil() {
        // Given
        let sut = ""

        // When / Then
        #expect(sut.nilIfEmpty == nil)
    }

    @Test("Should return self for non-empty string", .tags(.unit))
    func nonEmptyReturnsSelf() {
        // Given
        let sut = "hello"

        // When / Then
        #expect(sut.nilIfEmpty == "hello")
    }
}
