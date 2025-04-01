import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '/data/custom_themes.dart';
import '/data/message.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/views/widgets/message_widget.dart';
import '/views/widgets/tag_selection_widget.dart';
import '/data/user_info.dart';

class ChatPage extends StatefulWidget {
  final Function(Message) onSendMessage;

  const ChatPage({super.key, required this.onSendMessage});

  static bool userHasMessageTags(Message message) {
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

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _sendMessageController = TextEditingController();
  String _stringTags = "";
  Map<String, bool> selectedTags = {
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

  @override
  void initState() {
    selectedTagsNotifier.value = 0;
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
    Map<String, bool> newTags = Map<String, bool>.from(selectedTags);
    Message messageToSend = Message(tags: newTags, sender: userName, text: _sendMessageController.text.trim());
    widget.onSendMessage(messageToSend);
    _sendMessageController.clear();
  }

  @override
  void dispose() {
    _sendMessageController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unreadMessagesNotifier.value = 0;
    });
    super.dispose();
  }

  bool _messageHasUserTags(Message message) {
    for (String key in message.tags.keys) {
      if (message.tags[key]! && userTags[key]!) return true;
    }
    return false;
  }

  void _readMessages() {
    for (Message boxMessage in chatBox.values) {
      if (boxMessage.sender != userName && !boxMessage.readBy.contains(userName) && _messageHasUserTags(boxMessage)) {
        List<String> readBy = List.from(boxMessage.readBy);
        readBy.add(userName);
        Message messageToSend = Message(
          tags: boxMessage.tags,
          sender: boxMessage.sender,
          text: boxMessage.text,
          readBy: readBy,
          time: boxMessage.time,
        );
        widget.onSendMessage(messageToSend);
      }
    }
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
                        _readMessages();
                        List<Message> messages = box.values.cast<Message>().toList();
                        messages.sort((a, b) => a.time.compareTo(b.time));

                        messages.removeWhere((element) {
                          return !ChatPage.userHasMessageTags(element) || element.tags.isEmpty;
                        });
                        int newMessagesIndicatorPosition = messages.length - unreadMessagesNotifier.value;
                        return unreadMessagesNotifier.value > 0 && messages.isNotEmpty
                            ? Column(
                              spacing: 5,
                              children: List.generate(messages.length + 1, (index) {
                                return newMessagesIndicatorPosition == index
                                    ? const Row(
                                      children: [
                                        Expanded(child: Divider(thickness: 2)),
                                        Text(" Novas Mensagens "),
                                        Expanded(child: Divider(thickness: 2)),
                                      ],
                                    )
                                    : newMessagesIndicatorPosition < index
                                    ? MessageWidget(
                                      message: messages.elementAt(index - 1),
                                      onSendMessage: widget.onSendMessage,
                                    )
                                    : MessageWidget(
                                      message: messages.elementAt(index),
                                      onSendMessage: widget.onSendMessage,
                                    );
                              }),
                            )
                            : messages.isNotEmpty
                            ? Column(
                              spacing: 5,
                              children: List.generate(messages.length, (index) {
                                return MessageWidget(
                                  message: messages.elementAt(index),
                                  onSendMessage: widget.onSendMessage,
                                );
                              }),
                            )
                            : const Column(children: []);
                      },
                    ),
                  ),
                ),
                Row(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: selectedTagsNotifier,
                      builder: (context, selectedTagsNumber, child) {
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
                            backgroundColor:
                                selectedTagsNumber > 0
                                    ? WidgetStatePropertyAll(CustomThemes.mainColor(colorTheme))
                                    : null,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: selectedTagsNotifier,
                        builder: (context, selectedTagsNumber, child) {
                          _stringTags = "";
                          for (String tag in selectedTags.keys) {
                            if (selectedTags[tag]!) {
                              _stringTags += "@$tag ";
                            }
                          }
                          return TextField(
                            controller: _sendMessageController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: selectedTagsNumber > 0 ? _stringTags : "Digite uma mensagem",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed:
                          _hasMessage && selectedTagsNotifier.value > 0
                              ? () {
                                sendButtonClicked();
                              }
                              : null,
                      icon: const Icon(Icons.send_rounded),
                      style: ButtonStyle(
                        backgroundColor:
                            _hasMessage && selectedTagsNotifier.value > 0
                                ? WidgetStatePropertyAll(CustomThemes.mainColor(colorTheme))
                                : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}
