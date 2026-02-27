# ARCAuthentication Demo

A demonstration iOS app showcasing the ARCAuthentication package.

## Features

- Sign in with Apple credential provider
- SwiftUI button component
- Credential display after sign-in

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

### 1. Create a Credential Provider

```swift
let provider = AppleCredentialProvider()
```

### 2. Request a Credential

```swift
let credential = try await provider.requestCredential()
```

### 3. Use the Apple Sign-In Button

```swift
AppleSignInButton {
    Task {
        let credential = try await provider.requestCredential()
        // Handle credential...
    }
}
```

## Architecture

The demo uses ARCAuthentication v2 as a pure credential provider:

- **AppleCredentialProvider**: Handles the Sign in with Apple flow
- **AppleSignInButton**: SwiftUI wrapper for the system button
- **AuthCredential**: Provider-agnostic credential result

Backend integration (Firebase, Vapor, etc.) is the app's responsibility.

## License

MIT License - See LICENSE in the root directory.
