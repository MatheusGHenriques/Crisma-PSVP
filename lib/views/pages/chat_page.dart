import 'package:crisma/data/message.dart';
import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widgets/message_widget.dart';
import 'package:crisma/views/widgets/tag_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '../../data/user_info.dart';

class ChatPage extends StatefulWidget {
  final Function(Message) onSendMessage;

  const ChatPage({super.key, required this.onSendMessage});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _sendMessageController = TextEditingController();
  String _stringTags = "";
  late Map<String, bool> selectedTags = {
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
  bool _hasMessage = false;

  final chatBox = Hive.box("chatBox");

  @override
  void initState() {
    hasSelectedTagNotifier.value = false;
    _initController();
    super.initState();
  }

  void _initController() {
    _sendMessageController.addListener(() {
      setState(() {
        _hasMessage = _sendMessageController.text.isNotEmpty;
      });
    });
  }

  void sendButtonClicked() {
    final newTags = Map<String, bool>.from(selectedTags);
    Message messageToSend = Message(tags: newTags, sender: userName, text: _sendMessageController.text);
    widget.onSendMessage(messageToSend);
    _sendMessageController.clear();
  }

  bool userHasMessageTags(Message message) {
    if (message.sender == userName) {
      return true;
    }
    for(String tag in message.tags.keys) {
      if (message.tags[tag]! && userTags[tag]!) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _sendMessageController.dispose();
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
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: ValueListenableBuilder(
                      valueListenable: chatBox.listenable(),
                      builder: (context, box, child) {
                        List<Message> messages = box.values.cast<Message>().toList();
                        messages.sort((a, b) => a.time.compareTo(b.time));
                        return Column(
                          spacing: 5,
                          children: List.generate(messages.length, (index) {
                            if(userHasMessageTags(messages.elementAt(index))) {
                              return MessageWidget(message: messages.elementAt(index));
                            }
                            return SizedBox();
                          }),
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: hasSelectedTagNotifier,
                      builder: (context, hasSelectedTag, child) {
                        return IconButton.filledTonal(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TagSelectionWidget(tags: selectedTags),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.tag_rounded),
                          style: ButtonStyle(
                            backgroundColor: hasSelectedTag ? const WidgetStatePropertyAll(Colors.redAccent) : null,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: hasSelectedTagNotifier,
                        builder: (context, hasSelectedTag, child) {
                          _stringTags = "";
                          for(String tag in selectedTags.keys){
                            if(selectedTags[tag]!){
                              _stringTags += "@$tag ";
                            }
                          }
                          return TextField(
                            controller: _sendMessageController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: hasSelectedTag? _stringTags : "Digite uma mensagem",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            enableInteractiveSelection: false,
                            enableSuggestions: false,
                          );
                        },
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed:
                          _hasMessage && hasSelectedTagNotifier.value
                              ? () {
                                sendButtonClicked();
                              }
                              : null,
                      icon: const Icon(Icons.send_rounded),
                      style: ButtonStyle(
                        backgroundColor:
                            _hasMessage && hasSelectedTagNotifier.value
                                ? const WidgetStatePropertyAll(Colors.redAccent)
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }
}
