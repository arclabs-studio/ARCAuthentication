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
            HStack(spacing: 0) {
                googleLogoTile
                    .frame(width: 44, height: 44)

                Text("Sign in with Google")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(foregroundColor)
                    .frame(maxWidth: .infinity)

                // Balance the logo width so text is visually centered
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        }
    }

    // MARK: - Colors (Google Identity 2024 brand guidelines)

    //
    // Light: white #FFFFFF background, #747775 border, #1F1F1F text
    // Dark:  #131314 background, #8E918F border, #E3E3E3 text
    // Source: https://developers.google.com/identity/branding-guidelines

    private var backgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 0.075, green: 0.075, blue: 0.078) // #131314
            : .white // #FFFFFF
    }

    private var foregroundColor: Color {
        colorScheme == .dark
            ? Color(red: 0.890, green: 0.890, blue: 0.890) // #E3E3E3
            : Color(red: 0.122, green: 0.122, blue: 0.122) // #1F1F1F
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color(red: 0.557, green: 0.569, blue: 0.561) // #8E918F
            : Color(red: 0.455, green: 0.467, blue: 0.459) // #747775
    }

    // MARK: - Logo

    //
    // Per Google guidelines: the "G" logo must always appear on a white tile.

    private var googleLogoTile: some View {
        ZStack {
            // White tile ensures logo visibility in all modes
            Circle()
                .fill(Color.white)
                .frame(width: 28, height: 28)

            if let uiImage = loadGoogleLogo() {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } else {
                Text("G")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(red: 0.259, green: 0.522, blue: 0.957))
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
