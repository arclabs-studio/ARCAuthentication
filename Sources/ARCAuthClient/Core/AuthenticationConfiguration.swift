import Foundation

/// Configuration for the authentication system.
public struct AuthenticationConfiguration: Sendable {
    /// Base URL of the authentication server (for future use with backend).
    public let serverBaseURL: URL?

    /// Whether to verify Apple credentials when restoring session.
    public let verifyAppleCredentialsOnRestore: Bool

    /// Whether to persist the displayName in UserDefaults.
    public let persistDisplayNameInUserDefaults: Bool

    /// Default configuration.
    public static let `default` = AuthenticationConfiguration(
        serverBaseURL: nil,
        verifyAppleCredentialsOnRestore: true,
        persistDisplayNameInUserDefaults: true
    )

    public init(
        serverBaseURL: URL? = nil,
        verifyAppleCredentialsOnRestore: Bool = true,
        persistDisplayNameInUserDefaults: Bool = true
    ) {
        self.serverBaseURL = serverBaseURL
        self.verifyAppleCredentialsOnRestore = verifyAppleCredentialsOnRestore
        self.persistDisplayNameInUserDefaults = persistDisplayNameInUserDefaults
    }
}
