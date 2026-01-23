# Adding New Providers

Aprende a crear nuevos providers de autenticación.

## Overview

ARCAuthentication usa una arquitectura protocol-oriented que facilita añadir nuevos métodos de autenticación.

## Implementando AuthenticationProvider

Para crear un nuevo provider, implementa el protocolo `AuthenticationProvider`:

```swift
import ARCAuthClient
import ARCAuthCore

@MainActor
public final class GoogleAuthProvider: AuthenticationProvider {

    public let providerID: String = "google"
    public let displayName: String = "Google"

    public var isAvailable: Bool {
        // Verificar si Google Sign-In SDK está disponible
        true
    }

    public func authenticate() async throws -> AuthCredential {
        // Implementar flujo de Google Sign-In
        // ...

        return AuthCredential(
            userID: googleUserID,
            email: googleEmail,
            displayName: googleDisplayName,
            provider: .google,
            identityToken: googleIDToken
        )
    }

    public func signOut() async throws {
        // Cerrar sesión de Google
    }

    public func checkCredentialState() async -> CredentialState {
        // Verificar estado de la sesión
        .authorized
    }
}
```

## Registrando el Provider

Una vez implementado, registra el provider en el `AuthenticationManager`:

```swift
let manager = AuthenticationManager()
manager.register(provider: AppleAuthProvider())
manager.register(provider: GoogleAuthProvider())
```

## Usando el Provider

Los usuarios pueden autenticarse con cualquier provider registrado:

```swift
// Sign in with Apple
try await authManager.authenticate(with: "apple")

// Sign in with Google
try await authManager.authenticate(with: "google")
```

## Consideraciones

### Thread Safety

Los providers deben ser `Sendable` y usar `@MainActor` para operaciones de UI.

### Manejo de Errores

Lanza errores de tipo `AuthenticationError` para mantener consistencia:

```swift
throw AuthenticationError.invalidCredentials
throw AuthenticationError.unknown(underlying: originalError)
```

### Storage

Las credenciales se guardan automáticamente en Keychain. No necesitas manejar el storage manualmente.
