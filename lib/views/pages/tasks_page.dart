import 'package:crisma/views/widgets/create_new_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

import '../../data/task.dart';
import '../../data/user_info.dart';
import '../widgets/task_widget.dart';

class TasksPage extends StatefulWidget {
  final Function(Task) onSendTask;
  const TasksPage({super.key, required this.onSendTask});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final taskBox = Hive.box("taskBox");

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                Expanded(child: ValueListenableBuilder(
                valueListenable: taskBox.listenable(),
                builder: (context, box, child) {
                  List<Task> tasks = box.values.cast<Task>().toList();
                  tasks.sort((a, b) => a.time.compareTo(b.time));
                  
                  List<Task> createdTasks = [], acceptedTasks = [], availableTasks = [];
                  
                  for(Task task in tasks){
                    if(task.numberOfPersons < 0){
                      task.delete();
                    }else if(userName == task.sender){
                      createdTasks.add(task);
                    }else if(task.persons.containsKey(userName) && task.persons[userName] == false){
                      acceptedTasks.add(task);
                    }else if(!task.persons.containsKey(userName)){
                      availableTasks.add(task);
                    }
                  }
                  
                  List<Map<String, List<Task>>> tasksMenu = <Map<String, List<Task>>>[
                    {'Tarefas que Criei (${createdTasks.length})': createdTasks},
                    {'Tarefas que devo Concluir (${acceptedTasks.length})': acceptedTasks},
                    {'Tarefas que posso Aceitar (${availableTasks.length})': availableTasks},
                  ];
                  
                  return ListView(
                      children: tasksMenu.map((map) {
                        String title = map.keys.first;
                        return ExpansionTile(
                          title: Text(title),
                          shape: Border.all(color: Colors.transparent),
                          children: List.generate(map[title]!.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: TaskWidget(task: map[title]!.elementAt(index), onSendTask: widget.onSendTask,),
                            );
                          }),
                        );
                      }).toList(),
                  );
                },
              ),
            ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CreateNewTaskWidget(onSendTask: widget.onSendTask,);
                          },
                        );
                      },
                      child: Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
