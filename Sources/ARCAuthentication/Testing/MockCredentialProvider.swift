import Foundation

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
public final class MockCredentialProvider: CredentialProviding, @unchecked Sendable {
    // MARK: - Properties

    public let providerType: AuthProviderType

    private let lock = NSLock()
    private var _result: Result<AuthCredential, AuthenticationError>
    private var _requestCredentialCallCount = 0

    /// The result to return from ``requestCredential()``.
    public var result: Result<AuthCredential, AuthenticationError> {
        get { lock.withLock { _result } }
        set { lock.withLock { _result = newValue } }
    }

    /// The number of times ``requestCredential()`` has been called.
    public var requestCredentialCallCount: Int {
        lock.withLock { _requestCredentialCallCount }
    }

    // MARK: - Initialization

    /// Creates a mock credential provider.
    /// - Parameters:
    ///   - providerType: The provider type to report (default: `.apple`).
    ///   - result: The result to return when credentials are requested.
    public init(providerType: AuthProviderType = .apple,
                result: Result<AuthCredential, AuthenticationError> = .success(.apple(.mock))) {
        self.providerType = providerType
        _result = result
    }

    // MARK: - CredentialProviding

    public func requestCredential() async throws -> AuthCredential {
        lock.withLock { _requestCredentialCallCount += 1 }
        return try result.get()
    }
}
