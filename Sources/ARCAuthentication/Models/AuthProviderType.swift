import Foundation

/// Supported authentication provider types.
///
/// Each case represents a third-party identity provider that can issue
/// credentials for your application.
///
/// ## Usage
/// ```swift
/// let provider: AuthProviderType = .apple
/// print(provider.rawValue) // "apple"
/// ```
public enum AuthProviderType: String, Sendable, CaseIterable, Codable {
    /// Sign in with Apple.
    case apple

    /// Google Sign-In.
    case google
}
