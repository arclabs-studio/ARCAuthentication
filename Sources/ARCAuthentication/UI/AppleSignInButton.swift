#if canImport(SwiftUI) && canImport(AuthenticationServices)
import AuthenticationServices
import SwiftUI

/// A thin wrapper around `SignInWithAppleButton`.
///
/// Provides a simple, configurable Sign in with Apple button that
/// delegates the action entirely to the caller.
///
/// ## Usage
/// ```swift
/// AppleSignInButton {
///     let credential = try await provider.requestCredential()
///     // Send credential to backend...
/// }
/// ```
public struct AppleSignInButton: View {
    // MARK: - Properties

    private let type: SignInWithAppleButton.Label
    private let style: SignInWithAppleButton.Style
    private let action: () -> Void

    // MARK: - Initialization

    /// Creates a Sign in with Apple button.
    /// - Parameters:
    ///   - type: Button label type (default: `.signIn`).
    ///   - style: Visual style (default: `.black`).
    ///   - action: Closure executed when the button is tapped.
    public init(
        type: SignInWithAppleButton.Label = .signIn,
        style: SignInWithAppleButton.Style = .black,
        action: @escaping () -> Void
    ) {
        self.type = type
        self.style = style
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        SignInWithAppleButton(
            type,
            onRequest: { _ in },
            onCompletion: { _ in }
        )
        .signInWithAppleButtonStyle(style)
        .frame(height: 50)
        .allowsHitTesting(false)
        .overlay {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    action()
                }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        AppleSignInButton(type: .signIn, style: .black) {}
        AppleSignInButton(type: .continue, style: .white) {}
        AppleSignInButton(type: .signUp, style: .whiteOutline) {}
    }
    .padding()
}
#endif
