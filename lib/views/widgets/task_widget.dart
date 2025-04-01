import 'package:flutter/material.dart';
import '/main.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/data/task.dart';
import '/data/user_info.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final Function(Task) onSendTask;

  const TaskWidget({super.key, required this.task, required this.onSendTask});

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
    for (String person in widget.task.persons.keys) {
      if (persons.isNotEmpty) persons.add(Text(", "));
      Text text;
      if (widget.task.persons[person]!) {
        text = Text(
          person,
          style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, decorationThickness: 3),
        );
      } else {
        text = Text(person, style: TextStyle(fontWeight: FontWeight.bold));
      }
      persons.add(text);
    }
    return persons;
  }

  bool _isTaskDone(Task task) {
    if (task.persons.isEmpty || task.numberOfPersons > 0) return false;
    for (bool isDone in task.persons.values) {
      if (!isDone) return false;
    }
    return true;
  }

  Task _cloneTask(Task task) {
    return Task(
      sender: task.sender,
      description: task.description,
      tags: Map<String, bool>.from(task.tags),
      numberOfPersons: task.numberOfPersons,
      persons: Map<String, bool>.from(task.persons),
      time: task.time,
    );
  }

  void _deleteTask() {
    Task newTask = _cloneTask(widget.task);
    newTask.numberOfPersons = -1;
    widget.onSendTask(newTask);
  }

  void _concludeTask() {
    Task newTask = _cloneTask(widget.task);
    newTask.persons[userName] = true;
    widget.onSendTask(newTask);
  }

  void _acceptTask() {
    Task newTask = _cloneTask(widget.task);
    newTask.numberOfPersons--;
    newTask.persons[userName] = false;
    widget.onSendTask(newTask);
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
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color:
                widget.task.sender == userName
                    ? CustomThemes.secondaryLightColor(colorTheme)
                    : isDarkMode
                    ? CustomThemes.darkBackgroundColor(colorTheme)
                    : CustomThemes.lightBackgroundColor(colorTheme),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.task.sender != userName
                        ? Text(
                          widget.task.sender,
                          style: TextStyle(
                            color: CustomThemes.mainColor(colorTheme),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                        : const SizedBox(),
                    Text(
                      _getTags(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: CustomThemes.secondaryDarkColor(colorTheme),
                      ),
                    ),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(children: [const Icon(Icons.person_rounded), Text(widget.task.numberOfPersons.toString())]),
                    Row(children: _getPersons()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child:
                    widget.task.sender == userName
                        ? IconButton(
                          onPressed: _deleteTask,
                          icon:
                              _isTaskDone(_cloneTask(widget.task))
                                  ? Icon(Icons.check_circle_rounded, color: isDarkMode ? Colors.white : Colors.black)
                                  : Icon(Icons.close_rounded, color: isDarkMode ? Colors.white : Colors.black),
                        )
                        : widget.task.persons.containsKey(userName)
                        ? IconButton(
                          onPressed: _concludeTask,
                          icon: Icon(Icons.check_circle_rounded, color: isDarkMode ? Colors.white : Colors.black),
                        )
                        : IconButton(
                          onPressed: _acceptTask,
                          icon: Icon(Icons.person_add_alt_1, color: isDarkMode ? Colors.white : Colors.black),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
