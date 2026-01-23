import Foundation

/// Request para registro con email/password.
public struct SignUpRequest: Sendable, Codable {
    /// Email del usuario.
    public let email: String

    /// Password del usuario.
    public let password: String

    /// Nombre para mostrar (opcional).
    public let displayName: String?

    public init(email: String, password: String, displayName: String? = nil) {
        self.email = email
        self.password = password
        self.displayName = displayName
    }
}
