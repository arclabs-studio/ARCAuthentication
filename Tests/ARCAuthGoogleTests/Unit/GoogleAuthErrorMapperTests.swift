import GoogleSignIn
import Testing
@testable import ARCAuthentication
@testable import ARCAuthGoogle

#if canImport(UIKit)
struct GoogleAuthErrorMapperTests {
    @Test("Should map canceled error to userCancelled", .tags(.unit)) func mapCanceledError() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.canceled.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .userCancelled)
    }

    @Test("Should map hasNoAuthInKeychain error to providerNotAvailable", .tags(.unit))
    func mapHasNoAuthInKeychainError() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.hasNoAuthInKeychain.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .providerNotAvailable(.google))
    }

    @Test("Should map scopesAlreadyGranted error to systemError", .tags(.unit)) func mapScopesAlreadyGrantedError() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.scopesAlreadyGranted.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        if case .systemError = result {
            // Expected
        } else {
            Issue.record("Expected systemError, got \(result)")
        }
    }

    @Test("Should map EMM error to systemError", .tags(.unit)) func mapEMMError() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.EMM.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        if case .systemError = result {
            // Expected
        } else {
            Issue.record("Expected systemError, got \(result)")
        }
    }

    @Test("Should map keychain error to systemError", .tags(.unit)) func mapKeychainError() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.keychain.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .systemError("Keychain error"))
    }

    @Test("Should map mismatchWithCurrentUser error to systemError", .tags(.unit))
    func mapMismatchWithCurrentUserError() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain,
                            code: GIDSignInError.mismatchWithCurrentUser.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .systemError("Operation does not match the current user"))
    }

    @Test("Should map GIDSignIn unknown code to unknown error", .tags(.unit)) func mapGoogleUnknownCode() {
        // Given
        let error = NSError(domain: GIDSignInError.errorDomain, code: GIDSignInError.unknown.rawValue)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .unknown(error.localizedDescription))
    }

    @Test("Should map non-GIDSignIn domain error to systemError", .tags(.unit)) func mapNonGoogleDomainError() {
        // Given
        let error = NSError(domain: "com.example.other", code: 42)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        if case .systemError = result {
            // Expected
        } else {
            Issue.record("Expected systemError, got \(result)")
        }
    }

    @Test("Should map unknown GIDSignIn code to unknown error", .tags(.unit)) func mapUnknownGoogleCode() {
        // Given — use a code value outside known GIDSignInError cases
        let error = NSError(domain: GIDSignInError.errorDomain, code: 999_999)

        // When
        let result = GoogleAuthErrorMapper.mapError(error)

        // Then
        if case .unknown = result {
            // Expected
        } else {
            Issue.record("Expected unknown, got \(result)")
        }
    }
}
#endif
