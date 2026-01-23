//
//  ARCAuthenticationDemoApp.swift
//  ARCAuthenticationDemo
//
//  Created by ARC Labs Studio on 23/01/2026.
//

import ARCAuthClient
import ARCAuthCore
import SwiftUI

@main
struct ARCAuthenticationDemoApp: App {
    @StateObject private var authManager: AuthenticationManager = {
        let manager = AuthenticationManager()
        manager.register(provider: AppleAuthProvider())
        return manager
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .task {
                    await authManager.restoreSession()
                }
        }
    }
}
