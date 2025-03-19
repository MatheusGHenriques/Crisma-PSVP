import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widgets/tag_selection_widget.dart';
import 'package:flutter/material.dart';

class CreateNewTaskWidget extends StatefulWidget {
  const CreateNewTaskWidget({super.key});

  @override
  State<CreateNewTaskWidget> createState() => _CreateNewTaskWidgetState();
}

class _CreateNewTaskWidgetState extends State<CreateNewTaskWidget> {
  late bool _hasDescription = false;

  final TextEditingController _taskDescriptionController = TextEditingController();
  int _numberOfPersons = 1;
  final Map<String, bool> _newTaskTags = {
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

  }

  void initController(){
    _taskDescriptionController.addListener(() {
      setState(() {
        _hasDescription = _taskDescriptionController.text.isNotEmpty;
      });
    });
  }

  @override
  void initState() {
    hasSelectedTagNotifier.value = false;
    initController();
    super.initState();
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
              ValueListenableBuilder(valueListenable: hasSelectedTagNotifier, builder: (context, hasSelectedTag, child) {
                return FilledButton(
                  onPressed: _hasDescription && hasSelectedTag? () {
                      _createNewTask();
                      Navigator.pop(context);
                  } : null,
                  child: Text("Criar Tarefa"),
                );
              },)
            ],
          ),
        ),
      ),
    );
  }
}
