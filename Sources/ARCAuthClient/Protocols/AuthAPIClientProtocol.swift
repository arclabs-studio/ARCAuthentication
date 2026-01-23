import ARCAuthCore
import Foundation

/// Protocolo para comunicación con el backend de autenticación.
@MainActor
public protocol AuthAPIClientProtocol: Sendable {
    /// Envía las credenciales de Apple al servidor para verificación.
    /// - Parameter payload: Payload de autenticación de Apple.
    /// - Returns: Respuesta con tokens del servidor.
    func verifyAppleCredential(_ payload: AppleAuthPayload) async throws -> TokenResponse

    /// Renueva el access token usando el refresh token.
    /// - Parameter request: Request con el refresh token.
    /// - Returns: Nueva respuesta con tokens.
    func refreshToken(_ request: RefreshTokenRequest) async throws -> TokenResponse

    /// Cierra la sesión en el servidor.
    /// - Parameter accessToken: Token de acceso actual.
    func signOut(accessToken: String) async throws
}
