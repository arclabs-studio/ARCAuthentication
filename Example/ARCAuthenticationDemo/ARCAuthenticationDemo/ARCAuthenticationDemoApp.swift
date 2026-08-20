//
//  ARCAuthenticationDemoApp.swift
//  ARCAuthenticationDemo
//
//  Created by ARC Labs Studio on 23/01/2026.
//

import ARCAuthentication
import GoogleSignIn
import SwiftUI

@main
struct ARCAuthenticationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
