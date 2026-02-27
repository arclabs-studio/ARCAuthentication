import Foundation
import Testing
@testable import ARCAuthCore

@Suite("AuthConstants Tests")
struct AuthConstantsTests {
    // MARK: - Keychain

    @Test("Should have correct Keychain constant values", .tags(.unit))
    func keychainConstants() {
        // Given / When / Then
        #expect(AuthConstants.Keychain.service == "com.arclabs.authentication")
        #expect(AuthConstants.Keychain.credentialKey == "auth.credential")
        #expect(AuthConstants.Keychain.userIDKey == "auth.user_id")
    }

    // MARK: - Token

    @Test("Should have correct Token constant values", .tags(.unit))
    func tokenConstants() {
        // Given / When / Then
        #expect(AuthConstants.Token.refreshThreshold == 300)
        #expect(AuthConstants.Token.defaultAccessTokenDuration == 3600)
        #expect(AuthConstants.Token.defaultRefreshTokenDuration == 2_592_000)
    }

    // MARK: - Defaults

    @Test("Should have correct UserDefaults key values", .tags(.unit))
    func defaultsConstants() {
        // Given / When / Then
        #expect(AuthConstants.Defaults.displayNameKey == "auth.displayName")
    }

    // MARK: - Apple

    @Test("Should have correct Apple constant values", .tags(.unit))
    func appleConstants() {
        // Given / When / Then
        #expect(AuthConstants.Apple.defaultScopes == ["fullName", "email"])
        #expect(AuthConstants.Apple.authorizationCodeExpiration == 300)
    }
}
