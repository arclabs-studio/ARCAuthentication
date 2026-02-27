import ARCAuthCore
import Foundation

/// Observable authentication state.
///
/// Uses `@Observable` macro for automatic SwiftUI tracking.
///
/// ## Usage in SwiftUI
/// ```swift
/// @State private var authManager = AuthenticationManager()
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
@Observable
public final class AuthenticationState {
    // MARK: - Properties

    /// Whether there is an active session.
    public private(set) var isAuthenticated = false

    /// Current user credentials (if authenticated).
    public private(set) var currentCredential: AuthCredential?

    /// Provider used for the current authentication.
    public private(set) var currentProvider: AuthProvider?

    /// Whether an authentication operation is in progress.
    public private(set) var isLoading = false

    /// Error from the last operation (if any).
    public private(set) var lastError: AuthenticationError?

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
