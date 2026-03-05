#if canImport(SwiftUI) && canImport(UIKit)
import GoogleSignIn
import SwiftUI

/// A Google Sign-In button with centered content following Google's branding guidelines.
///
/// Loads the official Google "G" logo from the GoogleSignIn resource bundle at runtime.
/// Falls back to a styled placeholder if the bundle is unavailable.
///
/// ## Usage
/// ```swift
/// GoogleSignInButton {
///     let credential = try await provider.requestCredential()
///     // Send credential to backend...
/// }
/// ```
public struct GoogleSignInButton: View {
    // MARK: - Properties

    private let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Initialization

    /// Creates a Google Sign-In button.
    /// - Parameter action: Closure executed when the button is tapped.
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Spacer(minLength: 0)
                googleLogo
                    .frame(width: 18, height: 18)
                Text("Sign in with Google")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(foregroundColor)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0 : 0.15), radius: 1, x: 0, y: 2)
        .overlay {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(.white.opacity(0.24), lineWidth: 1)
            }
        }
    }

    // MARK: - Private

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0.259, green: 0.522, blue: 0.957) : .white
    }

    private var foregroundColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.235, green: 0.251, blue: 0.263)
    }

    @ViewBuilder private var googleLogo: some View {
        if let uiImage = loadGoogleLogo() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(Color(red: 0.259, green: 0.522, blue: 0.957))
                .overlay {
                    Text("G")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
        }
    }

    private func loadGoogleLogo() -> UIImage? {
        let bundles: [Bundle] = [.main, Bundle(for: GIDSignIn.self)]
        for bundle in bundles {
            if let path = bundle.path(forResource: "GoogleSignIn_GoogleSignIn", ofType: "bundle"),
               let resourceBundle = Bundle(path: path),
               let iconPath = resourceBundle.path(forResource: "google", ofType: "png") {
                return UIImage(contentsOfFile: iconPath)
            }
        }
        return nil
    }
}

// MARK: - Preview

#Preview("Google Button - Light") {
    VStack(spacing: 20) {
        GoogleSignInButton {}
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Google Button - Dark") {
    VStack(spacing: 20) {
        GoogleSignInButton {}
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
}
#endif
