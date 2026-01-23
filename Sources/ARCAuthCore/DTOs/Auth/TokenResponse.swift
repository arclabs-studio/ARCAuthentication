import Foundation

/// Respuesta del servidor después de autenticación exitosa.
///
/// Contiene los tokens de sesión y la información del usuario.
public struct TokenResponse: Sendable, Codable {
    /// JWT de acceso para autenticar requests.
    public let accessToken: String

    /// Token para renovar el access token.
    public let refreshToken: String

    /// Segundos hasta que expire el access token.
    public let expiresIn: Int

    /// Tipo de token (siempre "Bearer").
    public let tokenType: String

    /// Información del usuario autenticado.
    public let user: UserDTO

    public init(
        accessToken: String,
        refreshToken: String,
        expiresIn: Int,
        tokenType: String = "Bearer",
        user: UserDTO
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = tokenType
        self.user = user
    }

    /// Calcula la fecha de expiración basada en `expiresIn`.
    public var expiresAt: Date {
        Date().addingTimeInterval(TimeInterval(expiresIn))
    }
}
