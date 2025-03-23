import 'package:crisma/data/notifiers.dart';
import 'package:crisma/data/task.dart';
import 'package:crisma/data/user_info.dart';
import 'package:crisma/views/widgets/tag_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

class CreateNewTaskWidget extends StatefulWidget {
  final Function(Task) onSendTask;

  const CreateNewTaskWidget({super.key, required this.onSendTask});

  @override
  State<CreateNewTaskWidget> createState() => _CreateNewTaskWidgetState();
}

class _CreateNewTaskWidgetState extends State<CreateNewTaskWidget> {
  late bool _hasDescription = false;
  final Box taskBox = Hive.box("taskBox");

  final TextEditingController _taskDescriptionController = TextEditingController();
  int _numberOfPersons = 1;
  final Map<String, bool> _newTaskTags = {
    "Geral": false,
    "Coordenação": false,
    "Música": false,
    "Suporte": false,
    "Animação": false,
    "Cozinha": false,
    "Mídias": false,
    "Homens": false,
    "Mulheres": false,
  };

  void _createNewTask() {
    final newTags = Map<String, bool>.from(_newTaskTags);
    Task taskToSend = Task(
      sender: userName,
      numberOfPersons: _numberOfPersons,
      description: _taskDescriptionController.text,
      tags: newTags,
    );
    widget.onSendTask(taskToSend);
  }

  void initController() {
    _taskDescriptionController.addListener(() {
      setState(() {
        _hasDescription = _taskDescriptionController.text.isNotEmpty;
      });
    });
  }

  @override
  void initState() {
    selectedTagsNotifier.value = 0;
    initController();
    super.initState();
  }

  @override
  void dispose() {
    _taskDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text("Nova Tarefa", style: TextStyle(fontSize: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Text("Nº de Pessoas:"),
                  IconButton(
                    onPressed: () {
                      if (_numberOfPersons > 1) {
                        setState(() {
                          _numberOfPersons--;
                        });
                      }
                    },
                    icon: Icon(Icons.remove_rounded),
                  ),
                  Text(_numberOfPersons.toString()),
                  IconButton(
                    onPressed: () {
                      if (_numberOfPersons < 9) {
                        setState(() {
                          _numberOfPersons++;
                        });
                      }
                    },
                    icon: Icon(Icons.add_rounded),
                  ),
                ],
              ),
              TextField(
                controller: _taskDescriptionController,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Descreva a tarefa a ser criada",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
              SizedBox(height: 5),
              Text("Quem pode concluir essa tarefa?"),
              TagSelectionWidget(tags: _newTaskTags),
              ValueListenableBuilder(
                valueListenable: selectedTagsNotifier,
                builder: (context, selectedTagsNumber, child) {
                  return FilledButton(
                    onPressed:
                        _hasDescription && selectedTagsNumber > 0
                            ? () {
                              _createNewTask();
                              Navigator.pop(context);
                            }
                            : null,
                    child: Text("Criar Tarefa"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
