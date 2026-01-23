import ARCAuthCore
import ARCLogger
import Combine
import Foundation

/// Manager central de autenticación.
///
/// Coordina providers, storage y estado de autenticación.
///
/// ## Configuración
/// ```swift
/// @main
/// struct MyApp: App {
///     @StateObject private var authManager: AuthenticationManager = {
///         let manager = AuthenticationManager()
///         manager.register(provider: AppleAuthProvider())
///         return manager
///     }()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environmentObject(authManager)
///         }
///     }
/// }
/// ```
///
/// ## Uso
/// ```swift
/// // En una View
/// @EnvironmentObject var authManager: AuthenticationManager
///
/// Button("Sign in with Apple") {
///     Task {
///         try await authManager.authenticate(with: "apple")
///     }
/// }
/// ```
@MainActor
public final class AuthenticationManager: ObservableObject {
    // MARK: - Published Properties

    /// Estado actual de autenticación.
    @Published public private(set) var state = AuthenticationState()

    // MARK: - Private Properties

    private var providers: [String: any AuthenticationProvider] = [:]
    private let storage: any AuthStorageProtocol
    private let configuration: AuthenticationConfiguration
    private let logger: ARCLogger

    // MARK: - Initialization

    /// Inicializa el manager con storage por defecto (Keychain).
    public init(configuration: AuthenticationConfiguration = .default) {
        storage = KeychainAuthStorage()
        self.configuration = configuration
        logger = ARCLogger(subsystem: "ARCAuthentication", category: "Manager")
    }

    /// Inicializa el manager con storage custom.
    /// - Parameters:
    ///   - storage: Implementación de `AuthStorageProtocol`.
    ///   - configuration: Configuración del manager.
    public init(
        storage: any AuthStorageProtocol,
        configuration: AuthenticationConfiguration = .default
    ) {
        self.storage = storage
        self.configuration = configuration
        logger = ARCLogger(subsystem: "ARCAuthentication", category: "Manager")
    }

    // MARK: - Provider Management

    /// Registra un provider de autenticación.
    /// - Parameter provider: Provider a registrar.
    public func register(provider: any AuthenticationProvider) {
        providers[provider.providerID] = provider
        logger.info("Registered provider: \(provider.providerID)")
    }

    /// Obtiene un provider registrado.
    /// - Parameter id: Identificador del provider.
    /// - Returns: Provider si existe.
    public func provider(for id: String) -> (any AuthenticationProvider)? {
        providers[id]
    }

    /// Lista de providers disponibles.
    public var availableProviders: [any AuthenticationProvider] {
        providers.values.filter(\.isAvailable).map(\.self)
    }

    // MARK: - Authentication

    /// Ejecuta autenticación con el provider especificado.
    /// - Parameter providerID: ID del provider (ej: "apple").
    /// - Throws: `AuthenticationError` si falla.
    public func authenticate(with providerID: String) async throws {
        guard let provider = providers[providerID] else {
            throw AuthenticationError.providerNotRegistered(providerID)
        }

        state.setLoading(true)
        logger.info("Starting authentication with provider: \(providerID)")

        do {
            let credential = try await provider.authenticate()

            // Guardar en Keychain
            try await storage.saveCredential(credential)

            // Persistir displayName en UserDefaults si está configurado
            if configuration.persistDisplayNameInUserDefaults,
               let displayName = credential.displayName
            {
                UserDefaults.standard.set(displayName, forKey: "auth.displayName")
            }

            // Actualizar estado
            state.setAuthenticated(with: credential)

            logger.info("Authentication successful for provider: \(providerID)")
        } catch {
            let authError = (error as? AuthenticationError) ?? .unknown(underlying: error)
            state.setError(authError)
            logger.error("Authentication failed: \(authError.localizedDescription)")
            throw authError
        }
    }

    /// Cierra la sesión actual.
    public func signOut() async throws {
        guard let provider = state.currentProvider,
              let authProvider = providers[provider.rawValue]
        else {
            state.setUnauthenticated()
            try await storage.deleteCredential()
            return
        }

        state.setLoading(true)

        do {
            try await authProvider.signOut()
            try await storage.deleteCredential()

            // Limpiar UserDefaults
            UserDefaults.standard.removeObject(forKey: "auth.displayName")

            state.setUnauthenticated()
            logger.info("Sign out successful")
        } catch {
            let authError = (error as? AuthenticationError) ?? .unknown(underlying: error)
            state.setError(authError)
            logger.error("Sign out failed: \(authError.localizedDescription)")
            throw authError
        }
    }

    /// Restaura la sesión desde el almacenamiento.
    /// Llamar al inicio de la app.
    public func restoreSession() async {
        logger.info("Attempting to restore session")

        do {
            guard let credential = try await storage.getCredential() else {
                logger.info("No stored session found")
                state.setUnauthenticated()
                return
            }

            // Verificar que las credenciales siguen siendo válidas (para Apple)
            if configuration.verifyAppleCredentialsOnRestore,
               credential.provider == .apple
            {
                #if canImport(AuthenticationServices) && canImport(UIKit)
                if let appleProvider = providers[AuthProvider.apple.rawValue] as? AppleAuthProvider {
                    let credentialState = await appleProvider.checkCredentialState(for: credential.userID)

                    guard credentialState == .authorized else {
                        logger.warning("Apple credentials revoked or not found")
                        try await storage.deleteCredential()
                        state.setUnauthenticated()
                        return
                    }
                }
                #endif
            }

            state.setAuthenticated(with: credential)
            logger.info("Session restored successfully")
        } catch {
            logger.error("Failed to restore session: \(error.localizedDescription)")
            state.setUnauthenticated()
        }
    }

    /// Verifica el estado de las credenciales actuales.
    public func checkCredentialState() async -> CredentialState {
        guard let credential = state.currentCredential,
              let provider = providers[credential.provider.rawValue]
        else {
            return .notFound
        }

        return await provider.checkCredentialState()
    }

    /// Obtiene el displayName guardado (incluso si no hay sesión activa).
    public var savedDisplayName: String? {
        UserDefaults.standard.string(forKey: "auth.displayName")
    }
}
