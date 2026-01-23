import ARCAuthClient
import ARCAuthCore
import Foundation

@MainActor
final class MockAuthStorage: AuthStorageProtocol {
    var storedCredential: AuthCredential?
    var saveError: Error?
    var getError: Error?
    var deleteError: Error?

    var saveCallCount = 0
    var getCallCount = 0
    var deleteCallCount = 0

    func saveCredential(_ credential: AuthCredential) async throws {
        saveCallCount += 1
        if let error = saveError {
            throw error
        }
        storedCredential = credential
    }

    func getCredential() async throws -> AuthCredential? {
        getCallCount += 1
        if let error = getError {
            throw error
        }
        return storedCredential
    }

    func deleteCredential() async throws {
        deleteCallCount += 1
        if let error = deleteError {
            throw error
        }
        storedCredential = nil
    }

    func hasStoredCredential() async -> Bool {
        storedCredential != nil
    }
}
