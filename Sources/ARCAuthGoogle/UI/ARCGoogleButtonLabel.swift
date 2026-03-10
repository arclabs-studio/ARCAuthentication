#if canImport(SwiftUI)

/// The label style for a ``GoogleSignInButton``.
///
/// Google Identity branding guidelines allow exactly three button texts.
/// Each case maps to the corresponding approved string.
public enum ARCGoogleButtonLabel: Sendable {
    /// "Sign in with Google"
    case signIn
    /// "Sign up with Google"
    case signUp
    /// "Continue with Google"
    case `continue`

    // MARK: - Internal

    var title: String {
        switch self {
        case .signIn: "Sign in with Google"
        case .signUp: "Sign up with Google"
        case .continue: "Continue with Google"
        }
    }
}
#endif
