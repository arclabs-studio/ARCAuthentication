import Foundation

/// Payload sent to the backend for Sign in with Apple verification.
///
/// Contains all the information needed for the server to:
/// 1. Verify the JWT with Apple
/// 2. Create or update the user in the database
/// 3. Generate its own session tokens
public struct AppleAuthPayload: Sendable, Codable {
    /// Apple identity token JWT (Base64-encoded).
    public let identityToken: String

    /// Authorization code for server-to-server exchange.
    public let authorizationCode: String

    /// User's full name (first auth only).
    public let fullName: FullName?

    /// User email (first auth only).
    public let email: String?

    /// Apple's unique user identifier.
    public let userIdentifier: String

    /// Whether this is a real account vs bot (Apple's fraud detection).
    public let realUserStatus: RealUserStatus

    public init(
        identityToken: String,
        authorizationCode: String,
        fullName: FullName? = nil,
        email: String? = nil,
        userIdentifier: String,
        realUserStatus: RealUserStatus
    ) {
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
        self.fullName = fullName
        self.email = email
        self.userIdentifier = userIdentifier
        self.realUserStatus = realUserStatus
    }
}

// MARK: - Supporting Types

public struct FullName: Sendable, Codable {
    public let givenName: String?
    public let familyName: String?
    public let nickname: String?

    public init(givenName: String?, familyName: String?, nickname: String? = nil) {
        self.givenName = givenName
        self.familyName = familyName
        self.nickname = nickname
    }

    /// Formatted full name.
    public var formatted: String? {
        [givenName, familyName]
            .compactMap(\.self)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .nilIfEmpty
    }
}

public enum RealUserStatus: Int, Sendable, Codable {
    case unsupported = 0
    case unknown = 1
    case likelyReal = 2
}

// MARK: - String Extension

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
