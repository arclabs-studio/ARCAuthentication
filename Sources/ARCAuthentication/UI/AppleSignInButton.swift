#if canImport(SwiftUI) && canImport(AuthenticationServices)
import AuthenticationServices
import SwiftUI

/// A thin wrapper around `SignInWithAppleButton` with adaptive dark/light style support.
///
/// When no style is provided the button automatically selects `.black` in light mode
/// and `.white` in dark mode, using `@Environment(\.colorScheme)` — unlike
/// `UITraitCollection.current` this reacts to runtime appearance changes.
///
/// ## Usage
/// ```swift
/// // Adaptive (recommended)
/// AppleSignInButton {
///     let credential = try await provider.requestCredential()
/// }
///
/// // Fixed style
/// AppleSignInButton(style: .whiteOutline) { ... }
/// ```
public struct AppleSignInButton: View {
    // MARK: - Properties

    private let type: SignInWithAppleButton.Label
    private let style: SignInWithAppleButton.Style?
    private let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Initialization

    /// Creates an adaptive Sign in with Apple button.
    /// - Parameters:
    ///   - type: Button label type (default: `.signIn`).
    ///   - action: Closure executed when the button is tapped.
    public init(type: SignInWithAppleButton.Label = .signIn,
                action: @escaping () -> Void) {
        self.type = type
        style = nil
        self.action = action
    }

    /// Creates a Sign in with Apple button with a fixed style.
    /// - Parameters:
    ///   - type: Button label type (default: `.signIn`).
    ///   - style: Visual style.
    ///   - action: Closure executed when the button is tapped.
    public init(type: SignInWithAppleButton.Label = .signIn,
                style: SignInWithAppleButton.Style,
                action: @escaping () -> Void) {
        self.type = type
        self.style = style
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        SignInWithAppleButton(type,
                              onRequest: { _ in },
                              onCompletion: { _ in })
            .signInWithAppleButtonStyle(resolvedStyle)
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

    // MARK: - Private

    private var resolvedStyle: SignInWithAppleButton.Style {
        style ?? (colorScheme == .dark ? .white : .black)
    }
}

// MARK: - Preview

#Preview("Adaptive") {
    VStack(spacing: 20) {
        AppleSignInButton(type: .signIn) {}
        AppleSignInButton(type: .signUp) {}
        AppleSignInButton(type: .continue) {}
    }
    .padding()
}

#Preview("Fixed styles") {
    VStack(spacing: 20) {
        AppleSignInButton(type: .signIn, style: .black) {}
        AppleSignInButton(type: .signIn, style: .white) {}
        AppleSignInButton(type: .signIn, style: .whiteOutline) {}
    }
    .padding()
    .background(.gray)
}
#endif
