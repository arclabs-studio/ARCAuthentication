import ARCAuthCore
import ARCStorage
import Foundation

/// Credential storage implementation using Keychain.
///
/// Uses `KeychainRepository` from ARCStorage for secure Keychain access.
///
/// ## Security Level
/// Uses `.whenUnlockedThisDeviceOnly` by default:
/// - Only accessible when the device is unlocked
/// - NOT synced to other devices (security)
/// - Credentials are deleted if the app is removed
///
/// ## Usage
/// ```swift
/// let storage = KeychainAuthStorage()
/// try await storage.saveCredential(credential)
/// let restored = try await storage.getCredential()
/// ```
@MainActor
public final class KeychainAuthStorage: AuthStorageProtocol {
    // MARK: - Properties

    private let repository: KeychainRepository<AuthCredential>

    // MARK: - Initialization

    /// Initializes the storage with the default security level.
    public init() {
        repository = KeychainRepository<AuthCredential>(
            service: AuthConstants.Keychain.service,
            accessibility: .whenUnlockedThisDeviceOnly
        )
    }

    /// Initializes the storage with a custom security level.
    /// - Parameter accessibility: Keychain accessibility level.
    public init(accessibility: KeychainAccessibility) {
        repository = KeychainRepository<AuthCredential>(
            service: AuthConstants.Keychain.service,
            accessibility: accessibility
        )
    }

    /// Initializes the storage with a custom repository (useful for testing).
    /// - Parameter repository: Repository to use.
    init(repository: KeychainRepository<AuthCredential>) {
        self.repository = repository
    }

    // MARK: - AuthStorageProtocol

    public func saveCredential(_ credential: AuthCredential) async throws {
        do {
            // First delete any existing credential
            let existing = try await repository.fetchAll()
            for old in existing {
                try await repository.delete(id: old.id)
            }
            // Save the new credential
            try await repository.save(credential)
        } catch {
            throw AuthenticationError.storageSaveFailed(underlying: error)
        }
    }

    public func getCredential() async throws -> AuthCredential? {
        do {
            let credentials = try await repository.fetchAll()
            return credentials.first
        } catch {
            // If not found, return nil instead of error
            return nil
        }
    }

    public func deleteCredential() async throws {
        do {
            let credentials = try await repository.fetchAll()
            for credential in credentials {
                try await repository.delete(id: credential.id)
            }
        } catch {
            throw AuthenticationError.storageDeleteFailed(underlying: error)
        }
    }

    public func hasStoredCredential() async -> Bool {
        do {
            let credentials = try await repository.fetchAll()
            return !credentials.isEmpty
        } catch {
            return false
        }
    }
}
