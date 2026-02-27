import Foundation
import Testing
@testable import ARCAuthCore

@Suite("LoginRequest Tests")
struct LoginRequestTests {
    @Test("Should initialize with email and password", .tags(.unit))
    func initWithParameters() {
        // Given / When
        let sut = LoginRequest(email: "user@example.com", password: "secret123")

        // Then
        #expect(sut.email == "user@example.com")
        #expect(sut.password == "secret123")
    }

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let sut = LoginRequest(email: "user@example.com", password: "secret123")

        // When
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(LoginRequest.self, from: data)

        // Then
        #expect(decoded.email == sut.email)
        #expect(decoded.password == sut.password)
    }
}

@Suite("SignUpRequest Tests")
struct SignUpRequestTests {
    @Test("Should initialize with all parameters", .tags(.unit))
    func initWithAllParameters() {
        // Given / When
        let sut = SignUpRequest(
            email: "user@example.com",
            password: "secret123",
            displayName: "Test User"
        )

        // Then
        #expect(sut.email == "user@example.com")
        #expect(sut.password == "secret123")
        #expect(sut.displayName == "Test User")
    }

    @Test("Should initialize without display name", .tags(.unit))
    func initWithoutDisplayName() {
        // Given / When
        let sut = SignUpRequest(email: "user@example.com", password: "secret123")

        // Then
        #expect(sut.displayName == nil)
    }

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let sut = SignUpRequest(
            email: "user@example.com",
            password: "secret123",
            displayName: "Test User"
        )

        // When
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(SignUpRequest.self, from: data)

        // Then
        #expect(decoded.email == sut.email)
        #expect(decoded.password == sut.password)
        #expect(decoded.displayName == sut.displayName)
    }
}

@Suite("RefreshTokenRequest Tests")
struct RefreshTokenRequestTests {
    @Test("Should initialize with refresh token", .tags(.unit))
    func initWithRefreshToken() {
        // Given / When
        let sut = RefreshTokenRequest(refreshToken: "refresh_abc123")

        // Then
        #expect(sut.refreshToken == "refresh_abc123")
    }

    @Test("Should encode and decode correctly", .tags(.unit))
    func codableRoundTrip() throws {
        // Given
        let sut = RefreshTokenRequest(refreshToken: "refresh_abc123")

        // When
        let data = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(RefreshTokenRequest.self, from: data)

        // Then
        #expect(decoded.refreshToken == sut.refreshToken)
    }
}
