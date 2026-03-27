import Testing
@testable import ARCAuthentication
@testable import ARCAuthGoogle

struct GoogleCredentialProviderTests {
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

    // MARK: - SessionManaging

    #if canImport(UIKit)
    @Test("signOut() no lanza error", .tags(.unit))
    @MainActor func signOutDoesNotThrow() {
        // Given
        let sut = GoogleCredentialProvider(configuration: GoogleConfiguration(clientID: "test-id"))

        // When / Then — no debe lanzar ni crashear
        sut.signOut()
    }

    @Test("checkCredentialState() devuelve .notFound cuando no hay sesión activa", .tags(.unit))
    @MainActor func checkCredentialStateReturnsNotFoundWithoutSession() async {
        // Given — sin sign-in previo, GIDSignIn.sharedInstance.currentUser es nil
        let sut = GoogleCredentialProvider(configuration: GoogleConfiguration(clientID: "test-id"))
        sut.signOut() // garantizar sesión limpia

        // When
        let state = await sut.checkCredentialState()

        // Then
        #expect(state == .notFound)
    }
    #endif
}
