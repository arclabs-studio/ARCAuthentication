/// A type that can obtain authentication credentials from a provider.
///
/// Conform to this protocol to add a new authentication provider.
/// Each provider encapsulates the platform-specific sign-in flow and
/// returns a provider-agnostic ``AuthCredential``.
///
/// ## Implementing a Custom Provider
/// ```swift
/// final class MyProvider: CredentialProviding {
///     let providerType: AuthProviderType = .apple
///
///     func requestCredential() async throws -> AuthCredential {
///         // Perform sign-in flow...
///         return .apple(credential)
///     }
/// }
/// ```
public protocol CredentialProviding: Sendable {
    /// The type of provider this instance represents.
    var providerType: AuthProviderType { get }

    /// Requests a credential from the provider.
    ///
    /// This method presents the provider's sign-in UI (if needed) and
    /// returns the resulting credential. Throws ``AuthenticationError``
    /// on failure.
    ///
    /// - Returns: The obtained credential.
    /// - Throws: ``AuthenticationError`` if the flow fails or is cancelled.
    func requestCredential() async throws -> AuthCredential
}
