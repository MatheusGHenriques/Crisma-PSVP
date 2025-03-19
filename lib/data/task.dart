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
       time =
           time?.subtract(Duration(microseconds: time.microsecond)) ??
           DateTime.now().subtract(Duration(microseconds: DateTime.now().microsecond));

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

    return description == other.description &&
        sender == other.sender &&
        time == other.time &&
        _mapsEqual(tags, other.tags);
  }

  @override
  int get hashCode {
    return description.hashCode ^ sender.hashCode ^ time.hashCode ^ _mapHash(tags);
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
