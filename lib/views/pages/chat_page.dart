import 'package:crisma/data/message.dart';
import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widgets/message_widget.dart';
import 'package:crisma/views/widgets/tag_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '../../data/user_info.dart';
import '../../networking/udp_networking.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _sendMessageController = TextEditingController();
  late Map<String, bool> selectedTags;
  bool _hasMessage = false;

  late List<String> tags;
  final chatBox = Hive.box("chatBox");

  late UdpNetworking _udpNetworking;

  @override
  void initState() {
    _initController();
    _initTags();
    _initNetworking();
    super.initState();
  }

  void _initNetworking() {
    _udpNetworking = UdpNetworking(
      deviceName: userName!,
      onMessageReceived: (Message message) {
        bool isDuplicate = chatBox.values.cast<Message>().any(
          (msg) => msg.sender == message.sender && msg.text == message.text && msg.time == message.time,
        );
        if (!isDuplicate) {
          chatBox.add(message);
        }
      },
    );
    _udpNetworking.start();
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

  void sendMessage() {
    final newTags = Map<String, bool>.from(selectedTags);
    Message messageToSend = Message(tags: newTags, sender: userName!, text: _sendMessageController.text);
    _udpNetworking.sendMessage(messageToSend);
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
              spacing: 10,
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
                          children:
                              messages.map((message) {
                                if (userHasMessageTags(message)) {
                                  return MessageWidget(message: message);
                                }
                                return SizedBox();
                              }).toList(),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 5,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      alignment: WrapAlignment.center,
                                      children: List.generate(selectedTags.length, (index) {
                                        return TagButtonWidget(
                                          text: selectedTags.keys.elementAt(index),
                                          tagMap: selectedTags,
                                        );
                                      }),
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
                            backgroundColor: hasSelectedTag ? const WidgetStatePropertyAll(Colors.redAccent) : null,
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
                        backgroundColor:
                            _hasMessage && chatHasSelectedTagNotifier.value
                                ? const WidgetStatePropertyAll(Colors.redAccent)
                                : null,
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