# ARCAuthentication

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%20%7C%20macOS%2014-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-2.0.0-blue.svg)

**Backend-agnostic credential provider for Apple and Google authentication.**

---

## Overview

ARCAuthentication is a pure credential-provider library. It handles the platform sign-in flows (Sign in with Apple, Google Sign-In) and returns provider-specific credentials that your backend — Firebase, Vapor, Supabase, or any other — can consume directly.

### Features

- Sign in with Apple via `AppleCredentialProvider`
- Google Sign-In via `GoogleCredentialProvider` (separate `ARCAuthGoogle` target)
- Protocol-oriented: implement `CredentialProviding` for custom providers
- Shared sign-in logic across providers via protocol abstraction
- Zero ARC package dependencies (core target)
- `MockCredentialProvider` included for testing
- `AppleSignInButton` SwiftUI component
- Swift 6 strict concurrency
- Demo app with both Apple and Google authentication

---

## Requirements

- **Swift** 6.0+
- **iOS** 17.0+ / **macOS** 14.0+
- **Xcode** 16.0+

---

## Installation

### Swift Package Manager

Add ARCAuthentication to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCAuthentication.git", from: "2.0.0")
]
```

Then add the targets you need:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        // Core: Apple credential provider
        .product(name: "ARCAuthentication", package: "ARCAuthentication"),
        // Optional: Google credential provider
        // .product(name: "ARCAuthGoogle", package: "ARCAuthentication"),
    ]
)
```

---

## Usage

### Sign in with Apple

```swift
import ARCAuthentication

let provider = AppleCredentialProvider()
let credential = try await provider.requestCredential()

// Send to your backend
switch credential {
case .apple(let apple):
    let token = apple.identityToken
    let code = apple.authorizationCode
    // Verify with your backend...
case .google:
    break
}
```

### Using the Button

```swift
import ARCAuthentication
import SwiftUI

struct LoginView: View {
    let provider = AppleCredentialProvider()

    var body: some View {
        // Adaptive — recommended (black in light mode, white in dark mode)
        AppleSignInButton {
            Task {
                let credential = try await provider.requestCredential()
                // Handle credential...
            }
        }
        .frame(height: 50)

        // Custom label type
        AppleSignInButton(type: .signUp) {
            Task { let credential = try await provider.requestCredential() }
        }

        // Fixed style (ignores color scheme)
        AppleSignInButton(type: .continue, style: .whiteOutline) {
            Task { let credential = try await provider.requestCredential() }
        }
    }
}
```

`AppleSignInButton` accepts an `ARCAppleButtonLabel` for its `type` parameter — no `import AuthenticationServices` required in caller code. Available cases: `.signIn` (default), `.signUp`, `.continue`.

### Google Sign-In

Google Sign-In requires a client ID from the [Google Cloud Console](https://console.cloud.google.com/) and the `ARCAuthGoogle` target.

```swift
import ARCAuthGoogle

let config = GoogleConfiguration(clientID: "your-client-id.apps.googleusercontent.com")
let provider = GoogleCredentialProvider(configuration: config)
let credential = try await provider.requestCredential()

switch credential {
case .google(let google):
    let idToken = google.idToken
    let accessToken = google.accessToken
    // Verify with your backend...
case .apple:
    break
}
```

Your app must also handle the OAuth callback URL:

```swift
// In your App entry point
.onOpenURL { url in
    GIDSignIn.sharedInstance.handle(url)
}
```

And register the reversed client ID as a URL scheme in your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### Custom Provider

```swift
final class EmailCredentialProvider: CredentialProviding {
    let providerType: AuthProviderType = .apple // or extend as needed

    func requestCredential() async throws -> AuthCredential {
        // Your implementation...
    }
}
```

### Testing

```swift
import ARCAuthentication

let mock = MockCredentialProvider(
    providerType: .apple,
    result: .success(.apple(.mock))
)

let credential = try await mock.requestCredential()
assert(mock.requestCredentialCallCount == 1)
```

---

## Architecture

### Targets

| Target | Description | Dependencies |
|--------|-------------|--------------|
| `ARCAuthentication` | Core: protocols, models, Apple provider, utilities | None |
| `ARCAuthGoogle` | Google Sign-In provider | ARCAuthentication, GoogleSignIn SDK |

### Key Components

```
Sources/ARCAuthentication/
├── Protocols/
│   └── CredentialProviding       # Provider protocol
├── Providers/
│   └── AppleCredentialProvider   # Sign in with Apple
├── Models/
│   ├── AuthCredential            # Credential enum + structs
│   ├── AuthProviderType          # Provider type enum
│   └── AuthenticationState       # Generic state enum
├── Errors/
│   └── AuthenticationError       # Credential-only errors
├── Utilities/
│   └── CryptoUtils               # Nonce + SHA256
├── UI/
│   ├── AppleSignInButton         # SwiftUI wrapper
│   └── ARCAppleButtonLabel       # Button label enum (.signIn, .signUp, .continue)
└── Testing/
    └── MockCredentialProvider     # Test double

Sources/ARCAuthGoogle/
├── Models/
│   └── GoogleConfiguration       # Google client config
└── Providers/
    └── GoogleCredentialProvider   # Google Sign-In
```

---

## Demo App

A complete demo app is included at `Example/ARCAuthenticationDemo/` showing both providers in action:

- **Sign in with Apple** — works on the iOS Simulator without configuration
- **Google Sign-In** — requires a Google Cloud Console client ID (see the [demo README](Example/ARCAuthenticationDemo/README.md) for setup)

The demo uses a shared `signIn(with: some CredentialProviding)` method to show how the protocol abstraction works in practice.

---

## Migration from v1

v2.0.0 is a **breaking change**. The library no longer manages sessions, tokens, or backend communication.

| v1 | v2 |
|----|----|
| `import ARCAuthCore` / `import ARCAuthClient` | `import ARCAuthentication` |
| `AuthenticationManager` | Removed — manage state in your app |
| `AppleAuthProvider().authenticate()` | `AppleCredentialProvider().requestCredential()` |
| `KeychainAuthStorage` | Removed — use your backend's storage |
| `AuthAPIClient` | Removed — use your backend's client |
| ARCLogger / ARCStorage deps | Zero ARC deps |

---

## Testing

```bash
swift test
# Or:
make test
```

---

## Contributing

This package follows ARC Labs Studio development standards. See [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge) for guidelines.

### Development Setup

```bash
git clone --recurse-submodules https://github.com/arclabs-studio/ARCAuthentication
git submodule update --init --recursive
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

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**ARC Labs Studio** · [arclabs.studio](https://arclabs.studio)
