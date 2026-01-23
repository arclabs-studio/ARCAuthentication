# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-23

### Added

- Initial release of ARCAuthentication
- **ARCAuthCore**: Shared DTOs for authentication
  - `AuthCredential` - User credentials structure
  - `AuthProvider` - Supported authentication providers enum
  - `ServerTokens` - Server-provided tokens structure
  - `AppleAuthPayload` - Payload for Apple Sign In verification
  - `TokenResponse` - Server token response DTO
  - `UserDTO` and `UserProfileDTO` - User data transfer objects
  - `AuthenticationError` - Comprehensive error handling
  - `AuthConstants` - Configuration constants
- **ARCAuthClient**: iOS authentication client
  - `AuthenticationManager` - Central authentication coordinator
  - `AuthenticationState` - Observable authentication state
  - `AuthenticationConfiguration` - Manager configuration
  - `AppleAuthProvider` - Sign in with Apple implementation
  - `KeychainAuthStorage` - Secure credential storage via ARCStorage
  - `AuthAPIClient` - HTTP client for backend (placeholder)
  - `AppleSignInButton` - SwiftUI button component
  - `AuthenticationViewModifier` - Convenience view modifier
- Protocol-oriented architecture for extensibility
- Swift 6 strict concurrency support
- Comprehensive test suite with mocks
- DocC documentation

[Unreleased]: https://github.com/arclabs-studio/ARCAuthentication/compare/1.0.0...HEAD
[1.0.0]: https://github.com/arclabs-studio/ARCAuthentication/releases/tag/1.0.0
