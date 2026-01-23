# ``ARCAuthentication``

Sistema de autenticación modular y reutilizable para apps de ARC Labs Studio.

## Overview

ARCAuthentication proporciona una arquitectura protocol-oriented que permite autenticación mediante Sign in with Apple (SIWA) con integración preparada para un backend Vapor.

El paquete se divide en dos targets principales:

- **ARCAuthCore**: DTOs compartidos que pueden usarse tanto en cliente como en servidor Vapor
- **ARCAuthClient**: Cliente iOS con providers, storage y componentes UI

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:AddingNewProviders>

### Core Types

- ``AuthCredential``
- ``AuthProvider``
- ``ServerTokens``
- ``AuthenticationError``

### Client

- ``AuthenticationManager``
- ``AuthenticationState``
- ``AppleAuthProvider``
- ``KeychainAuthStorage``

### UI Components

- ``AppleSignInButton``

### Protocols

- ``AuthenticationProvider``
- ``AuthStorageProtocol``
- ``AuthAPIClientProtocol``
