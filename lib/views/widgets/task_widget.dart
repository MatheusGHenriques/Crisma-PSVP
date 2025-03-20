import 'package:flutter/material.dart';

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
      if (persons.isNotEmpty) {
        persons.add(Text(", "));
      }
      if (widget.task.persons[person]!) {
        text = Text(person, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
      } else {
        text = Text(person, style: TextStyle(fontWeight: FontWeight.bold));
      }
      persons.add(text);
    }
    return persons;
  }

  bool _isTaskDone() {
    for (bool isDone in widget.task.persons.values) {
      if (!isDone) {
        return false;
      }
    }
    return true;
  }

  void _deleteTask() async {
    widget.task.numberOfPersons = -1;
    widget.task.delete();
    //enviar tarefa com -1 pessoas por exemplo (deletar)
  }

  void _concludeTask() {
    setState(() {
      widget.task.persons[userName] = true;
    });
    //enviar tarefa atualizada
  }

  void _acceptTask() {
    setState(() {
      widget.task.numberOfPersons--;
      widget.task.persons[userName] = false;
    });
    //enviar tarefa atualizada
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.numberOfPersons < 0) {
      widget.task.delete();
    }
    if ((widget.task.persons[userName] != null && widget.task.persons[userName]! == true) ||
        (widget.task.numberOfPersons == 0 &&
            widget.task.sender != userName &&
            !widget.task.persons.containsKey(userName))) {
      return SizedBox();
    }

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
            spacing: 20,
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
                    icon:
                        _isTaskDone()
                            ? Icon(Icons.check_circle_rounded, color: isDarkMode ? Colors.white : Colors.black)
                            : Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.black),
                  )
                  : widget.task.persons.containsKey(userName)
                  ? IconButton(
                    onPressed: () {
                      _concludeTask();
                    },
                    icon: Icon(Icons.check_circle_rounded, color: isDarkMode ? Colors.white : Colors.black),
                  )
                  : IconButton(
                    onPressed: () {
                      _acceptTask();
                    },
                    icon: Icon(Icons.person_add_alt_1, color: isDarkMode ? Colors.white : Colors.black),
                  ),
            ],
          ),
        );
      },
    );
  }
}
