import ARCAuthCore
import Foundation

/// Protocol for secure credential storage.
///
/// The default implementation uses Keychain via ARCStorage.
@MainActor
public protocol AuthStorageProtocol: Sendable {
    /// Saves the authentication credentials.
    func saveCredential(_ credential: AuthCredential) async throws

    /// Gets the stored credentials.
    func getCredential() async throws -> AuthCredential?

    /// Deletes the stored credentials.
    func deleteCredential() async throws

    /// Whether there are stored credentials.
    func hasStoredCredential() async -> Bool
}
