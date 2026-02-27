# Getting Started

Integrate ARCAuthentication into your app to obtain authentication credentials.

## Overview

This guide shows how to use Sign in with Apple in your iOS app using ARCAuthentication.

## Prerequisites

1. An Apple Developer account
2. Sign in with Apple enabled on your App ID
3. The "Sign in with Apple" capability added to your target in Xcode

## Installation

Add ARCAuthentication to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCAuthentication.git", from: "2.0.0")
]
```

## Sign in with Apple

### Step 1: Create the Provider

```swift
import ARCAuthentication

let appleProvider = AppleCredentialProvider()
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

To add Google Sign-In, import the `ARCAuthGoogle` target:

```swift
import ARCAuthGoogle

let config = GoogleConfiguration(clientID: "your-client-id.apps.googleusercontent.com")
let provider = GoogleCredentialProvider(configuration: config)
let credential = try await provider.requestCredential()
```

## Important Notes

### Email and Name

Apple only provides the user's email and name on the **first** sign-in. Store these values immediately.

### Identity Token

The `identityToken` is a JWT that must be verified on your backend before trusting it.

### Backend Integration

ARCAuthentication only provides credentials. Your app is responsible for:
- Sending credentials to your backend for verification
- Managing user sessions and tokens
- Storing authentication state
