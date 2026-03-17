import ARCStorage

// MARK: - AuthCredentialRecord (internal)

/// Adaptador Codable+Identifiable para `KeychainRepository`.
///
/// Almacena una única credencial de autenticación con un identificador fijo ("current"),
/// de modo que cada instancia de `KeychainAuthStorage` mantiene exactamente un registro.
private struct AuthCredentialRecord: Codable, Sendable, Identifiable {
    /// Identificador fijo del registro único por instancia de almacén.
    let id: String
    /// La credencial de autenticación serializada.
    let credential: AuthCredential
}

// MARK: - KeychainAuthStorage

/// Almacén seguro de ``AuthCredential`` en el Keychain del dispositivo.
///
/// Usa `KeychainRepository` de ARCStorage internamente para persistir la credencial
/// del usuario de forma cifrada. Admite un Keychain Access Group para compartir la sesión
/// entre varias apps del mismo Team ID (SSO sin backend).
///
/// ## Uso básico
/// ```swift
/// let storage = KeychainAuthStorage()
/// try await storage.save(credential)
/// let saved = try await storage.load()
/// try await storage.delete()
/// ```
///
/// ## Shared Keychain SSO
/// ```swift
/// let storage = KeychainAuthStorage(accessGroup: AuthConstants.Keychain.sharedAccessGroup)
/// try await storage.save(credential)
/// // FavRes, FavBook y FavPrint pueden leer la misma credencial
/// ```
///
/// - Note: La accesibilidad está fijada a `.whenUnlockedThisDeviceOnly` para mayor seguridad.
///   Los elementos no se migran a nuevos dispositivos ni se sincronizan con iCloud Backup.
public struct KeychainAuthStorage: Sendable {
    // MARK: - Private

    private static let service = "com.arclabs.arcauthentication"
    private static let recordID = "current"

    private let repository: KeychainRepository<AuthCredentialRecord>

    // MARK: - Initialization

    /// Crea un almacén en el Keychain del dispositivo, sin Access Group.
    ///
    /// Usa este init para almacenamiento local en una única app.
    public init() {
        repository = KeychainRepository<AuthCredentialRecord>(service: Self.service,
                                                              accessGroup: nil,
                                                              accessibility: .whenUnlockedThisDeviceOnly)
    }

    /// Crea un almacén compartido entre apps mediante un Keychain Access Group.
    ///
    /// Todas las apps del mismo Team ID que usen el mismo `accessGroup` podrán
    /// leer y escribir la credencial, habilitando SSO sin backend propio.
    ///
    /// - Parameter accessGroup: Identificador del grupo de acceso compartido.
    ///   Usa ``AuthConstants/Keychain/sharedAccessGroup`` o define tu propio grupo.
    ///
    /// - Precondition: Cada app debe tener activada la capability **Keychain Sharing**
    ///   en Xcode con el mismo `accessGroup`.
    public init(accessGroup: String) {
        repository = KeychainRepository<AuthCredentialRecord>(service: Self.service,
                                                              accessGroup: accessGroup,
                                                              accessibility: .whenUnlockedThisDeviceOnly)
    }

    // MARK: - Operations

    /// Guarda una credencial en el Keychain, sobreescribiendo la existente si la hay.
    ///
    /// - Parameter credential: La credencial a persisir.
    /// - Throws: ``AuthenticationError/systemError(_:)`` si el Keychain rechaza la operación.
    public func save(_ credential: AuthCredential) async throws {
        let record = AuthCredentialRecord(id: Self.recordID, credential: credential)
        do {
            try await repository.save(record)
        } catch {
            throw AuthenticationError.systemError("KeychainAuthStorage save failed: \(error.localizedDescription)")
        }
    }

    /// Recupera la credencial guardada.
    ///
    /// - Returns: La credencial almacenada, o `nil` si no hay ninguna.
    /// - Throws: ``AuthenticationError/systemError(_:)`` si el Keychain rechaza la lectura.
    public func load() async throws -> AuthCredential? {
        do {
            let record = try await repository.fetch(id: Self.recordID)
            return record?.credential
        } catch {
            throw AuthenticationError.systemError("KeychainAuthStorage load failed: \(error.localizedDescription)")
        }
    }

    /// Elimina la credencial del Keychain.
    ///
    /// No lanza error si no hay ninguna credencial guardada.
    /// - Throws: ``AuthenticationError/systemError(_:)`` si el Keychain rechaza la eliminación.
    public func delete() async throws {
        do {
            try await repository.delete(id: Self.recordID)
        } catch {
            // Si no hay nada guardado, no es un error desde la perspectiva del caller.
            // StorageError.entityNotFound se ignora silenciosamente.
            let description = error.localizedDescription.lowercased()
            if description.contains("not found") || description.contains("notfound") {
                return
            }
            throw AuthenticationError.systemError("KeychainAuthStorage delete failed: \(error.localizedDescription)")
        }
    }
}
