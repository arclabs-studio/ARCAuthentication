import Testing
@testable import ARCAuthentication

/// Los tests de Keychain acceden al mismo slot externo (servicio "com.arclabs.arcauthentication" / "current").
/// .serialized garantiza ejecución secuencial para evitar errSecDuplicateItem (-25299).
@Suite(.serialized)
struct KeychainAuthStorageTests {
    // MARK: - Initialization

    @Test("Debe crear un almacén con accessGroup sin lanzar errores", .tags(.unit))
    func initWithAccessGroupCreatesStorage() {
        // Given / When
        let sut = KeychainAuthStorage(accessGroup: "com.test.shared")

        // Then — la instancia se crea correctamente (no crashea ni lanza en init)
        _ = sut
    }

    @Test("Debe crear un almacén sin accessGroup sin lanzar errores", .tags(.unit))
    func initWithoutAccessGroupCreatesStorage() {
        // Given / When
        let sut = KeychainAuthStorage()

        // Then
        _ = sut
    }

    // MARK: - Save & Load

    @Test("Debe guardar y recuperar una credencial Apple", .tags(.unit))
    func saveAndLoadAppleCredential() async throws {
        // Given
        let sut = makeSUT()
        let credential = AuthCredential.apple(.mock)

        // When
        try await sut.save(credential)
        let loaded = try await sut.load()

        // Then
        #expect(loaded == credential)

        // Cleanup
        try await sut.delete()
    }

    @Test("Debe guardar y recuperar una credencial Google", .tags(.unit))
    func saveAndLoadGoogleCredential() async throws {
        // Given
        let sut = makeSUT()
        let credential = AuthCredential.google(.mock)

        // When
        try await sut.save(credential)
        let loaded = try await sut.load()

        // Then
        #expect(loaded == credential)

        // Cleanup
        try await sut.delete()
    }

    @Test("Debe devolver nil cuando no hay credencial guardada", .tags(.unit))
    func loadReturnsNilWhenEmpty() async throws {
        // Given
        let sut = makeSUT()
        try await sut.delete() // asegurar estado limpio

        // When
        let loaded = try await sut.load()

        // Then
        #expect(loaded == nil)
    }

    @Test("Debe sobreescribir la credencial existente al guardar de nuevo", .tags(.unit))
    func saveOverwritesExistingCredential() async throws {
        // Given
        let sut = makeSUT()
        let first = AuthCredential.apple(.mock)
        let second = AuthCredential.google(.mock)

        // When
        try await sut.save(first)
        try await sut.save(second)
        let loaded = try await sut.load()

        // Then
        #expect(loaded == second)

        // Cleanup
        try await sut.delete()
    }

    // MARK: - Delete

    @Test("Debe eliminar la credencial correctamente", .tags(.unit)) func deleteRemovesCredential() async throws {
        // Given
        let sut = makeSUT()
        try await sut.save(.apple(.mock))

        // When
        try await sut.delete()
        let loaded = try await sut.load()

        // Then
        #expect(loaded == nil)
    }

    @Test("Delete no lanza error cuando no hay credencial guardada", .tags(.unit))
    func deleteOnEmptyStorageDoesNotThrow() async throws {
        // Given
        let sut = makeSUT()
        try await sut.delete() // vaciar primero

        // When / Then — no debe lanzar
        try await sut.delete()
    }

    // MARK: - Shared Access

    @Test("Dos instancias sin accessGroup comparten el mismo slot del Keychain", .tags(.unit))
    func twoInstancesShareSameKeychainSlot() async throws {
        // Given — dos instancias apuntan al mismo servicio ("com.arclabs.arcauthentication")
        let writer = KeychainAuthStorage()
        let reader = KeychainAuthStorage()
        try await writer.delete()

        // When — escribir desde una instancia
        try await writer.save(.apple(.mock))

        // Then — la otra instancia ve el mismo dato
        let loaded = try await reader.load()
        #expect(loaded == .apple(.mock))

        // Cleanup
        try await writer.delete()
    }

    // MARK: - Factory

    /// Crea un almacén sin accessGroup para tests (no requiere entitlement en macOS).
    private func makeSUT() -> KeychainAuthStorage {
        KeychainAuthStorage()
    }
}
