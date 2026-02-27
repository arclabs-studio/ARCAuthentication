import Foundation
import Testing
@testable import ARCAuthClient
@testable import ARCAuthCore

@Suite("AuthenticationState Tests")
@MainActor
struct AuthenticationStateTests {
    // MARK: - Factory

    private func makeSUT() -> AuthenticationState {
        AuthenticationState()
    }

    // MARK: - Initial State

    @Test("Should have correct initial state", .tags(.unit))
    func initialState() {
        // Given / When
        let sut = makeSUT()

        // Then
        #expect(sut.isAuthenticated == false)
        #expect(sut.currentCredential == nil)
        #expect(sut.currentProvider == nil)
        #expect(sut.isLoading == false)
        #expect(sut.lastError == nil)
    }

    // MARK: - Loading

    @Test("Should set loading to true and clear error", .tags(.unit))
    func setLoadingTrue() {
        // Given
        let sut = makeSUT()
        sut.setError(.userCancelled)

        // When
        sut.setLoading(true)

        // Then
        #expect(sut.isLoading == true)
        #expect(sut.lastError == nil)
    }

    @Test("Should set loading to false without clearing error", .tags(.unit))
    func setLoadingFalse() {
        // Given
        let sut = makeSUT()
        sut.setLoading(true)

        // When
        sut.setLoading(false)

        // Then
        #expect(sut.isLoading == false)
    }

    // MARK: - Authenticated

    @Test("Should transition to authenticated state", .tags(.unit))
    func setAuthenticated() {
        // Given
        let sut = makeSUT()
        sut.setLoading(true)
        let credential = AuthCredential(userID: "user123", provider: .apple)

        // When
        sut.setAuthenticated(with: credential)

        // Then
        #expect(sut.isAuthenticated == true)
        #expect(sut.currentCredential?.userID == "user123")
        #expect(sut.currentProvider == .apple)
        #expect(sut.isLoading == false)
        #expect(sut.lastError == nil)
    }

    // MARK: - Unauthenticated

    @Test("Should transition to unauthenticated state", .tags(.unit))
    func setUnauthenticated() {
        // Given
        let sut = makeSUT()
        let credential = AuthCredential(userID: "user123", provider: .apple)
        sut.setAuthenticated(with: credential)

        // When
        sut.setUnauthenticated()

        // Then
        #expect(sut.isAuthenticated == false)
        #expect(sut.currentCredential == nil)
        #expect(sut.currentProvider == nil)
        #expect(sut.isLoading == false)
    }

    // MARK: - Error

    @Test("Should set error and stop loading", .tags(.unit))
    func setError() {
        // Given
        let sut = makeSUT()
        sut.setLoading(true)

        // When
        sut.setError(.userCancelled)

        // Then
        #expect(sut.lastError == .userCancelled)
        #expect(sut.isLoading == false)
    }

    @Test("Should clear error", .tags(.unit))
    func clearError() {
        // Given
        let sut = makeSUT()
        sut.setError(.tokenExpired)

        // When
        sut.clearError()

        // Then
        #expect(sut.lastError == nil)
    }
}
