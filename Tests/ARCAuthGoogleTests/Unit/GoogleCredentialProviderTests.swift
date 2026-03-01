import Testing
@testable import ARCAuthentication
@testable import ARCAuthGoogle

@Suite("GoogleCredentialProvider Tests") struct GoogleCredentialProviderTests {
    // MARK: - GoogleConfiguration

    @Test("Should create GoogleConfiguration with client ID", .tags(.unit)) func configurationInit() {
        // Given
        let clientID = "test-client-id.apps.googleusercontent.com"

        // When
        let sut = GoogleConfiguration(clientID: clientID)

        // Then
        #expect(sut.clientID == clientID)
        #expect(sut.additionalScopes.isEmpty)
    }

    @Test("Should create GoogleConfiguration with additional scopes", .tags(.unit)) func configurationWithScopes() {
        // Given
        let scopes = ["https://www.googleapis.com/auth/drive.readonly"]

        // When
        let sut = GoogleConfiguration(clientID: "test-id",
                                      additionalScopes: scopes)

        // Then
        #expect(sut.additionalScopes == scopes)
    }

    // MARK: - Provider Type

    #if canImport(UIKit)
    @Test("Should report .google as provider type", .tags(.unit))
    @MainActor func providerType() {
        // Given
        let config = GoogleConfiguration(clientID: "test-id")
        let sut = GoogleCredentialProvider(configuration: config)

        // Then
        #expect(sut.providerType == .google)
    }
    #endif
}
