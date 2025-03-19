import 'package:crisma/views/widgets/create_new_task_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

import '../../data/task.dart';
import '../widgets/task_widget.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

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
                Expanded(child: SingleChildScrollView(
              child: ValueListenableBuilder(
                valueListenable: taskBox.listenable(),
                builder: (context, box, child) {
                  List<Task> tasks = box.values.cast<Task>().toList();
                  tasks.sort((a, b) => a.time.compareTo(b.time));
                  return Column(
                    spacing: 5,
                    children: List.generate(tasks.length, (index) {
                      return TaskWidget(task: tasks.elementAt(index));
                    }),
                  );
                },
              ),
            ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CreateNewTaskWidget();
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
