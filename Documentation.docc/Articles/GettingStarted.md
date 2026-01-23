# Getting Started

Aprende a integrar ARCAuthentication en tu app.

## Overview

Esta guía te muestra cómo configurar Sign in with Apple en tu aplicación iOS usando ARCAuthentication.

## Requisitos Previos

1. Una cuenta de desarrollador de Apple
2. Sign in with Apple habilitado en tu App ID
3. El capability "Sign in with Apple" añadido a tu target en Xcode

## Instalación

Añade ARCAuthentication a tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCAuthentication.git", from: "1.0.0")
]
```

## Configuración

### Paso 1: Crear el AuthenticationManager

En tu `App.swift`, crea y configura el `AuthenticationManager`:

```swift
import ARCAuthentication
import SwiftUI

@main
struct MyApp: App {
    @StateObject private var authManager: AuthenticationManager = {
        let manager = AuthenticationManager()
        manager.register(provider: AppleAuthProvider())
        return manager
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
```

### Paso 2: Crear la Vista de Login

```swift
import ARCAuthentication
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Bienvenido")
                .font(.largeTitle)

            AppleSignInButton {
                try await authManager.authenticate(with: "apple")
            }
            .frame(width: 280, height: 50)
        }
    }
}
```

### Paso 3: Manejar el Estado de Autenticación

```swift
struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        Group {
            if authManager.state.isAuthenticated {
                MainView()
            } else {
                LoginView()
            }
        }
        .task {
            await authManager.restoreSession()
        }
    }
}
```

## Notas Importantes

### Email y Nombre

Apple solo proporciona el email y nombre del usuario en el **primer** Sign in. Asegúrate de guardar estos valores inmediatamente.

### Identity Token

El `identityToken` es un JWT que debe verificarse en tu backend antes de confiar en él.

### Estado de Credenciales

Las credenciales de Apple pueden ser revocadas por el usuario en cualquier momento desde Configuración > Apple ID. Usa `restoreSession()` al iniciar la app para verificar el estado.
