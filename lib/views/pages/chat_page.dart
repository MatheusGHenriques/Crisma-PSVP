import 'package:crisma/data/message.dart';
import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widgets/message_widget.dart';
import 'package:crisma/views/widgets/tag_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '../../data/user_info.dart';

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
  final chatBox = Hive.box("chatBox");

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController() {
    _sendMessageController.addListener(() {
      setState(() {
        _hasMessage = _sendMessageController.text.isNotEmpty;
      });
    });
  }

  void sendMessage() {
    // Ainda falta enviar a mensagem
    Message sendMessage = Message(tags: selectedTags, sender: userName!, text: _sendMessageController.text);
    chatBox.add(sendMessage);
    _sendMessageController.clear();
  }

  @override
  void dispose() {
    isChatBoxInitializedNotifier.value = false;
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
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: ValueListenableBuilder(
                      valueListenable: chatBox.listenable(),
                      builder: (context, box, child) {
                        return Column(
                          children: List.generate(box.length, (index) {
                            Message message = box.getAt(index);
                            return MessageWidget(message: message);
                          }),
                        );
                      },
                    ),
                  ),
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
                          _hasMessage && chatHasSelectedTagNotifier.value
                              ? () {
                                sendMessage();
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
