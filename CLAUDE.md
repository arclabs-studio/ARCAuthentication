# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Package Is

ARCAuthentication is a **backend-agnostic credential provider** for iOS/macOS. It runs the platform sign-in flows (Sign in with Apple, Google Sign-In) and returns raw credentials. It does **not** manage sessions, tokens, or backend communication — that's the consumer's responsibility.

Two library targets:
- **ARCAuthentication** — Core: protocols, models, Apple provider, `CryptoUtils`, `MockCredentialProvider`. Zero external dependencies.
- **ARCAuthGoogle** — Google Sign-In provider. Depends on `ARCAuthentication` + GoogleSignIn SDK.

## Build & Test Commands

```bash
swift build              # Build both targets
swift test --parallel    # Run all tests (48 tests across 8 suites on macOS)
make lint                # SwiftLint (config: .swiftlint.yml)
make format              # SwiftFormat dry-run (config: .swiftformat)
make fix                 # Apply SwiftFormat
make clean               # rm -rf .build DerivedData
```

Run a single test by name:
```bash
swift test --filter "CryptoUtilsTests/nonceDefaultLength"
```

Run a single test suite:
```bash
swift test --filter "CryptoUtilsTests"
```

Tests run on **macOS** via `swift test`. UIKit-dependent code (`AppleCredentialProvider`, `GoogleCredentialProvider`, `AppleSignInButton`) is behind `#if canImport(UIKit)` and cannot be tested directly — only `AppleAuthErrorMapper` (behind `#if canImport(AuthenticationServices)`) is testable on macOS.

## Architecture

### Core Protocol

`CredentialProviding` — the single protocol all providers implement:
```
providerType: AuthProviderType
requestCredential() async throws -> AuthCredential
```

`AuthCredential` is an enum: `.apple(AppleCredential)` or `.google(GoogleCredential)`. Each case wraps a provider-specific struct with the raw tokens/metadata needed for backend verification.

### Platform Guards

This is critical for understanding compilation:
- `AppleAuthErrorMapper` → `#if canImport(AuthenticationServices)` (works on macOS + iOS)
- `AppleCredentialProvider` → `#if canImport(AuthenticationServices) && canImport(UIKit)` (iOS only)
- `AppleSignInButton` → `#if canImport(AuthenticationServices) && canImport(UIKit)` (iOS only)
- `GoogleCredentialProvider` → `#if canImport(UIKit)` (iOS only)

Error mapping is deliberately separated from the provider classes so it can be tested on macOS.

### Concurrency Model

Swift 6 strict concurrency (`swiftLanguageModes: [.v6]`). Providers use:
- `@MainActor` on provider classes (UI presentation)
- `@unchecked Sendable` on classes with mutable state guarded by the actor
- `nonisolated` delegate methods that hop back with `Task { @MainActor in }`
- `CheckedContinuation` to bridge delegate callbacks to async/await

### Testing Conventions

- **Framework:** Swift Testing (not XCTest)
- **Tags:** `.unit`, `.integration` (defined in `Tests/*/Tags.swift`)
- **Pattern:** Given/When/Then with `@Test("description", .tags(.unit))`
- **Mocks:** `MockCredentialProvider` ships in Sources (not Tests) for consumer use. Both credential types have `.mock` static properties.

## Demo App

`Example/ARCAuthenticationDemo/` — Xcode project (not SPM) that demonstrates both providers. Sign in with Apple works on Simulator without configuration. Google Sign-In requires a Google Cloud Console client ID configured in `ContentView.swift` and `Info.plist` build settings (`GOOGLE_CLIENT_ID`, `GOOGLE_REVERSED_CLIENT_ID`).

Build the demo app:
```bash
xcodebuild -project Example/ARCAuthenticationDemo/ARCAuthenticationDemo.xcodeproj \
  -scheme ARCAuthenticationDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## CI

GitHub Actions workflows (`.github/workflows/`):
- **tests.yml** — `swift test --parallel` on macOS-15 (Linux skipped due to platform constraints)
- **quality.yml** — SwiftLint (`--strict`) + SwiftFormat (`--lint`) + markdown link check
- **enforce-gitflow.yml** — Validates branch targeting rules for PRs

## Git Conventions

- **Branches:** `feature/`, `bugfix/`, `hotfix/`, `docs/` prefixes
- **Commits:** Conventional Commits (`feat(scope):`, `fix(scope):`, `docs:`, `test:`, `refactor:`, `chore:`)
- **PRs:** `feature/*` → `develop`, `develop` → `main`. Direct pushes to `main` are blocked.
- Pre-commit hooks run SwiftLint/SwiftFormat on staged Swift files (installed via `make setup`).

## Linting Rules to Know

- `force_unwrapping` is an **opt-in error** — never use `!` in Sources or Tests
- `no_force_cast` and `no_force_try` are **custom rules** at error severity
- Line length: 120 warning, 150 error (URLs and function declarations exempt)
- `@Observable` is required for ViewModels (custom `observable_viewmodel` rule)
- SwiftFormat: 4-space indent, 120 max width, `--self remove`, `--allman false`
