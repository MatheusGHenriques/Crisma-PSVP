import 'package:hive_ce/hive.dart';

class Message extends HiveObject {
  late Map<String, bool> tags;
  late String sender;
  late String text;
  late DateTime time;

  Message({required this.tags, required this.sender, required this.text, DateTime? time}) : time = time ?? DateTime.now();
}