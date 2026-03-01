import Foundation

/// Configuration for Google Sign-In.
///
/// Provide your OAuth client ID from the Google Cloud Console.
///
/// ## Usage
/// ```swift
/// let config = GoogleConfiguration(
///     clientID: "your-client-id.apps.googleusercontent.com"
/// )
/// let provider = GoogleCredentialProvider(configuration: config)
/// ```
public struct GoogleConfiguration: Sendable {
    /// The OAuth 2.0 client ID from Google Cloud Console.
    public let clientID: String

    /// Additional OAuth scopes to request beyond `openid`, `email`, `profile`.
    public let additionalScopes: [String]

    /// Creates a Google configuration.
    /// - Parameters:
    ///   - clientID: The OAuth client ID.
    ///   - additionalScopes: Extra scopes to request (default: none).
    public init(clientID: String,
                additionalScopes: [String] = []) {
        self.clientID = clientID
        self.additionalScopes = additionalScopes
    }
}
