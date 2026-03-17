/// Estado de la sesión de autenticación del usuario.
///
/// Devuelto por ``SessionManaging/checkCredentialState()`` para indicar
/// si el usuario tiene una sesión activa y válida.
public enum CredentialState: Sendable, Equatable {
    /// El usuario tiene una sesión activa y válida.
    case authorized

    /// No hay sesión activa para este proveedor.
    case notFound

    /// Las credenciales del usuario fueron revocadas.
    ///
    /// Este caso es exclusivo del proveedor de Apple, que notifica explícitamente
    /// cuando el usuario revoca el acceso a la app desde Ajustes de iCloud.
    case revoked
}
