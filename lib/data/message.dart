import 'package:hive_ce/hive.dart';

class Message extends HiveObject {
  late Map<String, bool> tags;
  late String sender;
  late String text;
  late DateTime time;

  Message({required this.tags, required this.sender, required this.text, DateTime? time}) : time = time ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'sender': sender,
      'text': text,
      'time': time.toIso8601String(),
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      tags: Map<String, bool>.from(json['tags']),
      sender: json['sender'],
      text: json['text'],
      time: DateTime.parse(json['time']),
    );
  }
}