import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '/data/poll.dart';
import '/views/widgets/create_new_poll_widget.dart';
import '/views/widgets/poll_widget.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/views/widgets/create_new_task_widget.dart';
import '/data/task.dart';
import '/data/user_info.dart';
import '/views/widgets/task_widget.dart';

class TasksPage extends StatefulWidget {
  final Function(dynamic) onSendTask;

  const TasksPage({super.key, required this.onSendTask});

  static bool userHasTaskTags(Task task) {
    for (String tag in task.tags.keys) {
      if (task.tags[tag]! && userTags[tag]!) {
        return true;
      }
    }
    return false;
  }

  static bool userHasPollTags(Poll poll) {
    for (String tag in poll.tags.keys) {
      if (poll.tags[tag]! && userTags[tag]!) {
        return true;
      }
    }
    return false;
  }

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<Task> _tasksToDelete = [];
  final List<Poll> _pollsToDelete = [];

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newTasksNotifier.value = 0;
    });
    for (Task taskToDelete in _tasksToDelete) {
      taskToDelete.delete();
    }
    for (Poll pollToDelete in _pollsToDelete) {
      pollToDelete.delete();
    }
    _tasksToDelete.clear();
    _pollsToDelete.clear();
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
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: taskBox.listenable(),
                        builder: (context, box, child) {
                          List<Task> tasks = [];
                          List<Poll> polls = [];

                          for (var item in box.values.where((item) => item.isInBox).toList()) {
                            if (item is Task) {
                              tasks.add(item);
                            } else if (item is Poll) {
                              polls.add(item);
                            }
                          }

                          tasks.sort((a, b) => a.time.compareTo(b.time));
                          polls.sort((a, b) => a.time.compareTo(b.time));

                          List<Task> createdTasks = [], acceptedTasks = [], availableTasks = [];
                          List<Poll> createdPolls = [], acceptedPolls = [];

                          for (Task task in tasks) {
                            if (task.numberOfPersons < 0) {
                              _tasksToDelete.add(task);
                            } else if (userName == task.sender) {
                              createdTasks.add(task);
                            } else if (task.persons.containsKey(userName) && task.persons[userName] == false) {
                              acceptedTasks.add(task);
                            } else if (!task.persons.containsKey(userName) && TasksPage.userHasTaskTags(task) && task.numberOfPersons > 0) {
                              availableTasks.add(task);
                            }
                          }

                          for (Poll poll in polls) {
                            if(!poll.tags.values.contains(true)){
                              _pollsToDelete.add(poll);
                            }else if (poll.sender == userName) {
                              createdPolls.add(poll);
                            } else if(TasksPage.userHasPollTags(poll)){
                              acceptedPolls.add(poll);
                            }
                          }

                          List<Map<String, List<dynamic>>> tasksMenu = [
                            {'Tarefas que Criei (${createdTasks.length})': createdTasks},
                            {'Enquetes que Criei (${createdPolls.length})': createdPolls},
                            {'Tarefas que devo Concluir (${acceptedTasks.length})': acceptedTasks},
                            {'Enquetes que posso Participar (${acceptedPolls.length})': acceptedPolls},
                            {'Tarefas que posso Aceitar (${availableTasks.length})': availableTasks},
                          ];

                          return ListView(
                            children: tasksMenu.map((map) {
                              String title = map.keys.first;
                              List<dynamic> items = map[title]!;

                              return ExpansionTile(
                                initiallyExpanded: true,
                                title: Text(title),
                                shape: Border.all(color: Colors.transparent),
                                children: List.generate(items.length, (index) {
                                  var item = items[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    child: item is Task
                                        ? TaskWidget(task: item, onSendTask: widget.onSendTask)
                                        : PollWidget(poll: item, onSendPoll: widget.onSendTask),
                                  );
                                }),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 5,
                        child: FloatingActionButton(
                          elevation: 0,
                          backgroundColor: CustomThemes.mainColor(colorTheme),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        spacing: 5,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => CreateNewTaskWidget(onSendTask: widget.onSendTask),
                                              );
                                            },
                                            child: const Text("Criar Nova Tarefa"),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => CreateNewPollWidget(onSendPoll: widget.onSendTask),
                                              );
                                            },
                                            child: const Text("Criar Nova Enquete"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.add_rounded),
                        ),
                      ),
                    ],
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
