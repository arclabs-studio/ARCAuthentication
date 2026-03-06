#if canImport(UIKit)
import UIKit

extension UIApplication {
    /// Returns the key window of the foreground-active scene, falling back to the first available window.
    ///
    /// Shared by both `AppleCredentialProvider` and `GoogleCredentialProvider` to avoid duplicating
    /// `UIWindowScene` traversal. Uses `UIWindowScene.keyWindow` (available iOS 15+, required iOS 17+).
    public var arcKeyWindow: UIWindow? {
        let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first(where: { $0.activationState == .foregroundActive })?.keyWindow
            ?? scenes.flatMap(\.windows).first
    }
}
#endif
