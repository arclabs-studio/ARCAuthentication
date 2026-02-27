import Foundation

/// Request for email/password authentication.
public struct LoginRequest: Sendable, Codable {
    /// User email.
    public let email: String

    /// User password.
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
