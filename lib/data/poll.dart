import 'package:hive_ce/hive.dart';
import 'package:collection/collection.dart';

class Poll extends HiveObject {
  late String sender;
  late bool openResponse;
  late Map<String, List<String>> votes;
  late String description;
  late Map<String, bool> tags;
  late DateTime time;

  Poll({
    required this.sender,
    required this.openResponse,
    Map<String, List<String>>? votes,
    required this.description,
    required this.tags,
    DateTime? time,
  })  : votes = votes ?? {},
        time = (time ?? DateTime.now()).copyWith(microsecond: 0);

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'openResponse': openResponse,
    'votes': votes.map((key, value) => MapEntry(key, List<String>.from(value))),
    'description': description,
    'tags': tags,
    'time': time.toIso8601String(),
  };

  static Poll fromJson(Map<String, dynamic> json) => Poll(
    sender: json['sender'],
    openResponse: json['openResponse'],
    votes: (json['votes'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
    ),
    description: json['description'],
    tags: Map<String, bool>.from(json['tags']),
    time: DateTime.parse(json['time']),
  );

  bool compare(Poll other) =>
      sender == other.sender &&
          description == other.description &&
          time == other.time &&
          openResponse == other.openResponse;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Poll) return false;

    return sender == other.sender &&
        openResponse == other.openResponse &&
        description == other.description &&
        time == other.time &&
        const DeepCollectionEquality().equals(votes, other.votes) &&
        const DeepCollectionEquality().equals(tags, other.tags);
  }

  @override
  int get hashCode => Object.hash(
    sender,
    openResponse,
    description,
    time,
    const DeepCollectionEquality().hash(votes),
    const DeepCollectionEquality().hash(tags),
  );
}