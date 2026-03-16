import Foundation

/// A credential obtained from an authentication provider.
///
/// Each case wraps a provider-specific credential containing the identity
/// token and metadata needed by your backend to verify the user.
///
/// ## Usage
/// ```swift
/// let credential = try await provider.requestCredential()
/// switch credential {
/// case .apple(let apple):
///     print(apple.userIdentifier)
/// case .google(let google):
///     print(google.idToken)
/// }
/// ```
public enum AuthCredential: Sendable, Equatable, Codable {
    /// Credential from Sign in with Apple.
    case apple(AppleCredential)

    /// Credential from Google Sign-In.
    case google(GoogleCredential)
}

/// Credential obtained from Sign in with Apple.
///
/// Contains the identity token, authorization code, and optional user
/// information returned by `ASAuthorizationAppleIDCredential`.
///
/// - Note: `fullName` and `email` are only provided on the **first** sign-in.
///   Store them immediately if needed.
public struct AppleCredential: Sendable, Equatable, Codable {
    /// The JSON Web Token used for identity verification.
    public let identityToken: Data

    /// The short-lived authorization code for server-side validation.
    public let authorizationCode: Data

    /// The raw nonce used in the authorization request.
    public let nonce: String

    /// The user's name components, if provided.
    public let fullName: PersonNameComponents?

    /// The user's email address, if provided.
    public let email: String?

    /// The stable, unique Apple user identifier.
    public let userIdentifier: String

    /// Creates an Apple credential.
    /// - Parameters:
    ///   - identityToken: The identity JWT data.
    ///   - authorizationCode: The authorization code data.
    ///   - nonce: The raw nonce string used in the request.
    ///   - fullName: Optional name components.
    ///   - email: Optional email address.
    ///   - userIdentifier: The stable Apple user ID.
    public init(identityToken: Data,
                authorizationCode: Data,
                nonce: String,
                fullName: PersonNameComponents? = nil,
                email: String? = nil,
                userIdentifier: String) {
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.nonce = nonce
        self.fullName = fullName
        self.email = email
        self.userIdentifier = userIdentifier
    }

    /// A mock credential for testing.
    public static let mock = AppleCredential(identityToken: Data("mock-identity-token".utf8),
                                             authorizationCode: Data("mock-auth-code".utf8),
                                             nonce: "mock-nonce",
                                             fullName: {
                                                 var name = PersonNameComponents()
                                                 name.givenName = "John"
                                                 name.familyName = "Appleseed"
                                                 return name
                                             }(),
                                             email: "john@example.com",
                                             userIdentifier: "mock-apple-user-id")
}

/// Credential obtained from Google Sign-In.
///
/// Contains the ID token, access token, and optional user profile
/// information returned by `GIDGoogleUser`.
public struct GoogleCredential: Sendable, Equatable, Codable {
    /// The OpenID Connect ID token for identity verification.
    public let idToken: String

    /// The OAuth 2.0 access token for API calls.
    public let accessToken: String

    /// The user's display name, if available.
    public let displayName: String?

    /// The user's email address, if available.
    public let email: String?

    /// The user's profile photo URL, if available.
    public let photoURL: URL?

    /// Creates a Google credential.
    /// - Parameters:
    ///   - idToken: The OIDC ID token string.
    ///   - accessToken: The OAuth access token string.
    ///   - displayName: Optional display name.
    ///   - email: Optional email address.
    ///   - photoURL: Optional profile photo URL.
    public init(idToken: String,
                accessToken: String,
                displayName: String? = nil,
                email: String? = nil,
                photoURL: URL? = nil) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.displayName = displayName
        self.email = email
        self.photoURL = photoURL
    }

    /// A mock credential for testing.
    public static let mock = GoogleCredential(idToken: "mock-google-id-token",
                                              accessToken: "mock-google-access-token",
                                              displayName: "John Doe",
                                              email: "john@gmail.com",
                                              photoURL: URL(string: "https://example.com/photo.jpg"))
}
