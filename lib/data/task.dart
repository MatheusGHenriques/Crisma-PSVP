import 'package:hive_ce/hive.dart';
import 'package:collection/collection.dart';

class Task extends HiveObject {
  late String sender;
  late int numberOfPersons;
  late Map<String, bool> persons;
  late String description;
  late Map<String, bool> tags;
  late DateTime time;

  Task({
    required this.sender,
    required this.numberOfPersons,
    Map<String, bool>? persons,
    required this.description,
    required this.tags,
    DateTime? time,
  })  : persons = persons ?? {},
        time = (time ?? DateTime.now()).copyWith(microsecond: 0);

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'numberOfPersons': numberOfPersons,
    'persons': persons,
    'description': description,
    'tags': tags,
    'time': time.toIso8601String(),
  };

  static Task fromJson(Map<String, dynamic> json) => Task(
    sender: json['sender'],
    numberOfPersons: json['numberOfPersons'],
    persons: Map<String, bool>.from(json['persons']),
    description: json['description'],
    tags: Map<String, bool>.from(json['tags']),
    time: DateTime.parse(json['time']),
  );

  bool compare(Task other) =>
      sender == other.sender &&
          description == other.description &&
          time == other.time;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Task) return false;

    return sender == other.sender &&
        numberOfPersons == other.numberOfPersons &&
        description == other.description &&
        time == other.time &&
        const DeepCollectionEquality().equals(persons, other.persons) &&
        const DeepCollectionEquality().equals(tags, other.tags);
  }

  @override
  int get hashCode => Object.hash(
    sender,
    numberOfPersons,
    description,
    time,
    const DeepCollectionEquality().hash(persons),
    const DeepCollectionEquality().hash(tags),
  );
}