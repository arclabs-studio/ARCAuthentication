/// Constantes globales de ARCAuthentication.
public enum AuthConstants {
    /// Constantes relacionadas con el almacenamiento en Keychain.
    public enum Keychain {
        /// Access group compartido entre todas las apps de ARC Labs Studio.
        ///
        /// Permite que FavRes, FavBook, FavPrint y futuras apps compartan la sesión
        /// del usuario mediante Keychain Sharing, sin necesidad de backend propio.
        ///
        /// ## Configuración requerida
        ///
        /// Cada app que use este grupo debe tener la capability **Keychain Sharing**
        /// activada en Xcode con el mismo identificador de grupo.
        ///
        /// ## Uso
        /// ```swift
        /// let storage = KeychainAuthStorage(accessGroup: AuthConstants.Keychain.sharedAccessGroup)
        /// ```
        ///
        /// - Important: Sustituye `$(TeamID)` por el Team ID real de tu cuenta de desarrollador
        ///   Apple antes de usar este valor en producción.
        public static let sharedAccessGroup = "$(TeamID).com.arclabs.shared"
    }
}
