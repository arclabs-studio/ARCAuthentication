#if canImport(SwiftUI) && canImport(AuthenticationServices)
import ARCAuthCore
import AuthenticationServices
import SwiftUI

/// Botón de Sign in with Apple siguiendo Human Interface Guidelines.
///
/// Wrapper de SwiftUI sobre `SignInWithAppleButton` con estilos adicionales.
///
/// ## Uso
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

    /// Crea un botón de Sign in with Apple.
    /// - Parameters:
    ///   - type: Tipo de botón (signIn, signUp, continue).
    ///   - style: Estilo visual (black, white, whiteOutline).
    ///   - cornerRadius: Radio de esquinas (default: 8).
    ///   - onRequest: Closure ejecutado al tocar el botón.
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

        // Determinar el color del tint basado en el estilo
        // .black usa tint blanco, .white y .whiteOutline usan tint negro
        var isBlack = true
        if #available(iOS 14.0, *) {
            // Usamos reflexión para determinar el estilo ya que no es Equatable
            let styleDescription = String(describing: style)
            isBlack = styleDescription.contains("black")
        }
        useWhiteTint = isBlack
    }

    // MARK: - Body

    public var body: some View {
        Button {
            performAuthentication()
        } label: {
            SignInWithAppleButton(
                type,
                onRequest: { _ in
                    // No usamos el handler de request
                },
                onCompletion: { _ in
                    // No usamos el handler de completion
                }
            )
            .signInWithAppleButtonStyle(style)
            .frame(height: 50)
            .cornerRadius(cornerRadius)
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
                    // No mostrar error si el usuario canceló
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
