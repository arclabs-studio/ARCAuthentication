import ARCAuthCore
import Foundation

/// Protocolo que define el contrato para cualquier provider de autenticación.
///
/// Implementa este protocolo para añadir nuevos métodos de autenticación
/// (ej: Google, Facebook, Email/Password, etc.).
///
/// ## Implementación
/// ```swift
/// public final class MyAuthProvider: AuthenticationProvider {
///     public let providerID: String = "my_provider"
///
///     public func authenticate() async throws -> AuthCredential {
///         // Implementación específica
///     }
/// }
/// ```
///
/// ## Thread Safety
/// Todas las implementaciones deben ser `Sendable` y thread-safe.
@MainActor
public protocol AuthenticationProvider: Sendable {
    /// Identificador único del provider (ej: "apple", "google", "email").
    var providerID: String { get }

    /// Nombre para mostrar en UI.
    var displayName: String { get }

    /// Indica si el provider está disponible en el dispositivo actual.
    var isAvailable: Bool { get }

    /// Ejecuta el flujo de autenticación.
    /// - Returns: Credenciales del usuario autenticado.
    /// - Throws: `AuthenticationError` si la autenticación falla.
    func authenticate() async throws -> AuthCredential

    /// Cierra la sesión del provider.
    func signOut() async throws

    /// Verifica si hay una sesión activa válida.
    func checkCredentialState() async -> CredentialState
}

// MARK: - Default Implementations

extension AuthenticationProvider {
    public var displayName: String { providerID.capitalized }
    public var isAvailable: Bool { true }

    public func signOut() async throws {
        // Default: no-op (muchos providers no requieren sign out explícito)
    }
}

// MARK: - Credential State

/// Estado de las credenciales del usuario.
public enum CredentialState: Sendable, Equatable {
    /// Credenciales válidas y autorizadas.
    case authorized
    /// Credenciales revocadas por el usuario.
    case revoked
    /// No se encontraron credenciales.
    case notFound
    /// Estado de credencial transferido desde otro dispositivo.
    case transferred
}
