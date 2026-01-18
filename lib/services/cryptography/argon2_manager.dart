import 'dart:convert';
import 'dart:math';
import '/data/user_info.dart';
import '/services/storage/secure_storage.dart';
import '/data/group_crypto.dart';
import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:flutter/foundation.dart';

class Argon2Manager {
  static final Argon2id _algorithm = Argon2id(parallelism: 2, memory: 65536, iterations: 3, hashLength: 32);
  static final Hmac _hmac = Hmac.sha256();
  static final Uint8List _hmacMessage = base64Decode('MclUa+0PE4+BXCu4dRrQLg==');

  static Future<SecretKey> _deriveKey(Map<String, dynamic> args) async {
    final String password = args['password'];
    final List<int> salt = base64Decode(args['salt']);
    return await _algorithm.deriveKeyFromPassword(password: password, nonce: salt);
  }

  static Future<SecretKey> _computeKey(Map<String, dynamic> args) async {
    return await compute(_deriveKey, args);
  }

  static Future<void> createUserKey() async {
    _clearWrongStoredGroupKeys();
    final id = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final password = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    userId = base64Encode(id);
    final userKey = await _computeKey({'password': base64Encode(password), 'salt': userId});
    _storeGroupKey(userKey, userId!);
  }

  static Future<void> _clearWrongStoredGroupKeys() async {
    for (String tag in userTags.keys) {
      if (!userTags[tag]!) {
        SecureStorage.storage.delete(key: tag);
      }
    }
  }

  static Future<bool> _checkGroupKey(SecretKey derivedKey, String group) async {
    final calculatedMac = await _hmac.calculateMac(_hmacMessage, secretKey: derivedKey);
    final String trueMac = groupCrypto[group]?['verifier'] as String;
    if (trueMac == base64Encode(calculatedMac.bytes)) {
      await _storeGroupKey(derivedKey, group);
      return true;
    }
    return false;
  }

  static Future<void> _storeGroupKey(SecretKey derivedKey, String group) async {
    final String groupKey = base64Encode(await derivedKey.extractBytes());
    await SecureStorage.saveGroupKey(group, groupKey);
  }

  static Future<bool> checkGroupPassword(String password, String group) async {
    final SecretKey derivedKey = await _computeKey({
      'password': password,
      'salt': groupCrypto[group]?['salt'] as String,
    });
    return await _checkGroupKey(derivedKey, group);
  }
}
