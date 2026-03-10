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
///
/// ## Note on GIDSignIn configuration
///
/// ``GoogleCredentialProvider`` applies this configuration to
/// `GIDSignIn.sharedInstance.configuration` on every sign-in call.
/// If your app needs additional properties on the shared instance (e.g.
/// `serverClientID` for Firebase backend OAuth), set them after
/// ``GoogleCredentialProvider/requestCredential()`` returns, or manage
/// `GIDSignIn.sharedInstance` directly alongside this provider.
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
