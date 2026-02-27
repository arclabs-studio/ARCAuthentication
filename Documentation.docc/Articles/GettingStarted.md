# Getting Started

Integrate ARCAuthentication into your app to obtain authentication credentials.

## Overview

This guide shows how to add Sign in with Apple and Google Sign-In to your iOS app using ARCAuthentication. Both providers conform to ``CredentialProviding``, so you can write shared sign-in logic once.

## Prerequisites

- An Apple Developer account
- Sign in with Apple enabled on your App ID (for Apple authentication)
- A Google Cloud Console project with an iOS OAuth client ID (for Google authentication)
- The "Sign in with Apple" capability added to your target in Xcode

## Installation

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
        .product(name: "ARCAuthentication", package: "ARCAuthentication"),
        // Optional: add Google Sign-In support
        .product(name: "ARCAuthGoogle", package: "ARCAuthentication"),
    ]
)
```

## Sign in with Apple

### Step 1: Create the Provider

```swift
import ARCAuthentication

let appleProvider = AppleCredentialProvider()
```

You can customize the requested scopes:

```swift
let appleProvider = AppleCredentialProvider(scopes: [.fullName, .email])
```

### Step 2: Request a Credential

```swift
do {
    let credential = try await appleProvider.requestCredential()

    switch credential {
    case .apple(let apple):
        // Send apple.identityToken and apple.authorizationCode to your backend
        print("User: \(apple.userIdentifier)")
    case .google:
        break
    }
} catch let error as AuthenticationError {
    switch error {
    case .userCancelled:
        break // User tapped Cancel
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

### Step 3: Add the Button

```swift
import ARCAuthentication
import SwiftUI

struct LoginView: View {
    let provider = AppleCredentialProvider()

    var body: some View {
        AppleSignInButton {
            Task {
                let credential = try await provider.requestCredential()
                // Handle credential...
            }
        }
        .frame(height: 50)
    }
}
```

## Google Sign-In

### Step 1: Get a Client ID

1. Go to [Google Cloud Console](https://console.cloud.google.com/) > **APIs & Services** > **Credentials**
2. Create an **OAuth 2.0 Client ID** with application type **iOS**
3. Enter your app's bundle identifier
4. Note the **Client ID** (e.g., `123456.apps.googleusercontent.com`)
5. Note the **Reversed Client ID** (e.g., `com.googleusercontent.apps.123456`)

### Step 2: Configure Info.plist

Add the reversed client ID as a URL scheme so Google can redirect back to your app:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
        <key>CFBundleURLName</key>
        <string>Google Sign-In</string>
    </dict>
</array>
```

Optionally add the client ID for Info.plist-based configuration:

```xml
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>
```

### Step 3: Handle the OAuth Callback

In your app entry point, forward incoming URLs to the Google Sign-In SDK:

```swift
import GoogleSignIn
import SwiftUI

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

### Step 4: Create the Provider and Request a Credential

```swift
import ARCAuthGoogle

let config = GoogleConfiguration(clientID: "your-client-id.apps.googleusercontent.com")
let provider = GoogleCredentialProvider(configuration: config)
let credential = try await provider.requestCredential()

switch credential {
case .google(let google):
    // Send google.idToken to your backend for verification
    print("Name: \(google.displayName ?? "N/A")")
    print("Email: \(google.email ?? "N/A")")
case .apple:
    break
}
```

You can also request additional OAuth scopes:

```swift
let config = GoogleConfiguration(
    clientID: "your-client-id.apps.googleusercontent.com",
    additionalScopes: ["https://www.googleapis.com/auth/drive.readonly"]
)
```

## Using Multiple Providers

Both providers conform to ``CredentialProviding``, so you can write generic sign-in logic:

```swift
func signIn(with provider: some CredentialProviding) async {
    do {
        let credential = try await provider.requestCredential()
        // Send credential to your backend...
    } catch let error as AuthenticationError {
        if case .userCancelled = error { return }
        // Handle error...
    } catch {
        // Handle unexpected error...
    }
}

// Use with any provider
await signIn(with: appleProvider)
await signIn(with: googleProvider)
```

## Important Notes

### Apple: Email and Name

Apple only provides the user's email and name on the **first** sign-in. Store these values immediately in your backend.

### Apple: Identity Token

The `identityToken` is a JWT that must be verified on your backend before trusting it. The `authorizationCode` expires in 5 minutes.

### Google: ID Token

The `idToken` should be verified server-side. The `accessToken` can be used for Google API calls but has a short expiration.

### Backend Integration

ARCAuthentication only provides credentials. Your app is responsible for:
- Sending credentials to your backend for verification
- Managing user sessions and tokens
- Storing authentication state
