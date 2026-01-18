import 'dart:convert';
import 'dart:typed_data';
import '/data/task.dart';
import '/data/poll.dart';
import '/data/group_crypto.dart';
import '/data/message.dart';
import '/data/user_info.dart';
import '/services/storage/secure_storage.dart';
import 'package:cryptography_plus/cryptography_plus.dart';

import 'ecdh_envelope.dart';

class AesManager {
  static final AesGcm _cipher = AesGcm.with256bits();

  static Future<String> encrypt(SecretKey key, String message) async {
    final plain = utf8.encode(message);
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(plain, secretKey: key, nonce: nonce);
    final full = box.concatenation();
    return base64.encode(full);
  }

  static Future<String> decrypt(SecretKey key, String base64Message) async {
    final bytes = base64.decode(base64Message);
    final box = SecretBox.fromConcatenation(
      bytes,
      nonceLength: 12,
      macLength: 16,
    );
    final plain = await _cipher.decrypt(box, secretKey: key);
    return utf8.decode(plain);
  }

  static Future<Uint8List> decryptBytes(
      SecretKey key,
      String base64Message,
      ) async {
    final bytes = base64.decode(base64Message);
    final box = SecretBox.fromConcatenation(
      bytes,
      nonceLength: 12,
      macLength: 16,
    );
    final plain = await _cipher.decrypt(box, secretKey: key);
    return Uint8List.fromList(plain);
  }

  static Future<String> encryptBytes(
      SecretKey key,
      Uint8List data,
      ) async {
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(
      data,
      secretKey: key,
      nonce: nonce,
    );
    return base64Encode(box.concatenation());
  }

  static Future<Map<String, String>> createEncryptedAesKey(
    Map<String, bool> tags,
  ) async {
    final key = await _cipher.newSecretKey();
    final String aesKey = base64Encode(await key.extractBytes());
    final Map<String, String> encryptedAesKey = {};
    for (String tag in tags.keys) {
      if (tags[tag]!) {
        final envelope = await EcdhEnvelope.encrypt(
          plainText: aesKey,
          groupPublicKeyBase64: groupCrypto[tag]!['public_key']!,
        );
        encryptedAesKey[tag] = jsonEncode(envelope);
      }
    }

    final userKeyString = await SecureStorage.getGroupKey(userId!);
    if (userKeyString == null) throw Error();
    final userKey = await _cipher.newSecretKeyFromBytes(
      base64Decode(userKeyString),
    );
    encryptedAesKey[userId!] = await encrypt(userKey, aesKey);
    return encryptedAesKey;
  }

  static Future<SecretKey> decryptAesKey(
    Map<String, String> encryptedAesKey,
  ) async {
    if (userId == null) {
      throw StateError('Session not initialized');
    }
    for (String tag in encryptedAesKey.keys) {
      if (userId == tag || userTags[tag]!) {
        final String? groupKeyString = await SecureStorage.getGroupKey(tag);
        if (groupKeyString == null) throw Error();
        final SecretKey groupKey = await _cipher.newSecretKeyFromBytes(
          base64Decode(groupKeyString),
        );
        final String aesKey;
        if (tag == userId) {
          aesKey = await decrypt(groupKey, encryptedAesKey[tag]!);
        } else {
          final encryptedPrivateKey =
              groupCrypto[tag]!['encrypted_private_key']!;

          final envelope =
              jsonDecode(encryptedAesKey[tag]!) as Map<String, dynamic>;
          final Uint8List privateKeyBytes = await decryptBytes(groupKey, encryptedPrivateKey);

          aesKey = await EcdhEnvelope.decrypt(
            envelope: Map<String, String>.from(envelope),
            groupPrivateKeyBytes: privateKeyBytes,
            groupPublicKeyBase64: groupCrypto[tag]!['public_key']!,
          );
        }
        return await _cipher.newSecretKeyFromBytes(base64Decode(aesKey));
      }
    }
    throw Error();
  }

  static Future<Message> encryptMessage(Message message) async {
    final key = await AesManager.decryptAesKey(message.encryptedAesKey);
    final text = await encrypt(key, message.text);
    return Message(
      encryptedAesKey: message.encryptedAesKey,
      sender: message.sender,
      text: text,
      readBy: message.readBy,
      time: message.time,
    );
  }

  static Future<Message> decryptMessage(Message message) async {
    final key = await AesManager.decryptAesKey(message.encryptedAesKey);
    final text = await decrypt(key, message.text);
    return Message(
      encryptedAesKey: message.encryptedAesKey,
      sender: message.sender,
      text: text,
      time: message.time,
      readBy: message.readBy,
    );
  }

  static Future<Poll> encryptPoll(Poll poll) async {
    final key = await AesManager.decryptAesKey(poll.encryptedAesKey);
    final description = await encrypt(key, poll.description);
    Map<String, List<String>> encryptedVotes = {};
    for (String response in poll.votes.keys) {
      List<String> users = [];
      if (poll.votes[response] != null) {
        for (String user in poll.votes[response]!) {
          users.add(await encrypt(key, user));
        }
      }
      encryptedVotes[await encrypt(key, response)] = users;
    }
    return Poll(
      sender: poll.sender,
      openResponse: poll.openResponse,
      description: description,
      encryptedAesKey: poll.encryptedAesKey,
      time: poll.time,
      votes: encryptedVotes,
    );
  }

  static Future<Poll> decryptPoll(Poll poll) async {
    final key = await AesManager.decryptAesKey(poll.encryptedAesKey);
    final description = await decrypt(key, poll.description);
    Map<String, List<String>> decryptedVotes = {};
    for (String response in poll.votes.keys) {
      List<String> users = [];
      if (poll.votes[response] != null) {
        for (String user in poll.votes[response]!) {
          users.add(await decrypt(key, user));
        }
      }
      decryptedVotes[await decrypt(key, response)] = users;
    }
    return Poll(
      sender: poll.sender,
      openResponse: poll.openResponse,
      description: description,
      encryptedAesKey: poll.encryptedAesKey,
      time: poll.time,
      votes: decryptedVotes,
    );
  }

  static Future<Task> encryptTask(Task task) async {
    final key = await AesManager.decryptAesKey(task.encryptedAesKey);
    final description = await encrypt(key, task.description);
    Map<String, bool> encryptedPersons = {};
    for (String person in task.persons.keys) {
      encryptedPersons[await encrypt(key, person)] = task.persons[person]!;
    }
    return Task(
      encryptedAesKey: task.encryptedAesKey,
      sender: task.sender,
      description: description,
      numberOfPersons: task.numberOfPersons,
      time: task.time,
      persons: encryptedPersons,
    );
  }

  static Future<Task> decryptTask(Task task) async {
    final key = await AesManager.decryptAesKey(task.encryptedAesKey);
    final description = await decrypt(key, task.description);
    Map<String, bool> decryptedPersons = {};
    for (String person in task.persons.keys) {
      decryptedPersons[await decrypt(key, person)] = task.persons[person]!;
    }
    return Task(
      encryptedAesKey: task.encryptedAesKey,
      sender: task.sender,
      description: description,
      numberOfPersons: task.numberOfPersons,
      time: task.time,
      persons: decryptedPersons,
    );
  }
}
