# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-20

First public release of **ARCAuthentication**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (1.0.0 → 2.0.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

- `AuthConstants.Keychain.sharedAccessGroup` — constante del Keychain Access Group compartido entre apps ARC Labs Studio (FavRes, FavBook, FavPrint y futuras apps Fav*)
- `KeychainAuthStorage` — almacén seguro de `AuthCredential` en el Keychain con soporte de Keychain Access Group para SSO entre apps; incluye `init()` y `init(accessGroup:)`
- `CredentialState` enum con casos `.authorized`, `.notFound`, `.revoked`
- `SessionManaging` protocol con `signOut()` y `checkCredentialState() async -> CredentialState`
- `AppleCredentialProvider` conforma a `SessionManaging`: `signOut()` limpia el estado en memoria, `checkCredentialState()` consulta `ASAuthorizationAppleIDProvider`
- `GoogleCredentialProvider` conforma a `SessionManaging`: `signOut()` llama a `GIDSignIn.sharedInstance.signOut()`, `checkCredentialState()` comprueba `GIDSignIn.sharedInstance.currentUser`
- Dependencia `ARCStorage` para `KeychainAuthStorage`
- Sección "Shared Keychain SSO" en la guía de inicio de DocC
- `ARCAppleButtonLabel` enum wrapping `SignInWithAppleButton.Label` cases (`.signIn`, `.signUp`, `.continue`) — callers no longer need to `import AuthenticationServices` to use `AppleSignInButton`
- Google Sign-In to the demo app alongside Sign in with Apple
- Demo app README with full Google Sign-In configuration guide
- Comprehensive documentation for Google Sign-In setup in DocC Getting Started guide
- URL scheme and `onOpenURL` handler in demo app for Google OAuth callback

### Changed

- `AuthCredential`, `AppleCredential`, `GoogleCredential` conforman ahora a `Codable` (cambio aditivo, sin breaking changes en la API existente)

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [2.0.0] - 2026-02-27

#### Breaking Changes

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

#### Added

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

#### Changed

- `AppleSignInButton` no longer manages loading state or error alerts — delegates entirely to caller
- `CryptoUtils.generateNonce()` renamed to `CryptoUtils.randomNonceString(length:)`
- `CryptoUtils.sha256Hash(of:)` renamed to `CryptoUtils.sha256(_:)`
- `CryptoUtils` falls back to `UInt8.random` instead of throwing on `SecRandomCopyBytes` failure

---

### [1.0.0] - 2026-01-23

#### Added

- Initial release of ARCAuthentication
- **ARCAuthCore**: Shared DTOs for authentication
- **ARCAuthClient**: iOS authentication client with Apple provider
- Protocol-oriented architecture for extensibility
- Swift 6 strict concurrency support
- Comprehensive test suite with mocks
- DocC documentation

[Unreleased]: https://github.com/arclabs-studio/ARCAuthentication/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/arclabs-studio/ARCAuthentication/releases/tag/v1.0.0

<!-- 2.0.0 has no published git tag yet; restore the link once v2.0.0 is tagged. -->
<!-- [2.0.0]: https://github.com/arclabs-studio/ARCAuthentication/compare/v1.0.0...v2.0.0 -->

---

[1.0.0]: https://github.com/arclabs-studio/ARCAuthentication/releases/tag/v1.0.0
