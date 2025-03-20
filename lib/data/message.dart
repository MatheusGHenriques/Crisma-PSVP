import 'package:hive_ce/hive.dart';

class Message extends HiveObject {
  late Map<String, bool> tags;
  late String sender;
  late String text;
  late DateTime time;

  Message({required this.tags, required this.sender, required this.text, DateTime? time})
    : time = (time ?? DateTime.now()).copyWith(microsecond: 0);

  Map<String, dynamic> toJson() {
    return {'tags': tags, 'sender': sender, 'text': text, 'time': time.toIso8601String()};
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      tags: Map<String, bool>.from(json['tags']),
      sender: json['sender'],
      text: json['text'],
      time: DateTime.parse(json['time']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Message) return false;

    return text == other.text && sender == other.sender && time == other.time && _mapsEqual(tags, other.tags);
  }

  @override
  int get hashCode {
    return text.hashCode ^ sender.hashCode ^ time.hashCode ^ _mapHash(tags);
  }

  bool _mapsEqual(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  int _mapHash(Map<String, bool> map) {
    int result = 0;
    for (final entry in map.entries) {
      result ^= entry.key.hashCode ^ entry.value.hashCode;
    }
    return result;
  }
}
