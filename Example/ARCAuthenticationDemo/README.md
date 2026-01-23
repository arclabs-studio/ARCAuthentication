# ARCAuthentication Demo

A demonstration iOS app showcasing the ARCAuthentication package.

## Features

- Sign in with Apple integration
- Session persistence with Keychain
- Observable authentication state
- SwiftUI components

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Apple Developer account (for Sign in with Apple capability)

## Running the Demo

1. Open the project in Xcode:
   ```bash
   open ARCAuthenticationDemo.xcodeproj
   ```

2. Configure Sign in with Apple:
   - Select the project in the navigator
   - Go to "Signing & Capabilities"
   - Add your Development Team
   - Click "+ Capability" and add "Sign in with Apple"

3. Run on a device or simulator

## Project Structure

```
ARCAuthenticationDemo/
├── ARCAuthenticationDemo.xcodeproj
├── ARCAuthenticationDemo/
│   ├── ARCAuthenticationDemoApp.swift   # App entry point
│   ├── ContentView.swift                 # Main views
│   ├── Info.plist
│   └── Assets.xcassets/
└── README.md
```

## Usage Example

The demo app shows how to:

### 1. Configure AuthenticationManager

```swift
@StateObject private var authManager: AuthenticationManager = {
    let manager = AuthenticationManager()
    manager.register(provider: AppleAuthProvider())
    return manager
}()
```

### 2. Restore Session on Launch

```swift
.task {
    await authManager.restoreSession()
}
```

### 3. Authenticate with Apple

```swift
AppleSignInButton {
    try await authManager.authenticate(with: "apple")
}
```

### 4. Check Authentication State

```swift
if authManager.state.isAuthenticated {
    // Show authenticated content
} else {
    // Show login
}
```

### 5. Sign Out

```swift
try await authManager.signOut()
```

## Architecture

The demo follows MVVM architecture with:

- **AuthenticationManager**: Central coordinator for auth state
- **AppleAuthProvider**: Sign in with Apple implementation
- **KeychainAuthStorage**: Secure credential storage (via ARCStorage)
- **AuthenticationState**: Observable state for SwiftUI

## License

MIT License - See LICENSE in the root directory.
