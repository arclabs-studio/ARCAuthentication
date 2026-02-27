#if canImport(SwiftUI) && canImport(AuthenticationServices)
import ARCAuthCore
import AuthenticationServices
import SwiftUI

/// Sign in with Apple button following Human Interface Guidelines.
///
/// SwiftUI wrapper over `SignInWithAppleButton` with additional styles.
///
/// ## Usage
/// ```swift
/// AppleSignInButton {
///     try await authManager.authenticate(with: "apple")
/// }
/// ```
public struct AppleSignInButton: View {
    // MARK: - Properties

    private let type: SignInWithAppleButton.Label
    private let style: SignInWithAppleButton.Style
    private let cornerRadius: CGFloat
    private let onRequest: () async throws -> Void

    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let useWhiteTint: Bool

    // MARK: - Initialization

    /// Creates a Sign in with Apple button.
    /// - Parameters:
    ///   - type: Button type (signIn, signUp, continue).
    ///   - style: Visual style (black, white, whiteOutline).
    ///   - cornerRadius: Corner radius (default: 8).
    ///   - onRequest: Closure executed when the button is tapped.
    public init(
        type: SignInWithAppleButton.Label = .signIn,
        style: SignInWithAppleButton.Style = .black,
        cornerRadius: CGFloat = 8,
        onRequest: @escaping () async throws -> Void
    ) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
        self.onRequest = onRequest

        // Determine tint color based on the style
        // .black uses white tint, .white and .whiteOutline use black tint
        let styleDescription = String(describing: style)
        useWhiteTint = styleDescription.contains("black")
    }

    // MARK: - Body

    public var body: some View {
        Button {
            performAuthentication()
        } label: {
            SignInWithAppleButton(
                type,
                onRequest: { _ in },
                onCompletion: { _ in }
            )
            .signInWithAppleButtonStyle(style)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .allowsHitTesting(false)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(useWhiteTint ? .white : .black)
            }
        }
        .alert(
            "Authentication Error",
            isPresented: $showError,
            actions: {
                Button("OK") {}
            },
            message: {
                Text(errorMessage)
            }
        )
    }

    // MARK: - Private Methods

    private func performAuthentication() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await onRequest()
            } catch let error as AuthenticationError {
                if case .userCancelled = error {
                    // Don't show error if the user cancelled
                    return
                }
                errorMessage = error.localizedDescription
                showError = true
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        AppleSignInButton(type: .signIn, style: .black) {
            // Preview action
        }

        AppleSignInButton(type: .continue, style: .white) {
            // Preview action
        }

        AppleSignInButton(type: .signUp, style: .whiteOutline) {
            // Preview action
        }
    }
    .padding()
}
#endif
