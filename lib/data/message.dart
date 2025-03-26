import 'package:hive_ce/hive.dart';
import 'package:collection/collection.dart';

class Message extends HiveObject {
  late Map<String, bool> tags;
  late String sender;
  late String text;
  late List<String> readBy;
  late DateTime time;

  Message({
    required this.tags,
    required this.sender,
    required this.text,
    List<String>? readBy,
    DateTime? time,
  })  : readBy = readBy ?? [],
        time = (time ?? DateTime.now()).copyWith(microsecond: 0);

  Map<String, dynamic> toJson() => {
    'tags': tags,
    'sender': sender,
    'text': text,
    'readBy': readBy,
    'time': time.toIso8601String(),
  };

  static Message fromJson(Map<String, dynamic> json) => Message(
    tags: Map<String, bool>.from(json['tags']),
    sender: json['sender'],
    text: json['text'],
    readBy: List<String>.from(json['readBy'] ?? []),
    time: DateTime.parse(json['time']),
  );

  bool compare(Message other) =>
      sender == other.sender &&
          text == other.text &&
          time == other.time &&
          const DeepCollectionEquality().equals(tags, other.tags);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Message) return false;

    return sender == other.sender &&
        text == other.text &&
        time == other.time &&
        const DeepCollectionEquality().equals(tags, other.tags) &&
        const ListEquality().equals(readBy, other.readBy);
  }

  @override
  int get hashCode => Object.hash(
    sender,
    text,
    time,
    const DeepCollectionEquality().hash(tags),
    const ListEquality().hash(readBy),
  );
}