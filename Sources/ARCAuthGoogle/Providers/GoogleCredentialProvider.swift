#if canImport(UIKit)
import ARCAuthentication
import GoogleSignIn
import UIKit

/// Credential provider for Google Sign-In.
///
/// Implements the Google Sign-In flow using the GoogleSignIn SDK and
/// returns a ``GoogleCredential`` wrapped in ``AuthCredential/google(_:)``.
///
/// ## Usage
/// ```swift
/// let config = GoogleConfiguration(clientID: "your-client-id")
/// let provider = GoogleCredentialProvider(configuration: config)
/// let credential = try await provider.requestCredential()
/// ```
@MainActor
public final class GoogleCredentialProvider: CredentialProviding, @unchecked Sendable {
    // MARK: - Properties

    public let providerType: AuthProviderType = .google

    private let configuration: GoogleConfiguration

    // MARK: - Initialization

    /// Creates a Google credential provider.
    /// - Parameter configuration: The Google Sign-In configuration.
    public init(configuration: GoogleConfiguration) {
        self.configuration = configuration
    }

    // MARK: - CredentialProviding

    public func requestCredential() async throws -> AuthCredential {
        guard let presentingViewController = findPresentingViewController() else {
            throw AuthenticationError.systemError("Unable to find a presenting view controller")
        }

        let config = GIDConfiguration(clientID: configuration.clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result: GIDSignInResult
        do {
            if configuration.additionalScopes.isEmpty {
                result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            } else {
                result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController,
                                                                   hint: nil,
                                                                   additionalScopes: configuration.additionalScopes)
            }
        } catch {
            throw GoogleAuthErrorMapper.mapError(error)
        }

        let user = result.user

        guard let idToken = user.idToken?.tokenString else {
            throw AuthenticationError.invalidIdentityToken
        }

        let credential = GoogleCredential(idToken: idToken,
                                          accessToken: user.accessToken.tokenString,
                                          displayName: user.profile?.name,
                                          email: user.profile?.email,
                                          photoURL: user.profile?.imageURL(withDimension: 200))

        return .google(credential)
    }

    // MARK: - Private Methods

    private func findPresentingViewController() -> UIViewController? {
        guard let rootVC = UIApplication.shared.arcKeyWindow?.rootViewController else {
            return nil
        }
        return topViewController(of: rootVC)
    }

    private func topViewController(of viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return topViewController(of: presented)
        }
        if let nav = viewController as? UINavigationController,
           let visible = nav.visibleViewController {
            return topViewController(of: visible)
        }
        if let tab = viewController as? UITabBarController,
           let selected = tab.selectedViewController {
            return topViewController(of: selected)
        }
        return viewController
    }
}
#endif
