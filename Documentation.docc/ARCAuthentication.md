# ``ARCAuthentication``

Backend-agnostic credential provider for Apple and Google authentication.

## Overview

ARCAuthentication handles platform sign-in flows and returns provider-specific credentials that any backend can consume — Firebase, Vapor, Supabase, or your own.

The package provides two targets:

- **ARCAuthentication**: Core library with Apple credential provider, models, and utilities
- **ARCAuthGoogle**: Google Sign-In credential provider (requires GoogleSignIn SDK)

A demo app is included in `Example/ARCAuthenticationDemo/` showcasing both Sign in with Apple and Google Sign-In with shared sign-in logic via the ``CredentialProviding`` protocol.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:AddingNewProviders>

### Protocols

- ``CredentialProviding``

### Providers

- ``AppleCredentialProvider``
- ``MockCredentialProvider``

### Models

- ``AuthCredential``
- ``AppleCredential``
- ``GoogleCredential``
- ``AuthProviderType``
- ``AuthenticationState``

### Errors

- ``AuthenticationError``

### Utilities

- ``CryptoUtils``

### UI Components

- ``AppleSignInButton``
