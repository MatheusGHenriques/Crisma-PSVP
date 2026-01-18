import '/services/cryptography/aes_manager.dart';
import 'package:flutter/material.dart';
import '/views/widgets/home_info_widget.dart';
import '/data/message.dart';
import '/data/user_info.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import 'dart:developer';

class MessageWidget extends StatefulWidget {
  final Message message;
  final Function(Message) onSendMessage;

  const MessageWidget({
    super.key,
    required this.message,
    required this.onSendMessage,
  });

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  String? _decryptedText;
  bool _loading = true;
  bool _error = false;

  String _getTags() {
    String tags = "";
    for (final tag in widget.message.encryptedAesKey.keys) {
      if (userTags.keys.contains(tag)) {
        tags += "@$tag ";
      }
    }
    return tags;
  }

  @override
  void initState() {
    super.initState();
    if (_loading) {
      _decryptText();
    }
    _decryptText();
  }

  @override
  void didUpdateWidget(covariant MessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message != widget.message) {
      _decryptedText = null;
      _loading = true;
      _error = false;
      _decryptText();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _decryptText() async {
    try {
      final decrypted = await AesManager.decryptMessage(widget.message);
      if (!mounted) return;

      setState(() {
        _decryptedText = decrypted.text;
        _loading = false;
        _error = false;
      });
    } catch (e, st) {
      log('decrypt text error: $e\n$st');
      if (!mounted) return;

      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sender = widget.message.sender;
    final tags = _getTags();

    final hours = widget.message.time.hour.toString().padLeft(2, '0');
    final minutes = widget.message.time.minute.toString().padLeft(2, '0');

    final bubbleColor =
        widget.message.encryptedAesKey.keys.contains(userId)
            ? CustomThemes.secondaryLightColor(colorThemeNotifier.value)
            : (isDarkModeNotifier.value
                ? CustomThemes.darkBackgroundColor(colorThemeNotifier.value)
                : CustomThemes.lightBackgroundColor(colorThemeNotifier.value));

    return Align(
      alignment:
          widget.message.encryptedAesKey.keys.contains(userId)
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth - 100,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  color: bubbleColor,
                ),
                child:
                    !widget.message.encryptedAesKey.keys.contains(userId)
                        ? _buildReceivedMessage(
                          sender,
                          tags,
                          hours,
                          minutes,
                          isDarkMode,
                        )
                        : _buildSentMessage(tags, hours, minutes, isDarkMode),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReceivedMessage(
    String sender,
    String tags,
    String hours,
    String minutes,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sender,
          style: TextStyle(
            color: CustomThemes.mainColor(colorThemeNotifier.value),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (tags.isNotEmpty)
          Text(
            tags,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CustomThemes.secondaryDarkColor(colorThemeNotifier.value),
            ),
          ),
        const SizedBox(height: 6),
        _buildTextArea(isDarkMode),
        const SizedBox(height: 6),
        Text('$hours:$minutes', style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildSentMessage(
    String tags,
    String hours,
    String minutes,
    bool isDarkMode,
  ) {
    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder:
              (dialogContext) => Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        FilledButton(
                          onPressed: () {
                            final newMessage = Message(
                              encryptedAesKey: {},
                              sender: userName!,
                              text: widget.message.text,
                              time: widget.message.time,
                              readBy: widget.message.readBy,
                            );
                            widget.onSendMessage(newMessage);
                            Navigator.pop(dialogContext);
                          },
                          child: const Text('Apagar Mensagem'),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children:
                              widget.message.readBy.map((user) {
                                return HomeInfoWidget(
                                  title: user,
                                  description: 'Lida',
                                  icon: Icons.mark_chat_read_rounded,
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isNotEmpty)
            Text(
              tags,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CustomThemes.secondaryDarkColor(
                  colorThemeNotifier.value,
                ),
              ),
            ),
          const SizedBox(height: 6),
          _buildTextArea(isDarkMode),
          const SizedBox(height: 6),
          Text('$hours:$minutes', style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTextArea(bool isDarkMode) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child:
          _loading
              ? Text(
                '•' * 3,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white54 : Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              )
              : _error
              ? const ListTile(
                leading: Icon(Icons.error, color: Colors.red),
                title: Text('Não foi possível carregar esta mensagem'),
                contentPadding: EdgeInsets.zero,
              )
              : Text(
                _decryptedText ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : null,
                ),
              ),
    );
  }
}
