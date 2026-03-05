#if canImport(SwiftUI) && canImport(AuthenticationServices)
import AuthenticationServices
import SwiftUI

/// The label style for an ``AppleSignInButton``.
///
/// Mirrors `SignInWithAppleButton.Label` without exposing
/// `AuthenticationServices` to callers.
public enum ARCAppleButtonLabel: Sendable {
    /// "Sign in with Apple"
    case signIn
    /// "Sign up with Apple"
    case signUp
    /// "Continue with Apple"
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
