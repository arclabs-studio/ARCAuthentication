import Foundation
import Testing

@testable import ARCAuthCore

@Suite("AuthCredential Tests")
struct AuthCredentialTests {
    @Test("Init with all parameters")
    func initWithAllParameters() {
        let credential = AuthCredential(
            userID: "user123",
            email: "test@example.com",
            displayName: "Test User",
            profileImageURL: URL(string: "https://example.com/image.jpg"),
            provider: .apple,
            identityToken: Data("token".utf8),
            authorizationCode: Data("code".utf8),
            serverTokens: nil,
            createdAt: Date()
        )

        #expect(credential.userID == "user123")
        #expect(credential.email == "test@example.com")
        #expect(credential.displayName == "Test User")
        #expect(credential.provider == .apple)
        #expect(credential.identityToken != nil)
        #expect(credential.authorizationCode != nil)
    }

    @Test("Init with minimal parameters")
    func initWithMinimalParameters() {
        let credential = AuthCredential(
            userID: "user123",
            provider: .apple
        )

        #expect(credential.userID == "user123")
        #expect(credential.email == nil)
        #expect(credential.displayName == nil)
        #expect(credential.provider == .apple)
    }

    @Test("Codable round-trip")
    func codableRoundTrip() throws {
        let original = AuthCredential(
            userID: "user123",
            email: "test@example.com",
            displayName: "Test User",
            provider: .apple,
            identityToken: Data("token".utf8)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AuthCredential.self, from: data)

        #expect(decoded == original)
    }

    @Test("Equatable")
    func equatable() {
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)

        let credential1 = AuthCredential(
            userID: "user123",
            provider: .apple,
            createdAt: fixedDate
        )

        let credential2 = AuthCredential(
            userID: "user123",
            provider: .apple,
            createdAt: fixedDate
        )

        let credential3 = AuthCredential(
            userID: "user456",
            provider: .apple,
            createdAt: fixedDate
        )

        #expect(credential1 == credential2)
        #expect(credential1 != credential3)
    }

    @Test("Hashable")
    func hashable() {
        let fixedDate = Date(timeIntervalSince1970: 1_000_000)

        let credential1 = AuthCredential(
            userID: "user123",
            provider: .apple,
            createdAt: fixedDate
        )

        let credential2 = AuthCredential(
            userID: "user123",
            provider: .apple,
            createdAt: fixedDate
        )

        var set = Set<AuthCredential>()
        set.insert(credential1)
        set.insert(credential2)

        #expect(set.count == 1)
    }
}

@Suite("AuthProvider Tests")
struct AuthProviderTests {
    @Test("Display names")
    func displayNames() {
        #expect(AuthProvider.apple.displayName == "Apple")
        #expect(AuthProvider.google.displayName == "Google")
        #expect(AuthProvider.email.displayName == "Email")
    }

    @Test("Raw values")
    func rawValues() {
        #expect(AuthProvider.apple.rawValue == "apple")
        #expect(AuthProvider.google.rawValue == "google")
        #expect(AuthProvider.email.rawValue == "email")
    }

    @Test("All cases")
    func allCases() {
        #expect(AuthProvider.allCases.count == 3)
        #expect(AuthProvider.allCases.contains(.apple))
        #expect(AuthProvider.allCases.contains(.google))
        #expect(AuthProvider.allCases.contains(.email))
    }
}

@Suite("ServerTokens Tests")
struct ServerTokensTests {
    @Test("isExpired returns true for past date")
    func isExpiredTrue() {
        let tokens = ServerTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(-60)
        )

        #expect(tokens.isExpired == true)
    }

    @Test("isExpired returns false for future date")
    func isExpiredFalse() {
        let tokens = ServerTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )

        #expect(tokens.isExpired == false)
    }

    @Test("willExpireSoon returns true within 5 minutes")
    func willExpireSoonTrue() {
        let tokens = ServerTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(120)
        )

        #expect(tokens.willExpireSoon == true)
    }

    @Test("willExpireSoon returns false beyond 5 minutes")
    func willExpireSoonFalse() {
        let tokens = ServerTokens(
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(600)
        )

        #expect(tokens.willExpireSoon == false)
    }
}
