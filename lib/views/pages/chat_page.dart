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
    Message messageToSend = Message(tags: newTags, sender: userName, text: _sendMessageController.text);
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
                            return MessageWidget(message: messages.elementAt(index));
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
                    Expanded(
                      child: TextField(
                        controller: _sendMessageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Digite uma mensagem",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed:
                          _hasMessage && chatHasSelectedTagNotifier.value
                              ? () {
                                sendButtonClicked();
                              }
                              : _hasMessage
                              ? () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: TagSelectionWidget(tags: selectedTags),
                                      ),
                                    );
                                  },
                                ).then((value) {
                                  for (String tag in selectedTags.keys) {
                                    if (selectedTags[tag]!) {
                                      chatHasSelectedTagNotifier.value = true;
                                    }
                                  }
                                });
                              }
                              : null, //talvez mandar um audio
                      icon: ValueListenableBuilder(
                        valueListenable: chatHasSelectedTagNotifier,
                        builder: (context, chatHasSelectedTag, child) {
                          return _hasMessage && chatHasSelectedTag
                              ? Icon(Icons.send_rounded)
                              : _hasMessage
                              ? Icon(Icons.tag_rounded)
                              : Icon(Icons.chat_rounded);
                        },
                      ),
                      style: ButtonStyle(
                        backgroundColor:
                            _hasMessage && chatHasSelectedTagNotifier.value
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
