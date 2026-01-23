import Foundation

/// Información del usuario para transferencia entre cliente y servidor.
public struct UserDTO: Sendable, Codable, Identifiable, Equatable, Hashable {
    public let id: UUID
    public let email: String?
    public let displayName: String?
    public let profileImageURL: URL?
    public let provider: AuthProvider
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: UUID,
        email: String?,
        displayName: String?,
        profileImageURL: URL? = nil,
        provider: AuthProvider,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.provider = provider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
