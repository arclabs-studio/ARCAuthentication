#if canImport(SwiftUI) && canImport(UIKit)
import GoogleSignIn
import SwiftUI

/// A Google Sign-In button following Google's Identity branding guidelines.
///
/// Loads the official Google "G" logo from the GoogleSignIn resource bundle at runtime.
/// Falls back to a styled placeholder if the bundle is unavailable.
///
/// **Layout spec (iOS):** 16pt leading padding · G logo · 12pt gap · centered text · 16pt trailing padding.
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

    private let label: ARCGoogleButtonLabel
    private let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Initialization

    /// Creates a Google Sign-In button.
    /// - Parameters:
    ///   - label: The text variant to display. Defaults to `.signIn`.
    ///   - action: Closure executed when the button is tapped.
    public init(label: ARCGoogleButtonLabel = .signIn, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                googleLogoTile
                    .frame(width: 20, height: 20)

                Text(label.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(foregroundColor)
                    .frame(maxWidth: .infinity)

                // Mirrors logo width so text is visually centered in the full button
                Color.clear
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        }
    }

    // MARK: - Colors (Google Identity branding guidelines)

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

    @ViewBuilder private var googleLogoTile: some View {
        if let uiImage = loadGoogleLogo() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Text("G")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.259, green: 0.522, blue: 0.957))
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
        GoogleSignInButton(label: .signIn) {}
        GoogleSignInButton(label: .signUp) {}
        GoogleSignInButton(label: .continue) {}
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Google Button - Dark") {
    VStack(spacing: 20) {
        GoogleSignInButton(label: .signIn) {}
        GoogleSignInButton(label: .signUp) {}
        GoogleSignInButton(label: .continue) {}
    }
    .padding()
    .background(.black)
    .preferredColorScheme(.dark)
}
#endif
