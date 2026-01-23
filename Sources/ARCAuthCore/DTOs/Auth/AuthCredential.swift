import Foundation

/// Representa las credenciales de un usuario autenticado.
///
/// Esta estructura es el resultado de cualquier autenticación exitosa,
/// independientemente del provider utilizado (Apple, Google, Email, etc.).
///
/// ## Uso
/// ```swift
/// let credential = AuthCredential(
///     userID: "001234.abc...",
///     email: "user@example.com",
///     displayName: "John Doe",
///     provider: .apple,
///     identityToken: tokenData,
///     authorizationCode: codeData
/// )
/// ```
///
/// ## Importante
/// - `email` y `displayName` solo se proporcionan en el **primer** Sign in with Apple
/// - Almacena estos valores inmediatamente ya que Apple no los envía de nuevo
/// - `identityToken` es un JWT que debe enviarse al backend para verificación
public struct AuthCredential: Sendable, Codable, Equatable, Hashable, Identifiable {
    // MARK: - Properties

    /// Identificador único para conformidad con Identifiable.
    public var id: String { userID }

    /// Identificador único del usuario proporcionado por el provider.
    /// Para SIWA: string opaco de ~44 caracteres que persiste entre sesiones.
    public let userID: String

    /// Email del usuario (puede ser relay de Apple: xxx@privaterelay.appleid.com).
    /// Solo disponible en el primer Sign in with Apple.
    public let email: String?

    /// Nombre para mostrar del usuario.
    /// Solo disponible en el primer Sign in with Apple.
    public let displayName: String?

    /// URL de la imagen de perfil (si está disponible).
    public let profileImageURL: URL?

    /// Provider de autenticación utilizado.
    public let provider: AuthProvider

    /// JWT que contiene información verificable del usuario.
    /// Debe enviarse al backend para validación.
    public let identityToken: Data?

    /// Código de autorización para intercambio server-to-server con Apple.
    /// Solo válido por 5 minutos.
    public let authorizationCode: Data?

    /// Tokens de acceso del servidor (se llenan después de verificación con backend).
    public var serverTokens: ServerTokens?

    /// Fecha de creación de la credencial.
    public let createdAt: Date

    // MARK: - Initialization

    public init(
        userID: String,
        email: String? = nil,
        displayName: String? = nil,
        profileImageURL: URL? = nil,
        provider: AuthProvider,
        identityToken: Data? = nil,
        authorizationCode: Data? = nil,
        serverTokens: ServerTokens? = nil,
        createdAt: Date = Date()
    ) {
        self.userID = userID
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.provider = provider
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.serverTokens = serverTokens
        self.createdAt = createdAt
    }
}

// MARK: - Supporting Types

/// Providers de autenticación soportados.
public enum AuthProvider: String, Sendable, Codable, CaseIterable {
    case apple
    case google
    case email

    public var displayName: String {
        switch self {
        case .apple: "Apple"
        case .google: "Google"
        case .email: "Email"
        }
    }
}

/// Tokens proporcionados por el servidor backend.
public struct ServerTokens: Sendable, Codable, Equatable, Hashable {
    /// JWT de acceso de corta duración (15-60 min).
    public let accessToken: String

    /// Token de refresh de larga duración (30 días).
    public let refreshToken: String

    /// Fecha de expiración del access token.
    public let expiresAt: Date

    public init(accessToken: String, refreshToken: String, expiresAt: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }

    /// Indica si el access token ha expirado.
    public var isExpired: Bool {
        Date() >= expiresAt
    }

    /// Indica si el token expirará pronto (dentro de 5 minutos).
    public var willExpireSoon: Bool {
        Date().addingTimeInterval(300) >= expiresAt
    }
}
