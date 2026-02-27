import Foundation
import Testing
@testable import ARCAuthClient

@Suite("CryptoUtils Tests")
struct CryptoUtilsTests {
    // MARK: - Nonce Generation

    @Test("Should generate nonce with default length of 32", .tags(.unit))
    func nonceDefaultLength() throws {
        // Given / When
        let nonce = try CryptoUtils.generateNonce()

        // Then
        #expect(nonce.count == 32)
    }

    @Test("Should generate nonce with custom length", .tags(.unit))
    func nonceCustomLength() throws {
        // Given
        let lengths = [1, 16, 64, 128]

        for length in lengths {
            // When
            let nonce = try CryptoUtils.generateNonce(length: length)

            // Then
            #expect(nonce.count == length)
        }
    }

    @Test("Should generate nonce using only valid charset characters", .tags(.unit))
    func nonceCharsetValid() throws {
        // Given
        let validCharset = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        // When
        let nonce = try CryptoUtils.generateNonce(length: 256)

        // Then
        for character in nonce {
            #expect(validCharset.contains(character), "Unexpected character: \(character)")
        }
    }

    @Test("Should generate unique nonces on consecutive calls", .tags(.unit))
    func nonceUniqueness() throws {
        // Given / When
        let nonce1 = try CryptoUtils.generateNonce()
        let nonce2 = try CryptoUtils.generateNonce()

        // Then
        #expect(nonce1 != nonce2)
    }

    // MARK: - SHA256

    @Test("Should produce known SHA256 hash for known input", .tags(.unit))
    func sha256KnownVector() {
        // Given — well-known SHA256 test vector
        let input = "hello"
        let expected = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"

        // When
        let result = CryptoUtils.sha256Hash(of: input)

        // Then
        #expect(result == expected)
    }

    @Test("Should return 64-character hex string", .tags(.unit))
    func sha256OutputFormat() {
        // Given
        let input = "test input"

        // When
        let result = CryptoUtils.sha256Hash(of: input)

        // Then
        #expect(result.count == 64)
        let hexCharset = CharacterSet(charactersIn: "0123456789abcdef")
        #expect(result.unicodeScalars.allSatisfy { hexCharset.contains($0) })
    }

    @Test("Should produce different hashes for different inputs", .tags(.unit))
    func sha256DifferentInputs() {
        // Given / When
        let hash1 = CryptoUtils.sha256Hash(of: "input1")
        let hash2 = CryptoUtils.sha256Hash(of: "input2")

        // Then
        #expect(hash1 != hash2)
    }

    @Test("Should produce consistent hash for same input", .tags(.unit))
    func sha256Deterministic() {
        // Given
        let input = "deterministic test"

        // When
        let hash1 = CryptoUtils.sha256Hash(of: input)
        let hash2 = CryptoUtils.sha256Hash(of: input)

        // Then
        #expect(hash1 == hash2)
    }
}
