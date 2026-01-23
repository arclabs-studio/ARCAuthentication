import Foundation

/// Configuración para el sistema de autenticación.
public struct AuthenticationConfiguration: Sendable {
    /// URL base del servidor de autenticación (para futuro uso con backend).
    public let serverBaseURL: URL?

    /// Indica si se debe verificar credenciales de Apple al restaurar sesión.
    public let verifyAppleCredentialsOnRestore: Bool

    /// Indica si se debe persistir el displayName en UserDefaults.
    public let persistDisplayNameInUserDefaults: Bool

    /// Configuración por defecto.
    public static let `default` = AuthenticationConfiguration(
        serverBaseURL: nil,
        verifyAppleCredentialsOnRestore: true,
        persistDisplayNameInUserDefaults: true
    )

    public init(
        serverBaseURL: URL? = nil,
        verifyAppleCredentialsOnRestore: Bool = true,
        persistDisplayNameInUserDefaults: Bool = true
    ) {
        self.serverBaseURL = serverBaseURL
        self.verifyAppleCredentialsOnRestore = verifyAppleCredentialsOnRestore
        self.persistDisplayNameInUserDefaults = persistDisplayNameInUserDefaults
    }
}
