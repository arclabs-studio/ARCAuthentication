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

    /// The result to return from ``requestCredential()``.
    public var result: Result<AuthCredential, AuthenticationError>

    /// The number of times ``requestCredential()`` has been called.
    public private(set) var requestCredentialCallCount = 0

    // MARK: - Initialization

    /// Creates a mock credential provider.
    /// - Parameters:
    ///   - providerType: The provider type to report (default: `.apple`).
    ///   - result: The result to return when credentials are requested.
    public init(providerType: AuthProviderType = .apple,
                result: Result<AuthCredential, AuthenticationError> = .success(.apple(.mock))) {
        self.providerType = providerType
        self.result = result
    }

    // MARK: - CredentialProviding

    public func requestCredential() async throws -> AuthCredential {
        requestCredentialCallCount += 1
        return try result.get()
    }
}
