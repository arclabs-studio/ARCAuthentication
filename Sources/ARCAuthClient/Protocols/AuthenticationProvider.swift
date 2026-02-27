import ARCAuthCore
import Foundation

/// Protocol that defines the contract for any authentication provider.
///
/// Implement this protocol to add new authentication methods
/// (e.g., Google, Facebook, Email/Password, etc.).
///
/// ## Implementation
/// ```swift
/// public final class MyAuthProvider: AuthenticationProvider {
///     public let providerID: String = "my_provider"
///
///     public func authenticate() async throws -> AuthCredential {
///         // Provider-specific implementation
///     }
/// }
/// ```
///
/// ## Thread Safety
/// All implementations must be `Sendable` and thread-safe.
@MainActor
public protocol AuthenticationProvider: Sendable {
    /// Unique provider identifier (e.g., "apple", "google", "email").
    var providerID: String { get }

    /// Display name for UI.
    var displayName: String { get }

    /// Whether the provider is available on the current device.
    var isAvailable: Bool { get }

    /// Executes the authentication flow.
    /// - Returns: Credentials of the authenticated user.
    /// - Throws: `AuthenticationError` if authentication fails.
    func authenticate() async throws -> AuthCredential

    /// Signs out from the provider.
    func signOut() async throws

    /// Checks whether there is a valid active session.
    func checkCredentialState() async -> CredentialState
}

// MARK: - Default Implementations

extension AuthenticationProvider {
    public var displayName: String {
        providerID.capitalized
    }

    public var isAvailable: Bool {
        true
    }

    public func signOut() async throws {
        // Default: no-op (many providers don't require explicit sign out)
    }
}

// MARK: - Credential State

/// User credential state.
public enum CredentialState: Sendable, Equatable {
    /// Valid and authorized credentials.
    case authorized
    /// Credentials revoked by the user.
    case revoked
    /// No credentials found.
    case notFound
    /// Credential state transferred from another device.
    case transferred
}
