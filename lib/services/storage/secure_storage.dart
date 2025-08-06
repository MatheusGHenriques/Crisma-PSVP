import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final storage = FlutterSecureStorage();

  static saveGroupPassword(String group, String password) async {
    await storage.write(key: group, value: password);
  }

  static userLogout() async {
    await storage.deleteAll();
  }

  static Future<String?> getGroupPassword(String group) async{
    return await storage.read(key: group);
  }
}