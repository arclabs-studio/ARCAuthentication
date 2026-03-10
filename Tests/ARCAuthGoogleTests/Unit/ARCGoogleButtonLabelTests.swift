#if canImport(SwiftUI)
import SwiftUI
import Testing
@testable import ARCAuthGoogle

@Suite("ARCGoogleButtonLabel Tests")
struct ARCGoogleButtonLabelTests {
    @Test("Should return 'Sign in with Google' for signIn case", .tags(.unit)) func signInTitle() {
        // Given / When
        let sut = ARCGoogleButtonLabel.signIn

        // Then
        #expect(sut.title == "Sign in with Google")
    }

    @Test("Should return 'Sign up with Google' for signUp case", .tags(.unit)) func signUpTitle() {
        // Given / When
        let sut = ARCGoogleButtonLabel.signUp

        // Then
        #expect(sut.title == "Sign up with Google")
    }

    @Test("Should return 'Continue with Google' for continue case", .tags(.unit)) func continueTitle() {
        // Given / When
        let sut = ARCGoogleButtonLabel.continue

        // Then
        #expect(sut.title == "Continue with Google")
    }

    @Test("Should have distinct titles for all cases", .tags(.unit)) func allTitlesDistinct() {
        // Given
        let titles = [ARCGoogleButtonLabel.signIn.title,
                      ARCGoogleButtonLabel.signUp.title,
                      ARCGoogleButtonLabel.continue.title]

        // When / Then
        #expect(Set(titles).count == 3)
    }

    @Test("Should be Sendable", .tags(.unit)) func isSendable() {
        // Given / When — compile-time conformance check
        let _: any Sendable = ARCGoogleButtonLabel.signIn
    }
}
#endif
