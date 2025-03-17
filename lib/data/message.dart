import 'package:hive_ce/hive.dart';

class Message extends HiveObject{
  late String sender;
  late String text;

  Message({required this.sender, required this.text});
}