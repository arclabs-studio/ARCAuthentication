import ARCStorage
import Foundation
import Testing
@testable import ARCAuthClient
@testable import ARCAuthCore

/// Integration tests for `KeychainAuthStorage`.
///
/// These tests require Keychain entitlements and will only pass when run
/// in an Xcode project with Keychain Sharing enabled (not `swift test` CLI).
/// They are tagged `.integration` to exclude from default CI runs.
@Suite("KeychainAuthStorage Tests")
@MainActor
struct KeychainAuthStorageTests {
    // MARK: - Factory

    private static let testService = "com.arclabs.authentication.tests"

    private func makeSUT() -> KeychainAuthStorage {
        let repository = KeychainRepository<AuthCredential>(
            service: Self.testService,
            accessibility: .whenUnlocked
        )
        return KeychainAuthStorage(repository: repository)
    }

    private func makeCredential(
        userID: String = "test_user_123",
        email: String? = "test@example.com",
        provider: AuthProvider = .apple
    ) -> AuthCredential {
        AuthCredential(
            userID: userID,
            email: email,
            provider: provider
        )
    }

    /// Checks whether Keychain is available in the current environment.
    private func keychainAvailable() async -> Bool {
        let sut = makeSUT()
        let testCredential = makeCredential(userID: "keychain_probe")
        do {
            try await sut.saveCredential(testCredential)
            try await sut.deleteCredential()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Save & Retrieve

    @Test("Should save and retrieve credential round-trip", .tags(.integration))
    func saveAndRetrieve() async throws {
        let sut = makeSUT()
        guard await keychainAvailable() else { return }

        // Given
        let credential = makeCredential()

        // When
        try await sut.saveCredential(credential)
        let retrieved = try await sut.getCredential()

        // Then
        #expect(retrieved != nil)
        #expect(retrieved?.userID == credential.userID)
        #expect(retrieved?.email == credential.email)
        #expect(retrieved?.provider == credential.provider)

        // Cleanup
        try await sut.deleteCredential()
    }

    @Test("Should overwrite existing credential on save", .tags(.integration))
    func saveOverwrites() async throws {
        let sut = makeSUT()
        guard await keychainAvailable() else { return }

        // Given
        let first = makeCredential(userID: "first_user")
        let second = makeCredential(userID: "second_user")

        // When
        try await sut.saveCredential(first)
        try await sut.saveCredential(second)
        let retrieved = try await sut.getCredential()

        // Then
        #expect(retrieved?.userID == "second_user")

        // Cleanup
        try await sut.deleteCredential()
    }

    // MARK: - Get

    @Test("Should return nil when no credential stored", .tags(.integration))
    func getReturnsNilWhenEmpty() async throws {
        let sut = makeSUT()
        guard await keychainAvailable() else { return }

        // Given
        try await sut.deleteCredential()

        // When
        let result = try await sut.getCredential()

        // Then
        #expect(result == nil)
    }

    // MARK: - Delete

    @Test("Should remove credential on delete", .tags(.integration))
    func deleteRemovesCredential() async throws {
        let sut = makeSUT()
        guard await keychainAvailable() else { return }

        // Given
        try await sut.saveCredential(makeCredential())

        // When
        try await sut.deleteCredential()

        // Then
        let result = try await sut.getCredential()
        #expect(result == nil)
    }

    // MARK: - Has Stored Credential

    @Test("Should return true when credential exists", .tags(.integration))
    func hasStoredCredentialTrue() async throws {
        let sut = makeSUT()
        guard await keychainAvailable() else { return }

        // Given
        try await sut.saveCredential(makeCredential())

        // When
        let result = await sut.hasStoredCredential()

        // Then
        #expect(result == true)

        // Cleanup
        try await sut.deleteCredential()
    }

    @Test("Should return false when no credential stored", .tags(.integration))
    func hasStoredCredentialFalse() async throws {
        let sut = makeSUT()
        guard await keychainAvailable() else { return }

        // Given
        try await sut.deleteCredential()

        // When
        let result = await sut.hasStoredCredential()

        // Then
        #expect(result == false)
    }
}
