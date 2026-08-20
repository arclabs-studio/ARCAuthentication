# ARCAuthentication Demo

A demonstration iOS app showcasing the ARCAuthentication package with Sign in with Apple and Google Sign-In.

## Features

- Sign in with Apple credential provider
- Google Sign-In credential provider
- SwiftUI button components for both providers
- Credential display after sign-in (provider-specific details)
- Shared `signIn(with:)` method demonstrating the `CredentialProviding` protocol

## Requirements

- iOS 17.0+
- Xcode 16.0+
- Apple Developer account (for Sign in with Apple capability)
- Google Cloud Console project (for Google Sign-In — optional)

## Running the Demo

1. Open the project in Xcode:
   ```bash
   open ARCAuthenticationDemo.xcodeproj
   ```

2. Select your Development Team in **Signing & Capabilities**.

3. **Sign in with Apple** works on the iOS Simulator out of the box (Apple provides a mock flow). On a physical device, add the "Sign in with Apple" capability.

4. **Google Sign-In** requires additional setup — see [Configuring Google Sign-In](#configuring-google-sign-in) below. It can be skipped if you only want to test Apple authentication.

5. Run on a device or simulator.

## Configuring Google Sign-In

Google Sign-In requires an OAuth client ID from the Google Cloud Console. Without it, tapping "Sign in with Google" will produce a configuration error.

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project (or select an existing one)
3. Navigate to **APIs & Services** > **Credentials**

### Step 2: Create an OAuth 2.0 Client ID

1. Click **Create Credentials** > **OAuth client ID**
2. Select **iOS** as the application type
3. Enter the demo app's bundle identifier (e.g., `com.arclabs.ARCAuthenticationDemo`)
4. Note the **Client ID** (format: `XXXX.apps.googleusercontent.com`)
5. Note the **Reversed Client ID** (format: `com.googleusercontent.apps.XXXX`)

### Step 3: Configure the Demo App

1. Open `ContentView.swift` and replace the placeholder:
   ```swift
   private let googleProvider = GoogleCredentialProvider(
       configuration: GoogleConfiguration(
           clientID: "YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com"
       )
   )
   ```

2. In the Xcode project, add two build settings (or use an `.xcconfig` file):
   - `GOOGLE_CLIENT_ID` = your client ID
   - `GOOGLE_REVERSED_CLIENT_ID` = your reversed client ID

   These are referenced by `Info.plist` for the URL scheme callback and the `GIDClientID` entry.

> **Tip:** If you skip Google configuration, Apple Sign-In still works independently.

## Project Structure

```
ARCAuthenticationDemo/
├── ARCAuthenticationDemo.xcodeproj
├── ARCAuthenticationDemo/
│   ├── ARCAuthenticationDemoApp.swift   # App entry point + Google URL handler
│   ├── ContentView.swift                 # Login, authenticated, and button views
│   ├── Info.plist                        # URL schemes + GIDClientID
│   └── Assets.xcassets/
└── README.md
```

## Usage Example

The demo app shows how to:

### 1. Create Credential Providers

```swift
import ARCAuthentication
import ARCAuthGoogle

let appleProvider = AppleCredentialProvider()
let googleProvider = GoogleCredentialProvider(
    configuration: GoogleConfiguration(clientID: "your-client-id")
)
```

### 2. Request a Credential (protocol-based)

```swift
func signIn(with provider: some CredentialProviding) {
    Task {
        do {
            let credential = try await provider.requestCredential()
            // Handle credential...
        } catch let error as AuthenticationError {
            if case .userCancelled = error { return }
            // Show error...
        }
    }
}
```

### 3. Use the Sign-In Buttons

```swift
AppleSignInButton(action: { signIn(with: appleProvider) })
    .frame(height: 50)

GoogleSignInButton(action: { signIn(with: googleProvider) })
    .frame(height: 50)
```

### 4. Handle the Google OAuth Callback

In your app entry point:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
```

## Architecture

The demo uses ARCAuthentication v2 as a pure credential provider:

- **AppleCredentialProvider**: Handles the Sign in with Apple flow
- **GoogleCredentialProvider**: Handles the Google Sign-In flow (from `ARCAuthGoogle`)
- **CredentialProviding**: Protocol both providers conform to, enabling shared sign-in logic
- **AppleSignInButton**: SwiftUI wrapper for the system Sign in with Apple button
- **AuthCredential**: Provider-agnostic credential enum (`.apple` or `.google`)

Backend integration (Firebase, Vapor, Supabase, etc.) is the app's responsibility.

## License

MIT License - See LICENSE in the root directory.
