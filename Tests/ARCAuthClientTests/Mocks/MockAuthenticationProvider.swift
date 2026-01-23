import ARCAuthClient
import ARCAuthCore
import Foundation

@MainActor
final class MockAuthenticationProvider: AuthenticationProvider {
    let providerID: String
    let displayName: String
    var isAvailable = true

    var authenticateResult: Result<AuthCredential, Error> = .success(
        AuthCredential(userID: "mock_user", provider: .apple)
    )
    var authenticateCallCount = 0

    var signOutError: Error?
    var signOutCallCount = 0

    var credentialState: CredentialState = .authorized

    init(providerID: String = "mock", displayName: String = "Mock") {
        self.providerID = providerID
        self.displayName = displayName
    }

    func authenticate() async throws -> AuthCredential {
        authenticateCallCount += 1
        return try authenticateResult.get()
    }

    func signOut() async throws {
        signOutCallCount += 1
        if let error = signOutError {
            throw error
        }
    }

    func checkCredentialState() async -> CredentialState {
        credentialState
    }
}
