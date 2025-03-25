import 'package:hive_ce/hive.dart';

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
  }) : persons = persons ?? {},
       time = (time ?? DateTime.now()).copyWith(microsecond: 0);

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'numberOfPersons': numberOfPersons,
      'persons': persons,
      'description': description,
      'tags': tags,
      'time': time.toIso8601String(),
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      sender: json['sender'],
      numberOfPersons: json['numberOfPersons'],
      persons: Map<String, bool>.from(json['persons']),
      description: json['description'],
      tags: Map<String, bool>.from(json['tags']),
      time: DateTime.parse(json['time']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Task) return false;

    return sender == other.sender &&
        numberOfPersons == other.numberOfPersons &&
        description == other.description &&
        time == other.time &&
        _mapsEqual(persons, other.persons) &&
        _mapsEqual(tags, other.tags);
  }

  bool compare(Task other) {
    return description == other.description && sender == other.sender && time == other.time;
  }

  @override
  int get hashCode {
    return sender.hashCode ^
        numberOfPersons.hashCode ^
        _mapHash(persons) ^
        description.hashCode ^
        _mapHash(tags) ^
        time.hashCode;
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
