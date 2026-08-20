#if canImport(SwiftUI) && canImport(AuthenticationServices)
import AuthenticationServices
import SwiftUI
import Testing
@testable import ARCAuthentication

struct ARCAppleButtonLabelTests {
    @Test("Should expose signIn case", .tags(.unit)) func signInCaseExists() {
        // Given / When
        let sut = ARCAppleButtonLabel.signIn

        // Then — distinct from the other cases
        #expect(sut != .signUp)
        #expect(sut != .continue)
    }

    @Test("Should expose signUp case", .tags(.unit)) func signUpCaseExists() {
        // Given / When
        let sut = ARCAppleButtonLabel.signUp

        // Then
        #expect(sut != .signIn)
        #expect(sut != .continue)
    }

    @Test("Should expose continue case", .tags(.unit)) func continueCaseExists() {
        // Given / When
        let sut = ARCAppleButtonLabel.continue

        // Then
        #expect(sut != .signIn)
        #expect(sut != .signUp)
    }

    @Test("Should produce a native label for every case", .tags(.unit)) func nativeLabelForAllCases() {
        // Given
        let cases: [ARCAppleButtonLabel] = [.signIn, .signUp, .continue]

        // When / Then — verifies nativeLabel resolves (SignInWithAppleButton.Label is
        // not Equatable, so correctness is enforced by the exhaustive switch in nativeLabel)
        for label in cases {
            let _: SignInWithAppleButton.Label = label.nativeLabel
        }
    }

    @Test("Should be Sendable", .tags(.unit)) func isSendable() {
        // Given / When — compile-time conformance check
        let _: any Sendable = ARCAppleButtonLabel.signIn
    }
}
#endif
