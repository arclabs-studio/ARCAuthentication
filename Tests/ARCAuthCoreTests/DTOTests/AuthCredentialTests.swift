import Foundation
import Testing
@testable import ARCAuthCore

extension Tag {
    @Tag static var unit: Self
}

@Suite("AuthCredential Tests")
struct AuthCredentialTests {
    // MARK: - Factory

    private func makeSUT(
        userID: String = "user123",
        email: String? = nil,
        displayName: String? = nil,
        profileImageURL: URL? = nil,
        provider: AuthProvider = .apple,
        identityToken: Data? = nil,
        authorizationCode: Data? = nil,
        serverTokens: ServerTokens? = nil,
        createdAt: Date = Date()
    ) -> AuthCredential {
        AuthCredential(
            userID: userID,
            email: email,
            displayName: displayName,
            profileImageURL: profileImageURL,
            provider: provider,
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            serverTokens: serverTokens,
            createdAt: createdAt
        )
    }

    // MARK: - Initialization

    @Test("Should initialize with all parameters", .tags(.unit))
    func initWithAllParameters() {
        // Given / When
        let sut = makeSUT(
            email: "test@example.com",
            displayName: "Test User",
            profileImageURL: URL(string: "https://example.com/image.jpg"),
            identityToken: Data("token".utf8),
            authorizationCode: Data("code".utf8)
        )

        // Then
        #expect(sut.userID == "user123")
        #expect(sut.email == "test@example.com")
        #expect(sut.displayName == "Test User")
        #expect(sut.provider == .apple)
        #expect(sut.identityToken != nil)
        #expect(sut.authorizationCode != nil)
    }

    @Test("Should initialize with minimal parameters", .tags(.unit))
    func initWithMinimalParameters() {
        // Given / When
        let sut = makeSUT()

        // Then
        #expect(sut.userID == "user123")
        #expect(sut.email == nil)
        #expect(sut.displayName == nil)
        #expect(sut.provider == .apple)
    }

    // MARK: - Codable

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let sut = makeSUT(
            email: "test@example.com",
            displayName: "Test User",
            identityToken: Data("token".utf8)
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(sut)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AuthCredential.self, from: data)

        // Then
        #expect(decoded == sut)
    }

    // MARK: - Equatable

    @Test("Should be equal when properties match", .tags(.unit))
    func equatable() {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)

        let credential1 = makeSUT(createdAt: fixedDate)
        let credential2 = makeSUT(createdAt: fixedDate)
        let credential3 = makeSUT(userID: "user456", createdAt: fixedDate)

        // When / Then
        #expect(credential1 == credential2)
        #expect(credential1 != credential3)
    }

    // MARK: - Hashable

    @Test("Should deduplicate in Set when equal", .tags(.unit))
    func hashable() {
        // Given
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)

        let credential1 = makeSUT(createdAt: fixedDate)
        let credential2 = makeSUT(createdAt: fixedDate)

        // When
        var set = Set<AuthCredential>()
        set.insert(credential1)
        set.insert(credential2)

        // Then
        #expect(set.count == 1)
    }
}

@Suite("AuthProvider Tests")
struct AuthProviderTests {
    @Test("Should return correct display names", .tags(.unit))
    func displayNames() {
        // Given / When / Then
        #expect(AuthProvider.apple.displayName == "Apple")
        #expect(AuthProvider.google.displayName == "Google")
        #expect(AuthProvider.email.displayName == "Email")
    }

    @Test("Should have correct raw values", .tags(.unit))
    func rawValues() {
        // Given / When / Then
        #expect(AuthProvider.apple.rawValue == "apple")
        #expect(AuthProvider.google.rawValue == "google")
        #expect(AuthProvider.email.rawValue == "email")
    }

    @Test("Should contain all expected cases", .tags(.unit))
    func allCases() {
        // Given / When / Then
        #expect(AuthProvider.allCases.count == 3)
        #expect(AuthProvider.allCases.contains(.apple))
        #expect(AuthProvider.allCases.contains(.google))
        #expect(AuthProvider.allCases.contains(.email))
    }
}

@Suite("ServerTokens Tests")
struct ServerTokensTests {
    // MARK: - Factory

    private func makeSUT(
        accessToken: String = "access",
        refreshToken: String = "refresh",
        expiresAt: Date = Date().addingTimeInterval(3600)
    ) -> ServerTokens {
        ServerTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: expiresAt
        )
    }

    // MARK: - Expiration

    @Test("Should return expired when date is in the past", .tags(.unit))
    func isExpiredTrue() {
        // Given
        let sut = makeSUT(expiresAt: Date().addingTimeInterval(-60))

        // When / Then
        #expect(sut.isExpired == true)
    }

    @Test("Should return not expired when date is in the future", .tags(.unit))
    func isExpiredFalse() {
        // Given
        let sut = makeSUT(expiresAt: Date().addingTimeInterval(3600))

        // When / Then
        #expect(sut.isExpired == false)
    }

    @Test("Should return expiring soon within 5 minutes", .tags(.unit))
    func willExpireSoonTrue() {
        // Given
        let sut = makeSUT(expiresAt: Date().addingTimeInterval(120))

        // When / Then
        #expect(sut.willExpireSoon == true)
    }

    @Test("Should return not expiring soon beyond 5 minutes", .tags(.unit))
    func willExpireSoonFalse() {
        // Given
        let sut = makeSUT(expiresAt: Date().addingTimeInterval(600))

        // When / Then
        #expect(sut.willExpireSoon == false)
    }
}
