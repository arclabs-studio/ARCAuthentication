import ARCAuthCore
import Foundation

/// Protocolo para almacenamiento seguro de credenciales.
///
/// La implementación por defecto usa Keychain vía ARCStorage.
@MainActor
public protocol AuthStorageProtocol: Sendable {
    /// Guarda las credenciales de autenticación.
    func saveCredential(_ credential: AuthCredential) async throws

    /// Obtiene las credenciales almacenadas.
    func getCredential() async throws -> AuthCredential?

    /// Elimina las credenciales almacenadas.
    func deleteCredential() async throws

    /// Indica si hay credenciales almacenadas.
    func hasStoredCredential() async -> Bool
}
