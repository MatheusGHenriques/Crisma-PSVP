import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

import '../../data/notifiers.dart';
import '../../data/task.dart';
import '../../data/user_info.dart';

class TaskWidget extends StatefulWidget {
  final Task task;

  const TaskWidget({super.key, required this.task});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  String _getTags() {
    String tags = "";
    for (String tag in widget.task.tags.keys) {
      if (widget.task.tags[tag]!) {
        tags += "@$tag ";
      }
    }
    return tags;
  }

  List<Text> _getPersons() {
    List<Text> persons = [];
    late Text text;
    for (String person in widget.task.persons.keys) {
      if (widget.task.persons[person]!) {
        text = Text(person);
      } else {
        text = Text(person, style: TextStyle(color: Colors.green));
      }
      persons.add(text);
    }
    return persons;
  }

  void _deleteTask() async{
    widget.task.delete();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color:
                widget.task.sender == userName
                    ? Colors.red[300]
                    : isDarkMode
                    ? Color.alphaBlend(Colors.red.withAlpha(30), Colors.black38)
                    : Color.alphaBlend(Colors.red.withAlpha(50), Colors.white),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5,
                  children: [
                    widget.task.sender != userName
                        ? Text(
                          widget.task.sender,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                        )
                        : const SizedBox(),
                    Text(
                      _getTags(),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[900]),
                    ),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(children: [Icon(Icons.person_rounded), Text(widget.task.numberOfPersons.toString())]),
                    Row(children: _getPersons()),
                  ],
                ),
              ),

              widget.task.sender == userName
                  ? IconButton(
                    onPressed: () {
                      _deleteTask();
                    },
                    icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.black),
                  )
                  : IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.person_add_alt_1, color: isDarkMode ? Colors.white : Colors.black),
                  ),
            ],
          ),
        );
      },
    );
  }
}
