import Foundation
import Testing
@testable import ARCAuthentication

@Suite("AuthCredential Tests")
struct AuthCredentialTests {
    // MARK: - AppleCredential

    @Test("Should create AppleCredential with all properties", .tags(.unit))
    func appleCredentialInit() {
        // Given
        let token = Data("token".utf8)
        let code = Data("code".utf8)
        let nonce = "test-nonce"
        let email = "test@example.com"
        let userID = "user-123"

        // When
        let sut = AppleCredential(
            identityToken: token,
            authorizationCode: code,
            nonce: nonce,
            email: email,
            userIdentifier: userID
        )

        // Then
        #expect(sut.identityToken == token)
        #expect(sut.authorizationCode == code)
        #expect(sut.nonce == nonce)
        #expect(sut.fullName == nil)
        #expect(sut.email == email)
        #expect(sut.userIdentifier == userID)
    }

    @Test("Should support Equatable for AppleCredential", .tags(.unit))
    func appleCredentialEquatable() {
        // Given
        let credential1 = AppleCredential.mock
        let credential2 = AppleCredential.mock

        // Then
        #expect(credential1 == credential2)
    }

    @Test("Should detect inequality for different AppleCredentials", .tags(.unit))
    func appleCredentialInequality() {
        // Given
        let credential1 = AppleCredential.mock
        let credential2 = AppleCredential(
            identityToken: Data("other".utf8),
            authorizationCode: Data("other".utf8),
            nonce: "other",
            userIdentifier: "other-user"
        )

        // Then
        #expect(credential1 != credential2)
    }

    @Test("Should provide mock AppleCredential with valid data", .tags(.unit))
    func appleCredentialMock() {
        // Given / When
        let sut = AppleCredential.mock

        // Then
        #expect(!sut.identityToken.isEmpty)
        #expect(!sut.authorizationCode.isEmpty)
        #expect(!sut.nonce.isEmpty)
        #expect(sut.fullName != nil)
        #expect(sut.email != nil)
        #expect(!sut.userIdentifier.isEmpty)
    }

    // MARK: - GoogleCredential

    @Test("Should create GoogleCredential with all properties", .tags(.unit))
    func googleCredentialInit() {
        // Given
        let idToken = "id-token"
        let accessToken = "access-token"
        let name = "John Doe"
        let email = "john@gmail.com"
        let photo = URL(string: "https://example.com/photo.jpg")

        // When
        let sut = GoogleCredential(
            idToken: idToken,
            accessToken: accessToken,
            displayName: name,
            email: email,
            photoURL: photo
        )

        // Then
        #expect(sut.idToken == idToken)
        #expect(sut.accessToken == accessToken)
        #expect(sut.displayName == name)
        #expect(sut.email == email)
        #expect(sut.photoURL == photo)
    }

    @Test("Should support Equatable for GoogleCredential", .tags(.unit))
    func googleCredentialEquatable() {
        // Given
        let credential1 = GoogleCredential.mock
        let credential2 = GoogleCredential.mock

        // Then
        #expect(credential1 == credential2)
    }

    @Test("Should provide mock GoogleCredential with valid data", .tags(.unit))
    func googleCredentialMock() {
        // Given / When
        let sut = GoogleCredential.mock

        // Then
        #expect(!sut.idToken.isEmpty)
        #expect(!sut.accessToken.isEmpty)
        #expect(sut.displayName != nil)
        #expect(sut.email != nil)
        #expect(sut.photoURL != nil)
    }

    // MARK: - AuthCredential Enum

    @Test("Should wrap AppleCredential in .apple case", .tags(.unit))
    func authCredentialAppleCase() {
        // Given
        let apple = AppleCredential.mock

        // When
        let sut = AuthCredential.apple(apple)

        // Then
        if case let .apple(credential) = sut {
            #expect(credential == apple)
        } else {
            Issue.record("Expected .apple case")
        }
    }

    @Test("Should wrap GoogleCredential in .google case", .tags(.unit))
    func authCredentialGoogleCase() {
        // Given
        let google = GoogleCredential.mock

        // When
        let sut = AuthCredential.google(google)

        // Then
        if case let .google(credential) = sut {
            #expect(credential == google)
        } else {
            Issue.record("Expected .google case")
        }
    }

    @Test("Should support Equatable for AuthCredential", .tags(.unit))
    func authCredentialEquatable() {
        // Given
        let apple1 = AuthCredential.apple(.mock)
        let apple2 = AuthCredential.apple(.mock)
        let google = AuthCredential.google(.mock)

        // Then
        #expect(apple1 == apple2)
        #expect(apple1 != google)
    }
}
