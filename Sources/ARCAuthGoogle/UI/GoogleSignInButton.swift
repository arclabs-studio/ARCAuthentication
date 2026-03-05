#if canImport(SwiftUI)
import GoogleSignInSwift
import SwiftUI

/// A thin wrapper around the official `GoogleSignInButton`.
///
/// Renders the Google-branded button that complies with Google's
/// identity branding guidelines. Delegates the action entirely to the caller.
///
/// ## Usage
/// ```swift
/// GoogleSignInButton {
///     let credential = try await provider.requestCredential()
///     // Send credential to backend...
/// }
/// ```
public struct GoogleSignInButton: View {
    // MARK: - Properties

    private let style: GoogleSignInButtonStyle
    private let action: () -> Void

    // MARK: - Initialization

    /// Creates a Google Sign-In button.
    /// - Parameters:
    ///   - style: Visual style (default: `.standard`).
    ///   - action: Closure executed when the button is tapped.
    public init(style: GoogleSignInButtonStyle = .standard,
                action: @escaping () -> Void) {
        self.style = style
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        GoogleSignInSwift.GoogleSignInButton(style: style) {
            action()
        }
        .frame(height: 50)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        GoogleSignInButton(style: .standard) {}
        GoogleSignInButton(style: .wide) {}
        GoogleSignInButton(style: .icon) {}
    }
    .padding()
}
#endif
