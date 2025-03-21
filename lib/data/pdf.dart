import 'package:hive_ce/hive.dart';

class Pdf extends HiveObject {
  late String base64String;
  late DateTime time;

  Pdf({required this.base64String, DateTime? time}) : time = (time ?? DateTime.now()).copyWith(microsecond: 0);

  Map<String, dynamic> toJson() {
    return {'base64String': base64String, 'time': time.toIso8601String()};
  }

  static Pdf fromJson(Map<String, dynamic> json) {
    return Pdf(base64String: json['base64String'], time: DateTime.parse(json['time']));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Pdf) return false;

    return base64String == other.base64String && time == other.time;
  }

  @override
  int get hashCode {
    return base64String.hashCode ^ time.hashCode;
  }
}