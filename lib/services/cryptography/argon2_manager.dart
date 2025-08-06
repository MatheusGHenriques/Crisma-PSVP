import 'dart:convert';
import '/services/storage/secure_storage.dart';
import '/data/group_crypto.dart';
import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:flutter/foundation.dart';

class Argon2Manager{
  static final Argon2id _algorithm = Argon2id(parallelism: 2, memory: 65536, iterations: 3, hashLength: 32);
  static final Hmac _hmac = Hmac.sha256();
  static final Uint8List _hmacMessage = base64Decode('MclUa+0PE4+BXCu4dRrQLg==');

  static Future<SecretKey> _deriveGroupKey(Map<String, dynamic> args) async{
    final String password = args['password'];
    final List<int> salt = base64Decode(groupCrypto[args['group'] as String]?['salt'] as String);
    final SecretKey secretKey = await _algorithm.deriveKeyFromPassword(password: password, nonce: salt);
    return secretKey;
  }

  static Future<bool> _checkGroupKey(SecretKey derivedKey, String group) async{
    final calculatedMac = await _hmac.calculateMac(_hmacMessage, secretKey: derivedKey);
    final String trueMac = groupCrypto[group]?['verifier'] as String;
    if(trueMac == base64Encode(calculatedMac.bytes)){
      _storeGroupKey(derivedKey, group);
      return true;
    }
    return false;
  }

  static _storeGroupKey(SecretKey derivedKey, String group) async{
    final String groupKey = base64Encode(await derivedKey.extractBytes());
    SecureStorage.saveGroupKey(group, groupKey);
  }

  static Future<bool> checkGroupPassword(String password, String group) async{
    final SecretKey derivedKey = await compute(_deriveGroupKey, {'password': password, 'group' : group});
    return await _checkGroupKey(derivedKey, group);
  }
}
