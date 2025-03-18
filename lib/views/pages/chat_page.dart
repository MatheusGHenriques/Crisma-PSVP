import 'package:crisma/data/message.dart';
import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widgets/message_widget.dart';
import 'package:crisma/views/widgets/tag_button_widget.dart';
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
  late Map<String, bool> selectedTags;
  bool _hasMessage = false;

  final chatBox = Hive.box("chatBox");



  @override
  void initState() {
    super.initState();
    _initController();
    _initTags();
  }

  void _initController() {
    _sendMessageController.addListener(() {
      setState(() {
        _hasMessage = _sendMessageController.text.isNotEmpty;
      });
    });
  }

  void _initTags() {
    selectedTags = {
      "Coordenação": false,
      "Música": false,
      "Suporte": false,
      "Animação": false,
      "Cozinha": false,
      "Mídias": false,
      "Homens": false,
      "Mulheres": false,
    };
    chatHasSelectedTagNotifier.value = false;
  }

  void sendButtonClicked() {
    final newTags = Map<String, bool>.from(selectedTags);
    Message messageToSend = Message(
      tags: newTags,
      sender: userName,
      text: _sendMessageController.text,
    );
    widget.onSendMessage(messageToSend);
    _sendMessageController.clear();
    _initTags();
  }

  bool userHasMessageTags(Message message) {
    if (message.sender == userName) {
      return true;
    }
    for (String tag in message.tags.keys) {
      if (message.tags[tag]! && userTags[tag]!) {
        return true;
      }
    }
    return false;
  }

  String _generateMessageHash(Message message) {
    var sortedTags = message.tags.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    String tagsString = sortedTags
        .map((e) => '${e.key}:${e.value.toString()}')
        .join(',');
    return '${message.text}-${message.sender}-$tagsString-${message.time.toIso8601String()}';
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
                        List<Message> messages =
                        box.values.cast<Message>().toList();
                        messages.sort((a, b) => a.time.compareTo(b.time));
                        return Column(
                          spacing: 5,
                          children: messages.fold<List<Widget>>([], (widgets, message) {
                            // Initialize a Set to track seen message hashes
                            Set<String> seenMessages = <String>{};

                            // Generate a unique hash for the message to detect duplicates
                            String messageHash = _generateMessageHash(message);

                            // Check if the message has already been processed (i.e., if it's a duplicate)
                            if (!seenMessages.contains(messageHash) && userHasMessageTags(message)) {
                              seenMessages.add(messageHash); // Mark the message as seen
                              widgets.add(MessageWidget(message: message)); // Add the message to the list
                            }

                            return widgets;
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
                      valueListenable: chatHasSelectedTagNotifier,
                      builder: (context, hasSelectedTag, child) {
                        return IconButton.filledTonal(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 5,
                                      crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                      alignment: WrapAlignment.center,
                                      children: List.generate(
                                        selectedTags.length,
                                            (index) {
                                          return TagButtonWidget(
                                            text: selectedTags.keys
                                                .elementAt(index),
                                            tagMap: selectedTags,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).then((value) {
                              chatHasSelectedTagNotifier.value = false;
                              for (String tag in selectedTags.keys) {
                                if (selectedTags[tag] == true) {
                                  chatHasSelectedTagNotifier.value = true;
                                }
                              }
                            });
                          },
                          icon: const Icon(Icons.tag_rounded),
                          style: ButtonStyle(
                            backgroundColor: hasSelectedTag
                                ? const WidgetStatePropertyAll(Colors.redAccent)
                                : null,
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
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                        ),
                        enableInteractiveSelection: false,
                        enableSuggestions: false,
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: _hasMessage && chatHasSelectedTagNotifier.value
                          ? () {
                        sendButtonClicked();
                      }
                          : null,
                      icon: const Icon(Icons.send_rounded),
                      style: ButtonStyle(
                        backgroundColor: _hasMessage &&
                            chatHasSelectedTagNotifier.value
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