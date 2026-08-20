import CryptoKit
import Foundation

/// Cryptographic utilities for authentication flows.
///
/// Provides nonce generation and hashing used by credential providers
/// for anti-replay protection (e.g., Sign in with Apple).
///
/// ## Usage
/// ```swift
/// let nonce = CryptoUtils.randomNonceString()
/// let hashed = CryptoUtils.sha256(nonce)
/// ```
public enum CryptoUtils {
    /// Character set for nonce generation.
    private static let nonceCharset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    /// Generates a cryptographically random nonce string.
    ///
    /// Uses `SecRandomCopyBytes` for secure randomness with a fallback
    /// to `UInt8.random(in:)` if the system call fails.
    ///
    /// - Parameter length: Length of the nonce (default: 32).
    /// - Returns: Random string composed of alphanumeric and punctuation characters.
    public static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if errorCode != errSecSuccess {
            // Fallback to UInt8.random
            randomBytes = (0 ..< length).map { _ in UInt8.random(in: 0 ... 255) }
        }

        return String(randomBytes.map { nonceCharset[Int($0) % nonceCharset.count] })
    }

    /// Computes the SHA-256 hash of a string and returns it as a hex-encoded string.
    ///
    /// - Parameter input: The string to hash.
    /// - Returns: 64-character lowercase hex string.
    public static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
