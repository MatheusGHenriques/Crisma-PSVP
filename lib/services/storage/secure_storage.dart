import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final storage = FlutterSecureStorage();

  static Future<void> saveGroupKey(String group, String key) async {
    await storage.write(key: group, value: key);
  }

  static Future<void> userLogout() async {
    await storage.deleteAll();
  }

  static Future<String?> getGroupKey(String group) async{
    return await storage.read(key: group);
  }
}