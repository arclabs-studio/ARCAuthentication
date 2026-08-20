//
//  ContentView.swift
//  ARCAuthenticationDemo
//
//  Created by ARC Labs Studio on 23/01/2026.
//

import ARCAuthentication
import ARCAuthGoogle
import SwiftUI

struct ContentView: View {
    @State private var credential: AuthCredential?
    @State private var errorMessage: String?

    private let appleProvider = AppleCredentialProvider()

    /// Replace with your Google Cloud Console client ID to test
    private let googleProvider =
        GoogleCredentialProvider(configuration: GoogleConfiguration(clientID: "YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"))

    var body: some View {
        NavigationStack {
            Group {
                if let credential {
                    AuthenticatedView(credential: credential) {
                        self.credential = nil
                        errorMessage = nil
                    }
                } else {
                    LoginView(errorMessage: errorMessage,
                              onAppleSignIn: signInWithApple,
                              onGoogleSignIn: signInWithGoogle)
                }
            }
            .navigationTitle("ARCAuthentication")
        }
    }

    private func signInWithApple() {
        signIn(with: appleProvider)
    }

    private func signInWithGoogle() {
        signIn(with: googleProvider)
    }

    private func signIn(with provider: some CredentialProviding) {
        Task {
            do {
                credential = try await provider.requestCredential()
                errorMessage = nil
            } catch let error as AuthenticationError {
                if case .userCancelled = error {
                    return
                }
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    let errorMessage: String?
    let onAppleSignIn: () -> Void
    let onGoogleSignIn: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Welcome")
                    .font(.largeTitle.bold())

                Text("Sign in to continue")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 16) {
                AppleSignInButton(action: onAppleSignIn)
                GoogleSignInButton(label: .signIn, action: onGoogleSignIn)
                GoogleSignInButton(label: .signUp, action: onGoogleSignIn)
                GoogleSignInButton(label: .continue, action: onGoogleSignIn)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Authenticated View

struct AuthenticatedView: View {
    let credential: AuthCredential
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Credential Obtained!")
                .font(.largeTitle.bold())

            credentialInfo
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()

            Button(role: .destructive, action: onSignOut) {
                Text("Clear Credential")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }

    @ViewBuilder private var credentialInfo: some View {
        switch credential {
        case let .apple(apple):
            VStack(spacing: 8) {
                InfoRow(label: "Provider", value: "Apple")
                InfoRow(label: "User ID", value: String(apple.userIdentifier.prefix(20)) + "...")
                if let email = apple.email {
                    InfoRow(label: "Email", value: email)
                }
                if let name = apple.fullName?.formatted() {
                    InfoRow(label: "Name", value: name)
                }
            }
        case let .google(google):
            VStack(spacing: 8) {
                InfoRow(label: "Provider", value: "Google")
                if let name = google.displayName {
                    InfoRow(label: "Name", value: name)
                }
                if let email = google.email {
                    InfoRow(label: "Email", value: email)
                }
                if let photoURL = google.photoURL {
                    InfoRow(label: "Photo", value: photoURL.absoluteString)
                }
            }
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .font(.subheadline)
    }
}

// MARK: - Previews

#Preview("Login") {
    ContentView()
}
