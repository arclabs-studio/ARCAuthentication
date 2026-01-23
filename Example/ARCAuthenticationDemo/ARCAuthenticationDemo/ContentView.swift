//
//  ContentView.swift
//  ARCAuthenticationDemo
//
//  Created by ARC Labs Studio on 23/01/2026.
//

import ARCAuthClient
import ARCAuthCore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        NavigationStack {
            Group {
                if authManager.state.isAuthenticated {
                    AuthenticatedView()
                } else {
                    LoginView()
                }
            }
            .navigationTitle("ARCAuthentication")
        }
    }
}

// MARK: - Login View

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager

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

            Spacer()

            AppleSignInButton {
                try await authManager.authenticate(with: "apple")
            }
            .frame(height: 50)
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Authenticated View

struct AuthenticatedView: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Authenticated!")
                .font(.largeTitle.bold())

            if let credential = authManager.state.currentCredential {
                VStack(spacing: 8) {
                    InfoRow(label: "User ID", value: String(credential.userID.prefix(20)) + "...")
                    InfoRow(label: "Provider", value: credential.provider.displayName)
                    if let email = credential.email {
                        InfoRow(label: "Email", value: email)
                    }
                    if let displayName = credential.displayName {
                        InfoRow(label: "Name", value: displayName)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            Button(role: .destructive) {
                Task {
                    try await authManager.signOut()
                }
            } label: {
                Text("Sign Out")
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
        }
        .font(.subheadline)
    }
}

// MARK: - Previews

#Preview("Login") {
    let manager = AuthenticationManager()
    return ContentView()
        .environmentObject(manager)
}
