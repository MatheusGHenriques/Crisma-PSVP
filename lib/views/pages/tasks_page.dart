import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/views/widgets/create_new_task_widget.dart';
import '/data/task.dart';
import '/data/user_info.dart';
import '/views/widgets/task_widget.dart';

class TasksPage extends StatefulWidget {
  final Function(Task) onSendTask;

  const TasksPage({super.key, required this.onSendTask});

  static bool userHasTaskTags(Task task) {
    for (String tag in task.tags.keys) {
      if (task.tags[tag]! && userTags[tag]!) {
        return true;
      }
    }
    return false;
  }

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newTasksNotifier.value = 0;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: taskBox.listenable(),
                    builder: (context, box, child) {
                      List<Task> tasks = box.values.cast<Task>().toList();
                      tasks.sort((a, b) => a.time.compareTo(b.time));

                      List<Task> createdTasks = [], acceptedTasks = [], availableTasks = [];

                      for (Task task in tasks) {
                        if (task.numberOfPersons < 0) {
                          task.delete();
                        } else if (userName == task.sender) {
                          createdTasks.add(task);
                        } else if (task.persons.containsKey(userName) && task.persons[userName] == false) {
                          acceptedTasks.add(task);
                        } else if (!task.persons.containsKey(userName) && TasksPage.userHasTaskTags(task)) {
                          availableTasks.add(task);
                        }
                      }

                      List<Map<String, List<Task>>> tasksMenu = <Map<String, List<Task>>>[
                        {'Tarefas que Criei (${createdTasks.length})': createdTasks},
                        {'Tarefas que devo Concluir (${acceptedTasks.length})': acceptedTasks},
                        {'Tarefas que posso Aceitar (${availableTasks.length})': availableTasks},
                      ];

                      return ListView(
                        children:
                            tasksMenu.map((map) {
                              String title = map.keys.first;
                              return ExpansionTile(
                                initiallyExpanded: true,
                                title: Text(title),
                                shape: Border.all(color: Colors.transparent),
                                children: List.generate(map[title]!.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: TaskWidget(
                                      task: map[title]!.elementAt(index),
                                      onSendTask: widget.onSendTask,
                                    ),
                                  );
                                }),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: FloatingActionButton(
                    backgroundColor: CustomThemes.mainColor(colorTheme),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CreateNewTaskWidget(onSendTask: widget.onSendTask);
                        },
                      );
                    },
                    child: const Icon(Icons.add_rounded),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
