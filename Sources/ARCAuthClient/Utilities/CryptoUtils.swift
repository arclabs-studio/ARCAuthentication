import CryptoKit
import Foundation

/// Internal cryptographic utilities for authentication flows.
///
/// Used by `AppleAuthProvider` to generate nonces and compute SHA256 hashes
/// for Sign in with Apple's anti-replay protection.
enum CryptoUtils {
    /// Character set for nonce generation.
    static let nonceCharset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    /// Generates a cryptographically random nonce string.
    /// - Parameter length: Length of the nonce (default: 32).
    /// - Returns: Random string composed of alphanumeric and punctuation characters.
    /// - Throws: If `SecRandomCopyBytes` fails.
    static func generateNonce(length: Int = 32) throws -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        guard errorCode == errSecSuccess else {
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: Int(errorCode),
                userInfo: [NSLocalizedDescriptionKey: "SecRandomCopyBytes failed with OSStatus \(errorCode)"]
            )
        }

        return String(randomBytes.map { nonceCharset[Int($0) % nonceCharset.count] })
    }

    /// Computes the SHA256 hash of a string and returns it as a hex-encoded string.
    /// - Parameter input: The string to hash.
    /// - Returns: 64-character lowercase hex string.
    static func sha256Hash(of input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
