import ARCAuthCore
import ARCStorage
import Foundation

/// Implementación de almacenamiento de credenciales usando Keychain.
///
/// Utiliza `KeychainRepository` de ARCStorage para el acceso seguro a Keychain.
///
/// ## Nivel de Seguridad
/// Usa `.whenUnlockedThisDeviceOnly` por defecto:
/// - Solo accesible cuando el dispositivo está desbloqueado
/// - NO se sincroniza a otros dispositivos (seguridad)
/// - Las credenciales se eliminan si se borra la app
///
/// ## Uso
/// ```swift
/// let storage = KeychainAuthStorage()
/// try await storage.saveCredential(credential)
/// let restored = try await storage.getCredential()
/// ```
@MainActor
public final class KeychainAuthStorage: AuthStorageProtocol {
    // MARK: - Properties

    private let repository: KeychainRepository<AuthCredential>

    // MARK: - Initialization

    /// Inicializa el storage con el nivel de seguridad por defecto.
    public init() {
        repository = KeychainRepository<AuthCredential>(
            service: AuthConstants.Keychain.service,
            accessibility: .whenUnlockedThisDeviceOnly
        )
    }

    /// Inicializa el storage con un nivel de seguridad personalizado.
    /// - Parameter accessibility: Nivel de accesibilidad del Keychain.
    public init(accessibility: KeychainAccessibility) {
        repository = KeychainRepository<AuthCredential>(
            service: AuthConstants.Keychain.service,
            accessibility: accessibility
        )
    }

    /// Inicializa el storage con un repository custom (útil para testing).
    /// - Parameter repository: Repository a utilizar.
    init(repository: KeychainRepository<AuthCredential>) {
        self.repository = repository
    }

    // MARK: - AuthStorageProtocol

    public func saveCredential(_ credential: AuthCredential) async throws {
        do {
            // Primero eliminamos cualquier credencial existente
            let existing = try await repository.fetchAll()
            for old in existing {
                try await repository.delete(id: old.id)
            }
            // Guardamos la nueva credencial
            try await repository.save(credential)
        } catch {
            throw AuthenticationError.storageSaveFailed(underlying: error)
        }
    }

    public func getCredential() async throws -> AuthCredential? {
        do {
            let credentials = try await repository.fetchAll()
            return credentials.first
        } catch {
            // Si no existe, retornar nil en lugar de error
            return nil
        }
    }

    public func deleteCredential() async throws {
        do {
            let credentials = try await repository.fetchAll()
            for credential in credentials {
                try await repository.delete(id: credential.id)
            }
        } catch {
            throw AuthenticationError.storageDeleteFailed(underlying: error)
        }
    }

    public func hasStoredCredential() async -> Bool {
        do {
            let credentials = try await repository.fetchAll()
            return !credentials.isEmpty
        } catch {
            return false
        }
    }
}
