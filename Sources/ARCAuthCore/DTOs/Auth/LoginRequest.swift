import Foundation

/// Request para autenticación con email/password.
public struct LoginRequest: Sendable, Codable {
    /// Email del usuario.
    public let email: String

    /// Password del usuario.
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
