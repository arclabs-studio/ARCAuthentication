import ARCAuthCore
import ARCLogger
import Foundation

/// Central authentication manager.
///
/// Coordinates providers, storage, and authentication state.
///
/// ## Configuration
/// ```swift
/// @main
/// struct MyApp: App {
///     @State private var authManager: AuthenticationManager = {
///         let manager = AuthenticationManager()
///         manager.register(provider: AppleAuthProvider())
///         return manager
///     }()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .environment(authManager)
///         }
///     }
/// }
/// ```
///
/// ## Usage
/// ```swift
/// // In a View
/// @Environment(AuthenticationManager.self) var authManager
///
/// Button("Sign in with Apple") {
///     Task {
///         try await authManager.authenticate(with: "apple")
///     }
/// }
/// ```
@MainActor
@Observable
public final class AuthenticationManager {
    // MARK: - Properties

    /// Current authentication state.
    public private(set) var state = AuthenticationState()

    // MARK: - Private Properties

    private var providers: [String: any AuthenticationProvider] = [:]
    private let storage: any AuthStorageProtocol
    private let configuration: AuthenticationConfiguration
    private let logger: ARCLogger

    // MARK: - Initialization

    /// Initializes the manager with default storage (Keychain).
    public init(configuration: AuthenticationConfiguration = .default) {
        storage = KeychainAuthStorage()
        self.configuration = configuration
        logger = ARCLogger(subsystem: "ARCAuthentication", category: "Manager")
    }

    /// Initializes the manager with custom storage.
    /// - Parameters:
    ///   - storage: Implementation of `AuthStorageProtocol`.
    ///   - configuration: Manager configuration.
    public init(
        storage: any AuthStorageProtocol,
        configuration: AuthenticationConfiguration = .default
    ) {
        self.storage = storage
        self.configuration = configuration
        logger = ARCLogger(subsystem: "ARCAuthentication", category: "Manager")
    }

    // MARK: - Provider Management

    /// Registers an authentication provider.
    /// - Parameter provider: Provider to register.
    public func register(provider: any AuthenticationProvider) {
        providers[provider.providerID] = provider
        logger.info("Registered provider: \(provider.providerID)")
    }

    /// Gets a registered provider.
    /// - Parameter id: Provider identifier.
    /// - Returns: Provider if it exists.
    public func provider(for id: String) -> (any AuthenticationProvider)? {
        providers[id]
    }

    /// List of available providers.
    public var availableProviders: [any AuthenticationProvider] {
        providers.values.filter(\.isAvailable).map(\.self)
    }

    // MARK: - Authentication

    /// Executes authentication with the specified provider.
    /// - Parameter providerID: Provider ID (e.g., "apple").
    /// - Throws: `AuthenticationError` if it fails.
    public func authenticate(with providerID: String) async throws {
        guard let provider = providers[providerID] else {
            throw AuthenticationError.providerNotRegistered(providerID)
        }

        state.setLoading(true)
        logger.info("Starting authentication with provider: \(providerID)")

        do {
            let credential = try await provider.authenticate()

            // Save to Keychain
            try await storage.saveCredential(credential)

            // Persist displayName in UserDefaults if configured
            if configuration.persistDisplayNameInUserDefaults,
               let displayName = credential.displayName
            {
                UserDefaults.standard.set(displayName, forKey: "auth.displayName")
            }

            // Update state
            state.setAuthenticated(with: credential)

            logger.info("Authentication successful for provider: \(providerID)")
        } catch {
            let authError = (error as? AuthenticationError) ?? .unknown(underlying: error)
            state.setError(authError)
            logger.error("Authentication failed: \(authError.localizedDescription)")
            throw authError
        }
    }

    /// Signs out the current session.
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

            // Clear UserDefaults
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

    /// Restores the session from storage.
    /// Call at app launch.
    public func restoreSession() async {
        logger.info("Attempting to restore session")

        do {
            guard let credential = try await storage.getCredential() else {
                logger.info("No stored session found")
                state.setUnauthenticated()
                return
            }

            // Verify that credentials are still valid (for Apple)
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

    /// Checks the state of the current credentials.
    public func checkCredentialState() async -> CredentialState {
        guard let credential = state.currentCredential,
              let provider = providers[credential.provider.rawValue]
        else {
            return .notFound
        }

        return await provider.checkCredentialState()
    }

    /// Gets the saved displayName (even if there is no active session).
    public var savedDisplayName: String? {
        UserDefaults.standard.string(forKey: "auth.displayName")
    }
}
