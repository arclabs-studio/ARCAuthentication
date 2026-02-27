import Foundation
import Testing
@testable import ARCAuthCore

@Suite("AuthenticationError Tests")
struct AuthenticationErrorTests {
    @Test("Should have non-empty descriptions for all error types", .tags(.unit))
    func errorDescriptionsNotEmpty() {
        // Given
        let errors: [AuthenticationError] = [
            .providerNotRegistered("test"),
            .appleSignInFailed(underlying: nil),
            .userCancelled,
            .invalidCredentials,
            .invalidIdentityToken,
            .tokenExpired,
            .tokenRefreshFailed(underlying: nil),
            .storageSaveFailed(underlying: nil),
            .storageReadFailed(underlying: nil),
            .storageDeleteFailed(underlying: nil),
            .networkError(underlying: nil),
            .serverError(statusCode: 500, message: "Internal error"),
            .noActiveSession,
            .credentialRevoked,
            .unknown(underlying: nil)
        ]

        // When / Then
        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    @Test("Should include provider ID in providerNotRegistered description", .tags(.unit))
    func providerNotRegisteredIncludesID() {
        // Given
        let sut = AuthenticationError.providerNotRegistered("my_provider")

        // When / Then
        #expect(sut.errorDescription?.contains("my_provider") == true)
    }

    @Test("Should include status code and message in serverError description", .tags(.unit))
    func serverErrorIncludesDetails() {
        // Given
        let sut = AuthenticationError.serverError(
            statusCode: 401,
            message: "Unauthorized"
        )

        // When / Then
        #expect(sut.errorDescription?.contains("401") == true)
        #expect(sut.errorDescription?.contains("Unauthorized") == true)
    }

    @Test("Should provide recovery suggestions for specific errors", .tags(.unit))
    func recoverySuggestions() {
        // Given / When / Then
        #expect(AuthenticationError.userCancelled.recoverySuggestion != nil)
        #expect(AuthenticationError.tokenExpired.recoverySuggestion != nil)
        #expect(AuthenticationError.networkError(underlying: nil).recoverySuggestion != nil)
        #expect(AuthenticationError.credentialRevoked.recoverySuggestion != nil)
    }

    @Test("Should be equal when same type and associated values match", .tags(.unit))
    func equatableConformance() {
        // Given / When / Then
        #expect(AuthenticationError.userCancelled == AuthenticationError.userCancelled)
        #expect(AuthenticationError.tokenExpired == AuthenticationError.tokenExpired)

        #expect(
            AuthenticationError.providerNotRegistered("a") ==
                AuthenticationError.providerNotRegistered("a")
        )
        #expect(
            AuthenticationError.providerNotRegistered("a") !=
                AuthenticationError.providerNotRegistered("b")
        )

        #expect(
            AuthenticationError.serverError(statusCode: 500, message: "Error") ==
                AuthenticationError.serverError(statusCode: 500, message: "Error")
        )
        #expect(
            AuthenticationError.serverError(statusCode: 500, message: nil) !=
                AuthenticationError.serverError(statusCode: 400, message: nil)
        )
    }

    @Test("Should not be equal when different error types", .tags(.unit))
    func differentErrorTypesNotEqual() {
        // Given / When / Then
        #expect(AuthenticationError.userCancelled != AuthenticationError.tokenExpired)
        #expect(AuthenticationError.invalidCredentials != AuthenticationError.invalidIdentityToken)
    }
}
