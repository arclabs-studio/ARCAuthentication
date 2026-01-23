# 🧑‍🧒 ARCAuthentication

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20%7C%20macOS%2014%20%7C%20watchOS%2010%20%7C%20tvOS%2017%20%7C%20visionOS%201-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**Sistema de autenticación modular y reutilizable para apps de ARC Labs Studio.**

---

## 🎯 Overview

ARCAuthentication proporciona una arquitectura protocol-oriented que permite autenticación mediante Sign in with Apple (SIWA) con integración preparada para un backend Vapor, preparado para expandirse a otros providers en el futuro.

### Características

- ✅ Sign in with Apple nativo
- ✅ Arquitectura protocol-oriented extensible
- ✅ DTOs compartidos listos para Vapor
- ✅ Gestión de estado con Combine/SwiftUI
- ✅ Almacenamiento seguro en Keychain (vía ARCStorage)
- ✅ Componentes UI base siguiendo HIG
- ✅ Swift 6 con strict concurrency

---

## 📋 Requirements

- **Swift** 6.0+
- **iOS** 17.0+ / **macOS** 14.0+ / **watchOS** 10.0+ / **tvOS** 17.0+ / **visionOS** 1.0+
- **Xcode** 16.0+

---

## 🚀 Installation

### Swift Package Manager

Add ARCAuthentication to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCAuthentication.git", from: "1.0.0")
]
```

Then add the targets you need:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        // Import both Core and Client
        .product(name: "ARCAuthentication", package: "ARCAuthentication"),
        // Or import separately:
        // .product(name: "ARCAuthCore", package: "ARCAuthentication"),
        // .product(name: "ARCAuthClient", package: "ARCAuthentication"),
    ]
)
```

---

## 📖 Usage

### Basic Setup

```swift
import ARCAuthentication

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

### Sign in with Apple

```swift
import ARCAuthentication
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack {
            AppleSignInButton {
                try await authManager.authenticate(with: "apple")
            }
            .frame(width: 280, height: 50)
        }
    }
}
```

### Check Authentication State

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

### Using the View Modifier

```swift
ContentView()
    .withAuthentication(manager: authManager) {
        LoginView()
    }
```

### Sign Out

```swift
Button("Sign Out") {
    Task {
        try await authManager.signOut()
    }
}
```

---

## 🏗️ Architecture

### Targets

| Target | Description |
|--------|-------------|
| `ARCAuthCore` | DTOs compartidos (sin dependencias externas) - puede usarse en Vapor |
| `ARCAuthClient` | Cliente iOS con providers, storage y UI |
| `ARCAuthentication` | Convenience target que incluye ambos |

### Key Components

```
ARCAuthCore/
├── DTOs/
│   ├── Auth/
│   │   ├── AuthCredential      # Credenciales de usuario
│   │   ├── AppleAuthPayload    # Payload para verificación backend
│   │   ├── TokenResponse       # Respuesta de tokens del servidor
│   │   └── ...
│   └── User/
│       ├── UserDTO             # DTO de usuario
│       └── UserProfileDTO      # Perfil extendido
├── Errors/
│   └── AuthenticationError     # Errores del sistema
└── Constants/
    └── AuthConstants           # Constantes de configuración

ARCAuthClient/
├── Core/
│   ├── AuthenticationManager   # Manager central
│   ├── AuthenticationState     # Estado observable
│   └── AuthenticationConfiguration
├── Protocols/
│   ├── AuthenticationProvider  # Protocolo para providers
│   ├── AuthStorageProtocol     # Protocolo para storage
│   └── AuthAPIClientProtocol   # Protocolo para API
├── Providers/
│   └── AppleAuthProvider       # Sign in with Apple
├── Storage/
│   └── KeychainAuthStorage     # Storage en Keychain
├── Networking/
│   └── AuthAPIClient           # Cliente HTTP (futuro)
└── UI/
    ├── Components/
    │   └── AppleSignInButton   # Botón SIWA
    └── ViewModifiers/
        └── AuthenticationViewModifier
```

---

## 🧪 Testing

Run tests with:

```bash
swift test
```

Or use the Makefile:

```bash
make test
```

---

## 🤝 Contributing

This package follows ARC Labs Studio development standards. See [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge) for guidelines.

### Development Setup

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/arclabs-studio/ARCAuthentication

# Or initialize submodules after cloning
git submodule update --init --recursive

# Run ARCDevTools setup
./ARCDevTools/arcdevtools-setup
```

### Quality Checks

```bash
make lint    # Run SwiftLint
make format  # Check SwiftFormat
make fix     # Apply SwiftFormat
make build   # Build package
make test    # Run tests
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**ARC Labs Studio** · [arclabs.studio](https://arclabs.studio)
