import Testing
@testable import ARCAuthentication

@Suite("MockCredentialProvider Tests")
struct MockCredentialProviderTests {
    // MARK: - Success

    @Test("Should return configured success result", .tags(.unit))
    func successResult() async throws {
        // Given
        let expected = AuthCredential.apple(.mock)
        let sut = MockCredentialProvider(result: .success(expected))

        // When
        let result = try await sut.requestCredential()

        // Then
        #expect(result == expected)
    }

    @Test("Should return configured Google credential", .tags(.unit))
    func googleResult() async throws {
        // Given
        let expected = AuthCredential.google(.mock)
        let sut = MockCredentialProvider(
            providerType: .google,
            result: .success(expected))

        // When
        let result = try await sut.requestCredential()

        // Then
        #expect(result == expected)
        #expect(sut.providerType == .google)
    }

    // MARK: - Failure

    @Test("Should throw configured failure", .tags(.unit))
    func failureResult() async {
        // Given
        let sut = MockCredentialProvider(result: .failure(.userCancelled))

        // When / Then
        await #expect(throws: AuthenticationError.userCancelled) {
            try await sut.requestCredential()
        }
    }

    // MARK: - Call Tracking

    @Test("Should track call count", .tags(.unit))
    func callCount() async throws {
        // Given
        let sut = MockCredentialProvider()
        #expect(sut.requestCredentialCallCount == 0)

        // When
        _ = try await sut.requestCredential()
        _ = try await sut.requestCredential()
        _ = try await sut.requestCredential()

        // Then
        #expect(sut.requestCredentialCallCount == 3)
    }

    // MARK: - Provider Type

    @Test("Should report configured provider type", .tags(.unit))
    func providerType() {
        // Given / When
        let appleMock = MockCredentialProvider(providerType: .apple)
        let googleMock = MockCredentialProvider(providerType: .google)

        // Then
        #expect(appleMock.providerType == .apple)
        #expect(googleMock.providerType == .google)
    }

    // MARK: - Default Values

    @Test("Should default to .apple provider type", .tags(.unit))
    func defaultProviderType() {
        // Given / When
        let sut = MockCredentialProvider()

        // Then
        #expect(sut.providerType == .apple)
    }

    @Test("Should default to success with apple mock", .tags(.unit))
    func defaultResult() async throws {
        // Given
        let sut = MockCredentialProvider()

        // When
        let result = try await sut.requestCredential()

        // Then
        if case let .apple(credential) = result {
            #expect(credential == AppleCredential.mock)
        } else {
            Issue.record("Expected .apple case")
        }
    }

    // MARK: - Mutable Result

    @Test("Should allow changing result between calls", .tags(.unit))
    func mutableResult() async throws {
        // Given
        let sut = MockCredentialProvider(result: .success(.apple(.mock)))

        // When — first call succeeds
        let first = try await sut.requestCredential()
        #expect(first == .apple(.mock))

        // Then — change to failure
        sut.result = .failure(.userCancelled)
        await #expect(throws: AuthenticationError.userCancelled) {
            try await sut.requestCredential()
        }

        #expect(sut.requestCredentialCallCount == 2)
    }
}
