import Foundation

/// Constantes utilizadas en el sistema de autenticación.
public enum AuthConstants {
    /// Configuración del Keychain.
    public enum Keychain {
        /// Service identifier para el Keychain.
        public static let service = "com.arclabs.authentication"

        /// Key para almacenar credenciales.
        public static let credentialKey = "auth.credential"

        /// Key para almacenar el userID.
        public static let userIDKey = "auth.user_id"
    }

    /// Configuración de tokens.
    public enum Token {
        /// Tiempo antes de expiración para considerar refresh (5 minutos).
        public static let refreshThreshold: TimeInterval = 300

        /// Duración por defecto del access token (1 hora).
        public static let defaultAccessTokenDuration: TimeInterval = 3600

        /// Duración por defecto del refresh token (30 días).
        public static let defaultRefreshTokenDuration: TimeInterval = 2_592_000
    }

    /// Configuración de Apple Sign In.
    public enum Apple {
        /// Scopes solicitados por defecto.
        public static let defaultScopes: [String] = ["fullName", "email"]

        /// Tiempo de expiración del authorization code (5 minutos).
        public static let authorizationCodeExpiration: TimeInterval = 300
    }
}
