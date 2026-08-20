#if canImport(SwiftUI)

/// The label style for a ``GoogleSignInButton``.
///
/// Google Identity branding guidelines allow exactly three button texts.
/// Each case maps to one of the three approved strings.
///
/// ## Localisation
///
/// The package ships English and Spanish translations out of the box.
/// To support additional languages, add the corresponding keys to your app's
/// `Localizable.xcstrings` (or `Localizable.strings`). The button resolves
/// the label from the app bundle first, falling back to the module bundle.
///
/// | Case | Localisation key |
/// | ---- | ---------------- |
/// | `.signIn` | `"Sign in with Google"` |
/// | `.signUp` | `"Sign up with Google"` |
/// | `.continue` | `"Continue with Google"` |
///
/// **Example — adding German to your app:**
/// ```
/// // In your app's Localizable.xcstrings (de localisation):
/// "Sign in with Google"  → "Mit Google anmelden"
/// "Sign up with Google"  → "Mit Google registrieren"
/// "Continue with Google" → "Mit Google fortfahren"
/// ```
public enum ARCGoogleButtonLabel: Sendable {
    /// Renders "Sign in with Google" (localised).
    case signIn
    /// Renders "Sign up with Google" (localised).
    case signUp
    /// Renders "Continue with Google" (localised).
    case `continue`

    // MARK: - Internal

    /// The English string that doubles as the localisation key.
    ///
    /// ``GoogleSignInButton`` looks this key up in `Bundle.main` first (app overrides),
    /// then falls back to the module bundle (built-in en/es translations).
    var titleKey: String {
        switch self {
        case .signIn: "Sign in with Google"
        case .signUp: "Sign up with Google"
        case .continue: "Continue with Google"
        }
    }
}
#endif
