import 'dart:convert';
import 'package:cryptography_plus/cryptography_plus.dart';

class AesManager {
  static final AesGcm _cipher = AesGcm.with256bits();

  static Future<String> encrypt(SecretKey key, String message) async {
    final plain = utf8.encode(message);
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(plain, secretKey: key, nonce: nonce);
    final full = box.concatenation();
    return base64.encode(full);
  }

  static Future<Map<String, dynamic>> decrypt(SecretKey key, String base64Message) async {
    final bytes = base64.decode(base64Message);
    final box = SecretBox.fromConcatenation(bytes, nonceLength: 12, macLength: 16);
    final plain = await _cipher.decrypt(box, secretKey: key);
    return json.decode(utf8.decode(plain)) as Map<String, dynamic>;
  }
}
