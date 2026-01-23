import Foundation
import Testing

@testable import ARCAuthCore

@Suite("AuthenticationError Tests")
struct AuthenticationErrorTests {
    @Test("Error descriptions are not empty")
    func errorDescriptionsNotEmpty() {
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

        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    @Test("providerNotRegistered includes provider ID")
    func providerNotRegisteredIncludesID() {
        let error = AuthenticationError.providerNotRegistered("my_provider")
        #expect(error.errorDescription?.contains("my_provider") == true)
    }

    @Test("serverError includes status code and message")
    func serverErrorIncludesDetails() {
        let error = AuthenticationError.serverError(
            statusCode: 401,
            message: "Unauthorized"
        )
        #expect(error.errorDescription?.contains("401") == true)
        #expect(error.errorDescription?.contains("Unauthorized") == true)
    }

    @Test("Recovery suggestions for specific errors")
    func recoverySuggestions() {
        #expect(AuthenticationError.userCancelled.recoverySuggestion != nil)
        #expect(AuthenticationError.tokenExpired.recoverySuggestion != nil)
        #expect(AuthenticationError.networkError(underlying: nil).recoverySuggestion != nil)
        #expect(AuthenticationError.credentialRevoked.recoverySuggestion != nil)
    }

    @Test("Equatable conformance")
    func equatableConformance() {
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

    @Test("Different error types are not equal")
    func differentErrorTypesNotEqual() {
        #expect(AuthenticationError.userCancelled != AuthenticationError.tokenExpired)
        #expect(AuthenticationError.invalidCredentials != AuthenticationError.invalidIdentityToken)
    }
}
