#if canImport(SwiftUI)
import SwiftUI

/// ViewModifier para manejar estado de autenticación.
///
/// ## Uso
/// ```swift
/// ContentView()
///     .withAuthentication(manager: authManager) {
///         LoginView()
///     }
/// ```
public struct AuthenticationViewModifier<UnauthContent: View>: ViewModifier {
    @ObservedObject private var manager: AuthenticationManager
    private let unauthContent: () -> UnauthContent

    public init(
        manager: AuthenticationManager,
        @ViewBuilder unauthContent: @escaping () -> UnauthContent
    ) {
        self.manager = manager
        self.unauthContent = unauthContent
    }

    public func body(content: Content) -> some View {
        Group {
            if manager.state.isAuthenticated {
                content
            } else {
                unauthContent()
            }
        }
        .task {
            await manager.restoreSession()
        }
    }
}

extension View {
    /// Aplica el modificador de autenticación.
    /// - Parameters:
    ///   - manager: Manager de autenticación.
    ///   - unauthContent: Vista a mostrar cuando no hay sesión.
    public func withAuthentication(
        manager: AuthenticationManager,
        @ViewBuilder unauthContent: @escaping () -> some View
    ) -> some View {
        modifier(
            AuthenticationViewModifier(
                manager: manager,
                unauthContent: unauthContent
            )
        )
    }
}
#endif
