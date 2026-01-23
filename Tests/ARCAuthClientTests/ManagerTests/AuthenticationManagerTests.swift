import Foundation
import Testing

@testable import ARCAuthClient
@testable import ARCAuthCore

@Suite("AuthenticationManager Tests")
@MainActor
struct AuthenticationManagerTests {
    @Test("Register provider")
    func registerProvider() async {
        let manager = AuthenticationManager()
        let provider = MockAuthenticationProvider(providerID: "test")

        manager.register(provider: provider)

        #expect(manager.provider(for: "test") != nil)
    }

    @Test("Available providers only returns available ones")
    func availableProviders() async {
        let manager = AuthenticationManager()

        let available = MockAuthenticationProvider(providerID: "available")
        available.isAvailable = true

        let unavailable = MockAuthenticationProvider(providerID: "unavailable")
        unavailable.isAvailable = false

        manager.register(provider: available)
        manager.register(provider: unavailable)

        let providers = manager.availableProviders
        #expect(providers.count == 1)
        #expect(providers.first?.providerID == "available")
    }

    @Test("Authenticate success")
    func authenticateSuccess() async throws {
        let storage = MockAuthStorage()
        let manager = AuthenticationManager(storage: storage)

        let credential = AuthCredential(
            userID: "user123",
            email: "test@example.com",
            provider: .apple
        )

        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .success(credential)
        manager.register(provider: provider)

        try await manager.authenticate(with: "apple")

        #expect(manager.state.isAuthenticated == true)
        #expect(manager.state.currentCredential?.userID == "user123")
        #expect(storage.saveCallCount == 1)
    }

    @Test("Authenticate failure - provider not registered")
    func authenticateFailureNotRegistered() async {
        let manager = AuthenticationManager()

        await #expect(throws: AuthenticationError.self) {
            try await manager.authenticate(with: "unknown")
        }
    }

    @Test("Authenticate failure - provider error")
    func authenticateFailureProviderError() async {
        let manager = AuthenticationManager()

        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .failure(AuthenticationError.userCancelled)
        manager.register(provider: provider)

        await #expect(throws: AuthenticationError.self) {
            try await manager.authenticate(with: "apple")
        }

        #expect(manager.state.isAuthenticated == false)
        #expect(manager.state.lastError == .userCancelled)
    }

    @Test("Sign out success")
    func signOutSuccess() async throws {
        let storage = MockAuthStorage()
        let manager = AuthenticationManager(storage: storage)

        let credential = AuthCredential(userID: "user123", provider: .apple)
        let provider = MockAuthenticationProvider(providerID: "apple")
        provider.authenticateResult = .success(credential)
        manager.register(provider: provider)

        try await manager.authenticate(with: "apple")
        #expect(manager.state.isAuthenticated == true)

        try await manager.signOut()

        #expect(manager.state.isAuthenticated == false)
        #expect(manager.state.currentCredential == nil)
        #expect(storage.deleteCallCount == 1)
    }

    @Test("Restore session with stored credential")
    func restoreSessionWithCredential() async {
        let storage = MockAuthStorage()
        storage.storedCredential = AuthCredential(
            userID: "user123",
            provider: .google
        )

        let manager = AuthenticationManager(
            storage: storage,
            configuration: AuthenticationConfiguration(verifyAppleCredentialsOnRestore: false)
        )

        await manager.restoreSession()

        #expect(manager.state.isAuthenticated == true)
        #expect(manager.state.currentCredential?.userID == "user123")
    }

    @Test("Restore session without credential")
    func restoreSessionWithoutCredential() async {
        let storage = MockAuthStorage()
        let manager = AuthenticationManager(storage: storage)

        await manager.restoreSession()

        #expect(manager.state.isAuthenticated == false)
    }

    @Test("State loading during authenticate")
    func stateLoadingDuringAuthenticate() async throws {
        let storage = MockAuthStorage()
        let manager = AuthenticationManager(storage: storage)

        let provider = MockAuthenticationProvider(providerID: "apple")
        manager.register(provider: provider)

        #expect(manager.state.isLoading == false)

        try await manager.authenticate(with: "apple")

        #expect(manager.state.isLoading == false)
    }
}
