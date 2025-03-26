import 'package:flutter/material.dart';
import '/data/poll.dart';
import '/data/notifiers.dart';
import '/data/user_info.dart';
import 'tag_selection_widget.dart';

class CreateNewPollWidget extends StatefulWidget {
  final Function(Poll) onSendPoll;

  const CreateNewPollWidget({super.key, required this.onSendPoll});

  @override
  State<CreateNewPollWidget> createState() => _CreateNewPollWidgetState();
}

class _CreateNewPollWidgetState extends State<CreateNewPollWidget> {
  bool _hasDescription = false;
  bool _hasVotes = false;
  bool _openResponse = false;

  final TextEditingController _pollDescriptionController = TextEditingController();
  final TextEditingController _pollVotesController = TextEditingController();
  final Map<String, bool> _newPollTags = {
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

  void _createNewPoll() {
    final newTags = Map<String, bool>.from(_newPollTags);
    Map<String, List<String>> votes = {};
    if(!_openResponse) {
      for (String possibleVote in _pollVotesController.text.split('\n')) {
        votes[possibleVote] = [];
      }
    }
    Poll pollToSend = Poll(
      sender: userName,
      openResponse: _openResponse,
      description: _pollDescriptionController.text,
      votes: votes,
      tags: newTags,
    );
    widget.onSendPoll(pollToSend);
  }

  void initController() {
    _pollDescriptionController.addListener(() {
      setState(() {
        _hasDescription = _pollDescriptionController.text.isNotEmpty;
      });
    });
    _pollVotesController.addListener(() {
      setState(() {
        _hasVotes = _pollVotesController.text.isNotEmpty;
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
    _pollDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              const Text("Nova Enquete", style: TextStyle(fontSize: 20)),
              TextField(
                controller: _pollDescriptionController,
                maxLines: 1,
                keyboardType: TextInputType.multiline,
                maxLength: 100,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Descreva a enquete",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _openResponse,
                    onChanged: (value) {
                      setState(() {
                        _openResponse = !_openResponse;
                      });
                    },
                  ),
                  const Text("Respostas personalizadas"),
                ],
              ),
              TextField(
                enabled: !_openResponse,
                controller: _pollVotesController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                maxLength: 300,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Digite aqui as opções para votar, separadas por linha",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
              const Text("Quem pode votar?"),
              TagSelectionWidget(tags: _newPollTags),
              ValueListenableBuilder(
                valueListenable: selectedTagsNotifier,
                builder: (context, selectedTagsNumber, child) {
                  return FilledButton(
                    onPressed:
                        _hasDescription &&
                                selectedTagsNumber > 0 &&
                                ((!_openResponse && _hasVotes) || _openResponse && !_hasVotes)
                            ? () {
                              _createNewPoll();
                              Navigator.pop(context);
                            }
                            : null,
                    child: const Text("Criar Enquete"),
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
