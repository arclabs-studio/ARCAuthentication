#if canImport(SwiftUI)
import SwiftUI

/// ViewModifier to handle authentication state.
///
/// ## Usage
/// ```swift
/// ContentView()
///     .withAuthentication(manager: authManager) {
///         LoginView()
///     }
/// ```
public struct AuthenticationViewModifier<UnauthContent: View>: ViewModifier {
    private let manager: AuthenticationManager
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
    /// Applies the authentication modifier.
    /// - Parameters:
    ///   - manager: Authentication manager.
    ///   - unauthContent: View to show when there is no session.
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
