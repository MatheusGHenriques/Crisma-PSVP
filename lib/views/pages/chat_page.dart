
import 'package:crisma/data/notifiers.dart';

import 'package:crisma/views/widgets/tag_button_widget.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _sendMessageController = TextEditingController();
  Map<String, bool> selectedTags = {
    "Todos": false,
    "Coordenação": false,
    "Música": false,
    "Suporte": false,
    "Animação": false,
    "Cozinha": false,
    "Mídias": false,
    "Homens": false,
    "Mulheres": false,
  };
  bool _hasMessage = false;
  late List<String> tags;

  @override
  void initState() {
    _sendMessageController.addListener(() {
      setState(() {
        _hasMessage = _sendMessageController.text.isNotEmpty;
      });
    });
    super.initState();
  }


  void sendMessage(){
    // Ainda falta enviar a mensagem
    // Message sendMessage = Message(sender: userName!, text: _sendMessageController.text,);

    _sendMessageController.clear();
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: [

                        ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: chatHasSelectedTagNotifier,
                      builder: (context, hasSelectedTag, child) {
                        return IconButton.filledTonal(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(selectedTags.length, (index) {
                                          return TagButtonWidget(
                                            text: selectedTags.keys.toList().elementAt(index),
                                            tagMap: selectedTags,
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).then((value) {
                              chatHasSelectedTagNotifier.value = false;
                              for (String tag in selectedTags.keys.toList()) {
                                if (selectedTags[tag] == true) {
                                  chatHasSelectedTagNotifier.value = true;
                                }
                              }
                            });
                          },
                          icon: const Icon(Icons.tag_rounded),
                          style: ButtonStyle(
                            backgroundColor: hasSelectedTag ? WidgetStatePropertyAll(Colors.redAccent) : null,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _sendMessageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Digite uma mensagem",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        enableInteractiveSelection: false,
                        enableSuggestions: false,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed:
                          _hasMessage
                              ? () {
                                chatHasSelectedTagNotifier.value
                                    ? sendMessage()
                                    : showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    "Você não selecionou uma tag. Gostaria de enviar a mensagem para todos?",
                                                    style: TextStyle(fontSize: 16),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      FilledButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("Não"),
                                                      ),
                                                      const SizedBox(width: 20),
                                                      FilledButton(
                                                        onPressed: () {
                                                          sendMessage();
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text("Sim"),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                              }
                              : null,
                      icon: const Icon(Icons.send_rounded),
                      style: ButtonStyle(
                        backgroundColor: _hasMessage ? WidgetStatePropertyAll(Colors.redAccent) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}