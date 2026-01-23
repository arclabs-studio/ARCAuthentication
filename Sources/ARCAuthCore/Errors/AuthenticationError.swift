import Foundation

/// Errores del sistema de autenticación.
public enum AuthenticationError: LocalizedError, Sendable {
    // MARK: - Provider Errors

    /// El provider especificado no está registrado.
    case providerNotRegistered(String)

    /// Error específico del provider de Apple.
    case appleSignInFailed(underlying: Error?)

    /// El usuario canceló la autenticación.
    case userCancelled

    /// Las credenciales proporcionadas son inválidas.
    case invalidCredentials

    // MARK: - Token Errors

    /// El identity token no es válido o está corrupto.
    case invalidIdentityToken

    /// El token de acceso ha expirado.
    case tokenExpired

    /// No se pudo refrescar el token.
    case tokenRefreshFailed(underlying: Error?)

    // MARK: - Storage Errors

    /// Error al guardar en Keychain.
    case storageSaveFailed(underlying: Error?)

    /// Error al leer de Keychain.
    case storageReadFailed(underlying: Error?)

    /// Error al eliminar de Keychain.
    case storageDeleteFailed(underlying: Error?)

    // MARK: - Network Errors

    /// Error de red al comunicarse con el servidor.
    case networkError(underlying: Error?)

    /// El servidor retornó un error.
    case serverError(statusCode: Int, message: String?)

    // MARK: - State Errors

    /// No hay sesión activa.
    case noActiveSession

    /// El estado de credenciales de Apple fue revocado.
    case credentialRevoked

    /// Error desconocido.
    case unknown(underlying: Error?)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case let .providerNotRegistered(id):
            "Authentication provider '\(id)' is not registered"
        case let .appleSignInFailed(error):
            "Apple Sign In failed: \(error?.localizedDescription ?? "Unknown error")"
        case .userCancelled:
            "Authentication was cancelled by the user"
        case .invalidCredentials:
            "The provided credentials are invalid"
        case .invalidIdentityToken:
            "The identity token is invalid or corrupted"
        case .tokenExpired:
            "The access token has expired"
        case let .tokenRefreshFailed(error):
            "Failed to refresh token: \(error?.localizedDescription ?? "Unknown error")"
        case let .storageSaveFailed(error):
            "Failed to save credentials: \(error?.localizedDescription ?? "Unknown error")"
        case let .storageReadFailed(error):
            "Failed to read credentials: \(error?.localizedDescription ?? "Unknown error")"
        case let .storageDeleteFailed(error):
            "Failed to delete credentials: \(error?.localizedDescription ?? "Unknown error")"
        case let .networkError(error):
            "Network error: \(error?.localizedDescription ?? "Unknown error")"
        case let .serverError(code, message):
            "Server error (\(code)): \(message ?? "Unknown error")"
        case .noActiveSession:
            "No active authentication session"
        case .credentialRevoked:
            "Apple ID credentials have been revoked"
        case let .unknown(error):
            "Unknown error: \(error?.localizedDescription ?? "Unknown error")"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .userCancelled:
            "Try signing in again"
        case .tokenExpired, .tokenRefreshFailed:
            "Please sign in again"
        case .networkError:
            "Check your internet connection and try again"
        case .credentialRevoked:
            "Please sign in with Apple again to restore access"
        default:
            nil
        }
    }
}

// MARK: - Equatable

extension AuthenticationError: Equatable {
    // swiftlint:disable:next cyclomatic_complexity
    public static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case let (.providerNotRegistered(lhsID), .providerNotRegistered(rhsID)):
            lhsID == rhsID
        case (.appleSignInFailed, .appleSignInFailed):
            true
        case (.userCancelled, .userCancelled):
            true
        case (.invalidCredentials, .invalidCredentials):
            true
        case (.invalidIdentityToken, .invalidIdentityToken):
            true
        case (.tokenExpired, .tokenExpired):
            true
        case (.tokenRefreshFailed, .tokenRefreshFailed):
            true
        case (.storageSaveFailed, .storageSaveFailed):
            true
        case (.storageReadFailed, .storageReadFailed):
            true
        case (.storageDeleteFailed, .storageDeleteFailed):
            true
        case (.networkError, .networkError):
            true
        case let (.serverError(lhsCode, lhsMsg), .serverError(rhsCode, rhsMsg)):
            lhsCode == rhsCode && lhsMsg == rhsMsg
        case (.noActiveSession, .noActiveSession):
            true
        case (.credentialRevoked, .credentialRevoked):
            true
        case (.unknown, .unknown):
            true
        default:
            false
        }
    }
}
