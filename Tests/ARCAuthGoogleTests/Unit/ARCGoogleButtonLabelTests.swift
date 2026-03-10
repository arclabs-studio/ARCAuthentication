#if canImport(SwiftUI)
import SwiftUI
import Testing
@testable import ARCAuthGoogle

@Suite("ARCGoogleButtonLabel Tests")
struct ARCGoogleButtonLabelTests {
    @Test("Should return 'Sign in with Google' key for signIn case", .tags(.unit)) func signInTitleKey() {
        // Given / When
        let sut = ARCGoogleButtonLabel.signIn

        // Then
        #expect(sut.titleKey == "Sign in with Google")
    }

    @Test("Should return 'Sign up with Google' key for signUp case", .tags(.unit)) func signUpTitleKey() {
        // Given / When
        let sut = ARCGoogleButtonLabel.signUp

        // Then
        #expect(sut.titleKey == "Sign up with Google")
    }

    @Test("Should return 'Continue with Google' key for continue case", .tags(.unit)) func continueTitleKey() {
        // Given / When
        let sut = ARCGoogleButtonLabel.continue

        // Then
        #expect(sut.titleKey == "Continue with Google")
    }

    @Test("Should have distinct title keys for all cases", .tags(.unit)) func allTitleKeysDistinct() {
        // Given
        let keys = [ARCGoogleButtonLabel.signIn.titleKey,
                    ARCGoogleButtonLabel.signUp.titleKey,
                    ARCGoogleButtonLabel.continue.titleKey]

        // When / Then
        #expect(Set(keys).count == 3)
    }

    @Test("Should be Sendable", .tags(.unit)) func isSendable() {
        // Given / When — compile-time conformance check
        let _: any Sendable = ARCGoogleButtonLabel.signIn
    }
}
#endif
