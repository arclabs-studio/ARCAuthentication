#if canImport(AuthenticationServices)
import AuthenticationServices
import Testing
@testable import ARCAuthentication

struct AppleCredentialProviderTests {
    #if canImport(UIKit)
    @Test("Should report .apple as provider type", .tags(.unit))
    @MainActor func providerType() {
        // Given
        let sut = AppleCredentialProvider()

        // Then
        #expect(sut.providerType == .apple)
    }

    @Test("Should accept custom scopes", .tags(.unit))
    @MainActor func customScopes() {
        // Given / When
        let sut = AppleCredentialProvider(scopes: [.email])

        // Then
        #expect(sut.providerType == .apple)
    }

    @Test("Should accept empty scopes", .tags(.unit))
    @MainActor func emptyScopes() {
        // Given / When
        let sut = AppleCredentialProvider(scopes: [])

        // Then
        #expect(sut.providerType == .apple)
    }
    #endif

    // MARK: - Error Mapping

    @Test("Should map canceled error to userCancelled", .tags(.unit)) func mapCanceledError() {
        // Given
        let error = ASAuthorizationError(.canceled)

        // When
        let result = AppleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .userCancelled)
    }

    @Test("Should map invalidResponse error to invalidIdentityToken", .tags(.unit)) func mapInvalidResponseError() {
        // Given
        let error = ASAuthorizationError(.invalidResponse)

        // When
        let result = AppleAuthErrorMapper.mapError(error)

        // Then
        #expect(result == .invalidIdentityToken)
    }

    @Test("Should map failed error to systemError", .tags(.unit)) func mapFailedError() {
        // Given
        let error = ASAuthorizationError(.failed)

        // When
        let result = AppleAuthErrorMapper.mapError(error)

        // Then
        if case .systemError = result {
            // Expected
        } else {
            Issue.record("Expected systemError, got \(result)")
        }
    }

    @Test("Should map non-ASAuthorizationError to systemError", .tags(.unit)) func mapGenericError() {
        // Given
        let error = NSError(domain: "test", code: 42)

        // When
        let result = AppleAuthErrorMapper.mapError(error)

        // Then
        if case .systemError = result {
            // Expected
        } else {
            Issue.record("Expected systemError, got \(result)")
        }
    }
}
#endif
