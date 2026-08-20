import Foundation

/// The current state of the authentication flow.
///
/// Generic over `UserType` so consumers can use their own user model
/// (e.g., a Firebase `User` or a custom profile struct).
///
/// ## Usage
/// ```swift
/// @State var authState: AuthenticationState<MyUser> = .unauthenticated
///
/// switch authState {
/// case .unauthenticated:
///     LoginView()
/// case .authenticating:
///     ProgressView()
/// case .authenticated(let user):
///     HomeView(user: user)
/// case .error(let error):
///     ErrorView(error: error)
/// }
/// ```
public enum AuthenticationState<UserType: Sendable>: Sendable {
    /// No user is signed in.
    case unauthenticated

    /// Authentication is in progress.
    case authenticating

    /// A user is signed in.
    case authenticated(UserType)

    /// Authentication failed with an error.
    case error(AuthenticationError)
}
