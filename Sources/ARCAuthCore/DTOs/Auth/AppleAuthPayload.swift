import Foundation

/// Payload enviado al backend para verificación de Sign in with Apple.
///
/// Contiene toda la información necesaria para que el servidor:
/// 1. Verifique el JWT con Apple
/// 2. Cree o actualice el usuario en la base de datos
/// 3. Genere tokens de sesión propios
public struct AppleAuthPayload: Sendable, Codable {
    /// Identity token JWT de Apple (codificado en Base64).
    public let identityToken: String

    /// Código de autorización para intercambio server-to-server.
    public let authorizationCode: String

    /// Nombre completo del usuario (solo primer auth).
    public let fullName: FullName?

    /// Email del usuario (solo primer auth).
    public let email: String?

    /// Identificador único del usuario de Apple.
    public let userIdentifier: String

    /// Indica si es una cuenta real vs bot (Apple's fraud detection).
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

    /// Nombre completo formateado.
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
