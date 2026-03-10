#if canImport(SwiftUI) && canImport(AuthenticationServices)
import AuthenticationServices
import SwiftUI

/// The label style for an ``AppleSignInButton``.
///
/// Mirrors `SignInWithAppleButton.Label` without exposing
/// `AuthenticationServices` to callers.
///
/// ## Localisation
///
/// No action needed. `AuthenticationServices` translates the button text
/// automatically into the device language across all iOS-supported locales.
public enum ARCAppleButtonLabel: Sendable {
    /// "Sign in with Apple" (localised automatically by the system).
    case signIn
    /// "Sign up with Apple" (localised automatically by the system).
    case signUp
    /// "Continue with Apple" (localised automatically by the system).
    case `continue`

    // MARK: - Internal

    var nativeLabel: SignInWithAppleButton.Label {
        switch self {
        case .signIn: .signIn
        case .signUp: .signUp
        case .continue: .continue
        }
    }
}
#endif
