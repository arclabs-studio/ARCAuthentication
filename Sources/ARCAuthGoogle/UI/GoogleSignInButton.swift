#if canImport(SwiftUI) && canImport(UIKit)
import GoogleSignIn
import SwiftUI

/// A Google Sign-In button following Google's Identity branding guidelines.
///
/// Loads the official Google "G" logo from the GoogleSignIn resource bundle at runtime.
/// Falls back to a styled placeholder if the bundle is unavailable.
///
/// Logo and label are centered together as a unit, matching the visual rhythm of
/// ``AppleSignInButton``. Colours adapt automatically to light and dark mode.
///
/// ## Usage
///
/// ```swift
/// // Default — "Sign in with Google"
/// GoogleSignInButton {
///     let credential = try await provider.requestCredential()
/// }
///
/// // Sign-up variant
/// GoogleSignInButton(label: .signUp) {
///     let credential = try await provider.requestCredential()
/// }
/// ```
///
/// ## Localisation
///
/// The button ships with English and Spanish translations. At runtime it resolves
/// the visible label in two steps:
///
/// 1. **App bundle** (`Bundle.main`) — checked first. Add the key to your app's
///    `Localizable.xcstrings` (or `.strings` file) to support additional languages
///    without any changes to this package.
/// 2. **Module bundle** — fallback. Provides English (`en`) and Spanish (`es`)
///    out of the box.
///
/// The three localisation keys (one per ``ARCGoogleButtonLabel`` case) are the
/// English strings themselves — see ``ARCGoogleButtonLabel`` for the full table
/// and an example of how to add a language to your app.
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
                    .frame(width: 16, height: 16)

                Text(verbatim: resolvedTitle)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(foregroundColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.plain)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        }
    }

    // MARK: - Label resolution

    //
    // Looks up the label key in the app's main bundle first so consumers can
    // ship additional localisations without forking the package. Falls back to
    // the module bundle, which ships English and Spanish out of the box.

    private var resolvedTitle: String {
        let key = label.titleKey
        let fromMain = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        if fromMain != key {
            return fromMain
        }
        return Bundle.module.localizedString(forKey: key, value: key, table: nil)
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
