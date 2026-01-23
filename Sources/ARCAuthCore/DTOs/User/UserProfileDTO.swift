import Foundation

/// Información extendida del perfil de usuario.
public struct UserProfileDTO: Sendable, Codable, Identifiable, Equatable, Hashable {
    public let id: UUID
    public let email: String?
    public let displayName: String?
    public let firstName: String?
    public let lastName: String?
    public let profileImageURL: URL?
    public let provider: AuthProvider
    public let isEmailVerified: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        email: String?,
        displayName: String?,
        firstName: String? = nil,
        lastName: String? = nil,
        profileImageURL: URL? = nil,
        provider: AuthProvider,
        isEmailVerified: Bool = false,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageURL = profileImageURL
        self.provider = provider
        self.isEmailVerified = isEmailVerified
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Nombre completo formateado.
    public var fullName: String? {
        [firstName, lastName]
            .compactMap(\.self)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .nilIfEmpty
    }
}
