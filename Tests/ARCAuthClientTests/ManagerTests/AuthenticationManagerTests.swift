import Foundation
import Testing
@testable import ARCAuthClient
@testable import ARCAuthCore

@Suite("AuthenticationManager Tests")
@MainActor
struct AuthenticationManagerTests {
    // MARK: - Factory

    private func makeSUT(
        storage: MockAuthStorage = MockAuthStorage(),
        configuration: AuthenticationConfiguration = .default
    ) -> (
        manager: AuthenticationManager,
        storage: MockAuthStorage
    ) {
        let manager = AuthenticationManager(storage: storage, configuration: configuration)
        return (manager, storage)
    }

    // MARK: - Provider Registration

    @Test("Should register provider when valid provider is given", .tags(.unit))
    func registerProvider() {
        // Given
        let (sut, _) = makeSUT()
        let provider = MockAuthenticationProvider(providerID: "test")

        // When
        sut.register(provider: provider)

        // Then
        #expect(sut.provider(for: "test") != nil)
    }

    @Test("Should return only available providers when filtering", .tags(.unit))
    func availableProviders() {
        // Given
        let (sut, _) = makeSUT()

        let available = MockAuthenticationProvider(providerID: "available")
        available.isAvailable = true

        let unavailable = MockAuthenticationProvider(providerID: "unavailable")
        unavailable.isAvailable = false

        sut.register(provider: available)
        sut.register(provider: unavailable)

        // When
        let providers = sut.availableProviders

        // Then
        #expect(providers.count == 1)
        #expect(providers.first?.providerID == "available")
    }

    // MARK: - Authentication

    @Test("Should authenticate and store credential when provider succeeds", .tags(.unit))
    func authenticateSuccess() async throws {
        // Given
        let storage = MockAuthStorage()
        let (sut, _) = makeSUT(storage: storage)

        let credential = AuthCredential(
            userID: "user123",
            email: "test@example.com",
            provider: .apple
        )

        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .success(credential)
        sut.register(provider: provider)

        // When
        try await sut.authenticate(with: "apple")

        // Then
        #expect(sut.state.isAuthenticated == true)
        #expect(sut.state.currentCredential?.userID == "user123")
        #expect(storage.saveCallCount == 1)
    }

    @Test("Should throw error when provider is not registered", .tags(.unit))
    func authenticateFailureNotRegistered() async {
        // Given
        let (sut, _) = makeSUT()

        // When / Then
        await #expect(throws: AuthenticationError.self) {
            try await sut.authenticate(with: "unknown")
        }
    }

    @Test("Should set error state when provider fails", .tags(.unit))
    func authenticateFailureProviderError() async {
        // Given
        let (sut, _) = makeSUT()

        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .failure(AuthenticationError.userCancelled)
        sut.register(provider: provider)

        // When
        await #expect(throws: AuthenticationError.self) {
            try await sut.authenticate(with: "apple")
        }

        // Then
        #expect(sut.state.isAuthenticated == false)
        #expect(sut.state.lastError == .userCancelled)
    }

    // MARK: - Sign Out

    @Test("Should clear state and storage when signing out", .tags(.unit))
    func signOutSuccess() async throws {
        // Given
        let storage = MockAuthStorage()
        let (sut, _) = makeSUT(storage: storage)

        let credential = AuthCredential(userID: "user123", provider: .apple)
        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .success(credential)
        sut.register(provider: provider)

        try await sut.authenticate(with: "apple")
        #expect(sut.state.isAuthenticated == true)

        // When
        try await sut.signOut()

        // Then
        #expect(sut.state.isAuthenticated == false)
        #expect(sut.state.currentCredential == nil)
        #expect(storage.deleteCallCount == 1)
    }

    @Test("Should clear state when signing out without registered provider", .tags(.unit))
    func signOutWithoutProvider() async throws {
        // Given
        let storage = MockAuthStorage()
        let (sut, _) = makeSUT(storage: storage)

        // When
        try await sut.signOut()

        // Then
        #expect(sut.state.isAuthenticated == false)
        #expect(storage.deleteCallCount == 1)
    }

    // MARK: - Session Restore

    @Test("Should restore session when stored credential exists", .tags(.unit))
    func restoreSessionWithCredential() async {
        // Given
        let storage = MockAuthStorage()
        storage.storedCredential = AuthCredential(
            userID: "user123",
            provider: .google
        )

        let (sut, _) = makeSUT(
            storage: storage,
            configuration: AuthenticationConfiguration(verifyAppleCredentialsOnRestore: false)
        )

        // When
        await sut.restoreSession()

        // Then
        #expect(sut.state.isAuthenticated == true)
        #expect(sut.state.currentCredential?.userID == "user123")
    }

    @Test("Should set unauthenticated when no stored credential exists", .tags(.unit))
    func restoreSessionWithoutCredential() async {
        // Given
        let storage = MockAuthStorage()
        let (sut, _) = makeSUT(storage: storage)

        // When
        await sut.restoreSession()

        // Then
        #expect(sut.state.isAuthenticated == false)
    }

    // MARK: - State Management

    @Test("Should not be loading after authentication completes", .tags(.unit))
    func stateLoadingDuringAuthenticate() async throws {
        // Given
        let storage = MockAuthStorage()
        let (sut, _) = makeSUT(storage: storage)

        let provider = MockAuthenticationProvider(providerID: "apple")
        sut.register(provider: provider)

        #expect(sut.state.isLoading == false)

        // When
        try await sut.authenticate(with: "apple")

        // Then
        #expect(sut.state.isLoading == false)
    }

    @Test("Should clear error when starting new authentication", .tags(.unit))
    func errorClearedOnNewAuthentication() async throws {
        // Given
        let storage = MockAuthStorage()
        let (sut, _) = makeSUT(storage: storage)

        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .failure(AuthenticationError.userCancelled)
        sut.register(provider: provider)

        await #expect(throws: AuthenticationError.self) {
            try await sut.authenticate(with: "apple")
        }
        #expect(sut.state.lastError != nil)

        // When - authenticate again (success this time)
        provider.authenticateResult = .success(AuthCredential(userID: "user123", provider: .apple))
        try await sut.authenticate(with: "apple")

        // Then
        #expect(sut.state.lastError == nil)
    }

    @Test("Should return notFound when checking credential state without session", .tags(.unit))
    func checkCredentialStateWithoutSession() async {
        // Given
        let (sut, _) = makeSUT()

        // When
        let credentialState = await sut.checkCredentialState()

        // Then
        #expect(credentialState == .notFound)
    }

    @Test("Should propagate storage failure on authenticate", .tags(.unit))
    func storageFailurePropagation() async {
        // Given
        let storage = MockAuthStorage()
        storage.saveError = AuthenticationError.storageSaveFailed(underlying: nil)
        let (sut, _) = makeSUT(storage: storage)

        let provider = MockAuthenticationProvider(providerID: "apple")
        sut.register(provider: provider)

        // When / Then
        await #expect(throws: AuthenticationError.self) {
            try await sut.authenticate(with: "apple")
        }
        #expect(sut.state.isAuthenticated == false)
    }
}
