# Crisma PSVP

> Secure offline-first peer-to-peer communication platform for local events - no internet, no centralized servers.

Crisma PSVP was developed for the Confirmation retreat of **Paróquia São Vicente de Paulo** (Belo Horizonte, Brazil), replacing traditional radio communicators with a multiplatform Flutter application that runs entirely over local Wi-Fi/LAN networks without internet access or centralized servers - enabling secure real-time communication, task management, polls and PDF sharing directly between smartphones and computers.

## Screenshots

| Home | Chat | Tasks |
|---|---|---|
| ![home](home_main_theme.jpeg) | ![chat](chat_page.jpeg) | ![tasks](tasks_page.jpeg) |

## Features

### Offline-First P2P Networking
- Automatic peer discovery via UDP broadcast
- Reliable peer-to-peer communication over TCP sockets
- Fully functional without internet access or external servers
- Automatic reconnection and inactive peer removal
- Real-time connected user synchronization

### Secure Group-Based Authentication
- Authentication using team passwords
- 256-bit key derivation with Argon2id
- Secure persistence using Android Keystore, Apple Keychain, Windows Credential Manager and Linux libsecret
- Persistent authenticated sessions across app restarts

### End-to-End Encrypted Communication
- ECDH X25519 handshake for ephemeral session key exchange
- AES-GCM encrypted communication channels
- Confidentiality and integrity protection for exchanged data
- Encrypted local message storage

### Collaboration Features
- Real-time messaging
- Task management system
- Poll creation and voting
- PDF synchronization and visualization
- Local notifications for events and updates

### User Experience
- Light and dark themes
- Multiple color palettes
- Real-time theme switching
- Lottie animations
- Integrated PDF viewer

## Security Architecture

Crisma PSVP uses a layered security architecture designed for fully offline environments.

### Key Derivation

Group passwords are never stored directly.

A 256-bit `groupKey` is derived using **Argon2id** and securely persisted through `flutter_secure_storage`, leveraging Android Keystore, Apple Keychain, Windows Credential Manager and Linux libsecret. The derivation process runs in a background isolate to avoid blocking the UI. On logout, the `groupKey` is wiped from Secure Storage.

### Message Encryption

Each message is encrypted with a random **AES-GCM** `contentKey`. This `contentKey` is then wrapped (encrypted) with the `groupKey` of each destination group - a multi-wrap envelope scheme. Only peers holding the correct `groupKey` can unwrap the `contentKey` and decrypt the message content.

### Transport Security

Each TCP connection performs an **ECDH X25519** handshake to establish an ephemeral shared secret. All subsequent traffic on that connection is encrypted using **AES-GCM**, providing confidentiality, integrity and forward secrecy at the transport layer.

### Secure Local Storage

Messages are stored locally using Hive with encrypted content. Decryption occurs only at display time and only if the user holds the corresponding `groupKey`. Sensitive cryptographic material is isolated in Secure Storage and removed on logout.

### Threat Model Considerations

On rooted or jailbroken devices, platform secure storage guarantees may be weakened or bypassed by privileged attackers.

## Tech Stack

| Layer | Technologies |
|---|---|
| Framework | Flutter / Dart |
| Networking | UDP Broadcast, TCP Sockets |
| Cryptography | ECDH X25519, AES-GCM, Argon2id |
| Storage | Hive, flutter_secure_storage |
| UI | Lottie, flutter_pdfview |

## Getting Started

> Tested on Android and Linux desktop environments.

### Install APK (Android)

APK files are available in the [`/apks`](./apks) directory.

### Build From Source

Clone the repository:

```sh
git clone https://github.com/MatheusGHenriques/Crisma-PSVP.git
cd Crisma-PSVP
```

Install dependencies:

```sh
flutter pub get
```

Run the application:

```sh
flutter run
```

> Flutter SDK required.

## Project Status

### Implemented

- Local peer discovery and P2P communication
- Group authentication with Argon2id key derivation
- ECDH X25519 + AES-GCM encrypted transport
- End-to-end encrypted messaging
- Encrypted local message storage (Hive)
- Task management, polls and PDF synchronization
- Local notifications

### Planned

- Encryption for tasks, polls and PDFs
- Biometric / PIN app lock

## License

This software is proprietary.

Usage is permitted for:
- **Testing and evaluation** - permitted without prior authorization

Any other usage requires prior permission from the author.

[matheusghenriques@proton.me](mailto:matheusghenriques@proton.me)
