/// Tipo que puede gestionar el ciclo de vida de la sesión de autenticación.
///
/// Conforma a este protocolo para añadir capacidades de cierre de sesión y
/// verificación de estado a un proveedor de credenciales. Es independiente de
/// ``CredentialProviding`` para mantener compatibilidad con implementaciones
/// existentes que no necesiten gestión de sesión.
///
/// ## Conformidad
///
/// ``AppleCredentialProvider`` y ``GoogleCredentialProvider`` conforman a este protocolo.
/// ``MockCredentialProvider`` no lo implementa, por lo que el código de producción que
/// necesite gestión de sesión debe usar los providers concretos o crear su propio mock.
///
/// ## Ejemplo
/// ```swift
/// let provider = AppleCredentialProvider()
///
/// // Verificar estado antes de mostrar pantalla de login
/// let state = await provider.checkCredentialState()
/// if state == .authorized {
///     // El usuario ya tiene sesión activa
/// }
///
/// // Cerrar sesión
/// provider.signOut()
/// ```
public protocol SessionManaging: Sendable {
    /// Cierra la sesión activa del usuario para este proveedor.
    ///
    /// En Google, invalida la sesión en el SDK de Google Sign-In.
    /// En Apple, limpia el estado de sesión en memoria del provider.
    func signOut()

    /// Comprueba el estado actual de la sesión del usuario.
    ///
    /// - Returns: ``CredentialState/authorized`` si hay una sesión activa,
    ///   ``CredentialState/notFound`` si no hay sesión, o
    ///   ``CredentialState/revoked`` si el usuario revocó el acceso (solo Apple).
    func checkCredentialState() async -> CredentialState
}
