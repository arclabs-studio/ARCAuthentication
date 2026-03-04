import Foundation
import Testing
@testable import ARCAuthentication

@Suite("AuthenticationError Tests")
struct AuthenticationErrorTests {
    // MARK: - Error Descriptions

    @Test("Should provide non-nil errorDescription for all cases", .tags(.unit)) func allCasesHaveDescriptions() {
        // Given
        let allCases: [AuthenticationError] = [.userCancelled,
                                               .providerNotAvailable(.apple),
                                               .providerNotAvailable(.google),
                                               .invalidIdentityToken,
                                               .missingAuthorizationCode,
                                               .unexpectedCredentialType,
                                               .nonceMismatch,
                                               .invalidConfiguration("test"),
                                               .systemError("test"),
                                               .unknown("test")]

        // Then
        for error in allCases {
            #expect(error.errorDescription != nil, "Missing description for: \(error)")
            #expect(error.errorDescription?.isEmpty == false, "Empty description for: \(error)")
        }
    }

    @Test("Should include provider name in providerNotAvailable description", .tags(.unit))
    func providerNotAvailableDescription() {
        // Given
        let error = AuthenticationError.providerNotAvailable(.apple)

        // Then
        #expect(error.errorDescription?.contains("apple") == true)
    }

    @Test("Should include message in invalidConfiguration description", .tags(.unit))
    func invalidConfigurationDescription() {
        // Given
        let message = "Missing client ID"
        let error = AuthenticationError.invalidConfiguration(message)

        // Then
        #expect(error.errorDescription?.contains(message) == true)
    }

    @Test("Should include message in systemError description", .tags(.unit)) func systemErrorDescription() {
        // Given
        let message = "Network unavailable"
        let error = AuthenticationError.systemError(message)

        // Then
        #expect(error.errorDescription?.contains(message) == true)
    }

    @Test("Should include message in unknown description", .tags(.unit)) func unknownDescription() {
        // Given
        let message = "Something went wrong"
        let error = AuthenticationError.unknown(message)

        // Then
        #expect(error.errorDescription?.contains(message) == true)
    }

    // MARK: - Equatable

    @Test("Should be equal for same cases with same values", .tags(.unit)) func equatable() {
        // Given / Then
        #expect(AuthenticationError.userCancelled == .userCancelled)
        #expect(AuthenticationError.invalidIdentityToken == .invalidIdentityToken)
        #expect(AuthenticationError.missingAuthorizationCode == .missingAuthorizationCode)
        #expect(AuthenticationError.unexpectedCredentialType == .unexpectedCredentialType)
        #expect(AuthenticationError.nonceMismatch == .nonceMismatch)
        #expect(AuthenticationError.providerNotAvailable(.apple) == .providerNotAvailable(.apple))
        #expect(AuthenticationError.invalidConfiguration("a") == .invalidConfiguration("a"))
        #expect(AuthenticationError.systemError("a") == .systemError("a"))
        #expect(AuthenticationError.unknown("a") == .unknown("a"))
    }

    @Test("Should not be equal for different cases", .tags(.unit)) func notEquatable() {
        // Given / Then
        #expect(AuthenticationError.userCancelled != .invalidIdentityToken)
        #expect(AuthenticationError.providerNotAvailable(.apple) != .providerNotAvailable(.google))
        #expect(AuthenticationError.invalidConfiguration("a") != .invalidConfiguration("b"))
    }
}
