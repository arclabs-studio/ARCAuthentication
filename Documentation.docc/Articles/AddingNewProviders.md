# Adding New Providers

Create custom authentication providers by conforming to `CredentialProviding`.

## Overview

ARCAuthentication uses a protocol-oriented architecture that makes it easy to add new authentication methods.

## Implementing CredentialProviding

To create a new provider, conform to the ``CredentialProviding`` protocol:

```swift
import ARCAuthentication

@MainActor
public final class EmailCredentialProvider: CredentialProviding, @unchecked Sendable {
    public let providerType: AuthProviderType = .apple // or extend the enum

    public func requestCredential() async throws -> AuthCredential {
        // Implement your sign-in flow...
        let token = try await performEmailSignIn()

        return .apple(AppleCredential(
            identityToken: token,
            authorizationCode: code,
            nonce: nonce,
            userIdentifier: userID
        ))
    }
}
```

## Using the Provider

```swift
let provider = EmailCredentialProvider()
let credential = try await provider.requestCredential()
// Send credential to your backend...
```

## Testing

Use ``MockCredentialProvider`` to test code that depends on `CredentialProviding`:

```swift
let mock = MockCredentialProvider(
    providerType: .apple,
    result: .success(.apple(.mock))
)

// Inject mock into your view model or service
let viewModel = LoginViewModel(provider: mock)
await viewModel.signIn()

#expect(mock.requestCredentialCallCount == 1)
```

## Considerations

### Thread Safety

Providers must be `Sendable`. Use `@MainActor` for operations that require UI presentation and `@unchecked Sendable` if the class has mutable state guarded by the actor.

### Error Handling

Throw ``AuthenticationError`` cases to maintain consistency:

```swift
throw AuthenticationError.userCancelled
throw AuthenticationError.systemError("Network unavailable")
throw AuthenticationError.invalidConfiguration("Missing API key")
```
