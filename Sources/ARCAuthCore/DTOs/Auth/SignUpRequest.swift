import Foundation

/// Request for email/password registration.
public struct SignUpRequest: Sendable, Codable {
    /// User email.
    public let email: String

    /// User password.
    public let password: String

    /// Display name (optional).
    public let displayName: String?

    public init(email: String, password: String, displayName: String? = nil) {
        self.email = email
        self.password = password
        self.displayName = displayName
    }
}
