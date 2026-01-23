import ARCAuthCore
import Combine
import Foundation

/// Estado observable de autenticación.
///
/// Utiliza `@Published` para notificar cambios a SwiftUI automáticamente.
///
/// ## Uso en SwiftUI
/// ```swift
/// @StateObject private var authManager = AuthenticationManager()
///
/// var body: some View {
///     if authManager.state.isAuthenticated {
///         MainView()
///     } else {
///         LoginView()
///     }
/// }
/// ```
@MainActor
public final class AuthenticationState: ObservableObject, @unchecked Sendable {
    // MARK: - Published Properties

    /// Indica si hay una sesión activa.
    @Published public private(set) var isAuthenticated = false

    /// Credenciales del usuario actual (si está autenticado).
    @Published public private(set) var currentCredential: AuthCredential?

    /// Provider utilizado para la autenticación actual.
    @Published public private(set) var currentProvider: AuthProvider?

    /// Indica si hay una operación de autenticación en progreso.
    @Published public private(set) var isLoading = false

    /// Error de la última operación (si existe).
    @Published public private(set) var lastError: AuthenticationError?

    // MARK: - Initialization

    public init() {}

    // MARK: - Internal Methods

    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            lastError = nil
        }
    }

    func setAuthenticated(with credential: AuthCredential) {
        currentCredential = credential
        currentProvider = credential.provider
        isAuthenticated = true
        isLoading = false
        lastError = nil
    }

    func setUnauthenticated() {
        currentCredential = nil
        currentProvider = nil
        isAuthenticated = false
        isLoading = false
    }

    func setError(_ error: AuthenticationError) {
        lastError = error
        isLoading = false
    }

    func clearError() {
        lastError = nil
    }
}
