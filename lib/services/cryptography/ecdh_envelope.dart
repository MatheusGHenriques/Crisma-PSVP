import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography_plus/cryptography_plus.dart';

class EcdhEnvelope {
  static final X25519 _ecdh = X25519();
  static final AesGcm _aes = AesGcm.with256bits();
  static final Hkdf _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  static Future<Map<String, String>> encrypt({
    required String plainText,
    required String groupPublicKeyBase64,
  }) async {
    final ephemeralKeyPair = await _ecdh.newKeyPair();
    final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKey();

    final groupPublicKey = SimplePublicKey(
      base64Decode(groupPublicKeyBase64),
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _ecdh.sharedSecretKey(
      keyPair: ephemeralKeyPair,
      remotePublicKey: groupPublicKey,
    );

    final aesKey = await _hkdf.deriveKey(
      secretKey: sharedSecret,
      nonce: ephemeralPublicKey.bytes,
      info: utf8.encode('crisma-ecdh-envelope'),
    );

    final nonce = _aes.newNonce();
    final box = await _aes.encrypt(
      utf8.encode(plainText),
      secretKey: aesKey,
      nonce: nonce,
    );

    return {
      'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
      'nonce': base64Encode(nonce),
      'ephemeral_public_key': base64Encode(ephemeralPublicKey.bytes),
    };
  }

  static Future<String> decrypt({
    required Map<String, String> envelope,
    required Uint8List groupPrivateKeyBytes,
    required String groupPublicKeyBase64,
  }) async {
    final groupKeyPair = SimpleKeyPairData(
      groupPrivateKeyBytes,
      publicKey: SimplePublicKey(
        base64Decode(groupPublicKeyBase64),
        type: KeyPairType.x25519,
      ),
      type: KeyPairType.x25519,
    );

    final ephemeralPublicKey = SimplePublicKey(
      base64Decode(envelope['ephemeral_public_key']!),
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _ecdh.sharedSecretKey(
      keyPair: groupKeyPair,
      remotePublicKey: ephemeralPublicKey,
    );

    final aesKey = await _hkdf.deriveKey(
      secretKey: sharedSecret,
      nonce: ephemeralPublicKey.bytes,
      info: utf8.encode('crisma-ecdh-envelope'),
    );

    final box = SecretBox(
      base64Decode(envelope['ciphertext']!),
      nonce: base64Decode(envelope['nonce']!),
      mac: Mac(base64Decode(envelope['mac']!)),
    );

    final plainBytes = await _aes.decrypt(box, secretKey: aesKey);
    return utf8.decode(plainBytes);
  }
}
