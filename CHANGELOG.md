# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Google Sign-In to the demo app alongside Sign in with Apple
- Demo app README with full Google Sign-In configuration guide
- Comprehensive documentation for Google Sign-In setup in DocC Getting Started guide
- URL scheme and `onOpenURL` handler in demo app for Google OAuth callback

## [2.0.0] - 2026-02-27

### Breaking Changes

- **Complete API redesign**: ARCAuthentication is now a pure credential provider library.
  The Vapor-specific session management, token storage, and API client have been removed.
- Removed `ARCAuthCore` and `ARCAuthClient` targets — replaced by single `ARCAuthentication` target
- Removed `AuthenticationManager`, `AuthenticationConfiguration`, `AuthenticationState` (session management)
- Removed `KeychainAuthStorage`, `AuthStorageProtocol` (token storage)
- Removed `AuthAPIClient`, `AuthAPIClientProtocol` (backend HTTP client)
- Removed all DTOs: `AppleAuthPayload`, `TokenResponse`, `LoginRequest`, `SignUpRequest`, `RefreshTokenRequest`, `UserDTO`, `UserProfileDTO`, `ServerTokens`, `AuthConstants`
- Removed `AuthenticationViewModifier`
- Removed dependencies on `ARCLogger` and `ARCStorage`
- Dropped watchOS, tvOS, and visionOS platform support

### Added

- `CredentialProviding` protocol for backend-agnostic credential providers
- `AuthCredential` enum with `.apple(AppleCredential)` and `.google(GoogleCredential)` cases
- `AppleCredential` struct with identity token, authorization code, nonce, and user info
- `GoogleCredential` struct with ID token, access token, and user profile
- `AuthProviderType` enum (`.apple`, `.google`)
- `AuthenticationState<UserType>` generic state enum for consumer use
- `AuthenticationError` redesigned for credential-only errors
- `AppleCredentialProvider` — refactored from `AppleAuthProvider` with configurable scopes
- `GoogleCredentialProvider` in new `ARCAuthGoogle` target (requires GoogleSignIn SDK)
- `GoogleConfiguration` for Google Sign-In setup
- `CryptoUtils` made public with `randomNonceString(length:)` and `sha256(_:)`
- `MockCredentialProvider` in Sources for consumer testing
- `AppleSignInButton` simplified to pure UI wrapper

### Changed

- `AppleSignInButton` no longer manages loading state or error alerts — delegates entirely to caller
- `CryptoUtils.generateNonce()` renamed to `CryptoUtils.randomNonceString(length:)`
- `CryptoUtils.sha256Hash(of:)` renamed to `CryptoUtils.sha256(_:)`
- `CryptoUtils` falls back to `UInt8.random` instead of throwing on `SecRandomCopyBytes` failure

## [1.0.0] - 2026-01-23

### Added

- Initial release of ARCAuthentication
- **ARCAuthCore**: Shared DTOs for authentication
- **ARCAuthClient**: iOS authentication client with Apple provider
- Protocol-oriented architecture for extensibility
- Swift 6 strict concurrency support
- Comprehensive test suite with mocks
- DocC documentation

[Unreleased]: https://github.com/arclabs-studio/ARCAuthentication/compare/2.0.0...HEAD
[2.0.0]: https://github.com/arclabs-studio/ARCAuthentication/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/arclabs-studio/ARCAuthentication/releases/tag/1.0.0
