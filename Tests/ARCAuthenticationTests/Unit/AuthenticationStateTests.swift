import Testing
@testable import ARCAuthentication

@Suite("AuthenticationState Tests")
struct AuthenticationStateTests {
    @Test("Should represent unauthenticated state", .tags(.unit)) func unauthenticated() {
        // Given / When
        let sut: AuthenticationState<String> = .unauthenticated

        // Then
        if case .unauthenticated = sut {
            // Expected
        } else {
            Issue.record("Expected .unauthenticated, got \(sut)")
        }
    }

    @Test("Should represent authenticating state", .tags(.unit)) func authenticating() {
        // Given / When
        let sut: AuthenticationState<String> = .authenticating

        // Then
        if case .authenticating = sut {
            // Expected
        } else {
            Issue.record("Expected .authenticating, got \(sut)")
        }
    }

    @Test("Should hold associated user value in authenticated state", .tags(.unit)) func authenticated() {
        // Given
        let user = "mock-user"

        // When
        let sut: AuthenticationState<String> = .authenticated(user)

        // Then
        if case let .authenticated(value) = sut {
            #expect(value == user)
        } else {
            Issue.record("Expected .authenticated, got \(sut)")
        }
    }

    @Test("Should hold associated error in error state", .tags(.unit)) func errorState() {
        // Given
        let error = AuthenticationError.userCancelled

        // When
        let sut: AuthenticationState<String> = .error(error)

        // Then
        if case let .error(value) = sut {
            #expect(value == error)
        } else {
            Issue.record("Expected .error, got \(sut)")
        }
    }
}
