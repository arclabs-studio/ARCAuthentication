import Foundation

/// Constants used in the authentication system.
public enum AuthConstants {
    /// Keychain configuration.
    public enum Keychain {
        /// Service identifier for Keychain.
        public static let service = "com.arclabs.authentication"

        /// Key for storing credentials.
        public static let credentialKey = "auth.credential"

        /// Key for storing the userID.
        public static let userIDKey = "auth.user_id"
    }

    /// Token configuration.
    public enum Token {
        /// Time before expiration to consider refresh (5 minutes).
        public static let refreshThreshold: TimeInterval = 300

        /// Default access token duration (1 hour).
        public static let defaultAccessTokenDuration: TimeInterval = 3600

        /// Default refresh token duration (30 days).
        public static let defaultRefreshTokenDuration: TimeInterval = 2_592_000
    }

    /// Apple Sign In configuration.
    public enum Apple {
        /// Default requested scopes.
        public static let defaultScopes: [String] = ["fullName", "email"]

        /// Authorization code expiration time (5 minutes).
        public static let authorizationCodeExpiration: TimeInterval = 300
    }
}
