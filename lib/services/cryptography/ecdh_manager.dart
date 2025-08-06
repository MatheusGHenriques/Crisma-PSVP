import 'dart:convert';
import 'dart:math';
import 'package:cryptography_plus/cryptography_plus.dart';

class EcdhManager {
  final algorithm = X25519();
  final random = Random.secure();
  late SimpleKeyPair _keyPair;
  late SimplePublicKey _publicKey;
  late List<int> nonce;

  Future<void> generateKeyPair() async {
    _keyPair = await algorithm.newKeyPair();
    _publicKey = await _keyPair.extractPublicKey();
  }

  List<int> generateNonce() {
    return nonce = List<int>.generate(16, (_) => random.nextInt(256));
  }

  String getPublicKey() {
    return base64Encode(_publicKey.bytes);
  }

  Future<SecretKey> _getSecretKey(String peerPublicKey) async {
    SimplePublicKey remotePublicKey = SimplePublicKey(base64Decode(peerPublicKey), type: KeyPairType.x25519);
    return await algorithm.sharedSecretKey(keyPair: _keyPair, remotePublicKey: remotePublicKey);
  }

  Future<SecretKey> deriveAesKey(String peerPublicKey) async {
    Hkdf hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

    return await hkdf.deriveKey(
      secretKey: await _getSecretKey(peerPublicKey),
      nonce: nonce,
      info: utf8.encode('ECDH AES key'),
    );
  }
}
