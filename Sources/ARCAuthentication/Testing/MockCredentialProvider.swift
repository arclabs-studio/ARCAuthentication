import Foundation
import os

/// A configurable mock credential provider for consumer testing.
///
/// Use this in your app's tests to simulate authentication flows
/// without triggering real provider UI.
///
/// ## Usage
/// ```swift
/// let mock = MockCredentialProvider(
///     providerType: .apple,
///     result: .success(.apple(.mock))
/// )
/// let credential = try await mock.requestCredential()
/// #expect(mock.requestCredentialCallCount == 1)
/// ```
public final class MockCredentialProvider: CredentialProviding {
    // MARK: - Properties

    public let providerType: AuthProviderType

    private struct State {
        var result: Result<AuthCredential, AuthenticationError>
        var requestCredentialCallCount = 0
    }

    private let state: OSAllocatedUnfairLock<State>

    /// The result to return from ``requestCredential()``.
    public var result: Result<AuthCredential, AuthenticationError> {
        get { state.withLock { $0.result } }
        set { state.withLock { $0.result = newValue } }
    }

    /// The number of times ``requestCredential()`` has been called.
    public var requestCredentialCallCount: Int {
        state.withLock { $0.requestCredentialCallCount }
    }

    // MARK: - Initialization

    /// Creates a mock credential provider.
    /// - Parameters:
    ///   - providerType: The provider type to report (default: `.apple`).
    ///   - result: The result to return when credentials are requested.
    public init(providerType: AuthProviderType = .apple,
                result: Result<AuthCredential, AuthenticationError> = .success(.apple(.mock))) {
        self.providerType = providerType
        state = OSAllocatedUnfairLock(initialState: State(result: result))
    }

    // MARK: - CredentialProviding

    public func requestCredential() async throws -> AuthCredential {
        let result = state.withLock { state in
            state.requestCredentialCallCount += 1
            return state.result
        }
        return try result.get()
    }
}
