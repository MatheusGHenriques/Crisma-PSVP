import 'package:crisma/data/message.dart';
import 'package:crisma/data/user_info.dart';
import 'package:flutter/material.dart';

import '../../data/notifiers.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget({super.key, required this.message});

  String _getTags() {
    bool allTagged = true;
    String tags = "";
    for (String tag in message.tags.keys) {
      if (message.tags[tag]!) {
        tags += "@$tag ";
      } else {
        allTagged = false;
      }
    }
    return allTagged ? "@Todos" : tags;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sender == userName ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: Border.all(width: 2),
          color: message.sender == userName ? Colors.red[300] : null,
        ),
        child: ValueListenableBuilder(
          valueListenable: isDarkModeNotifier,
          builder: (context, isDarkMode, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                message.sender != userName
                    ? Text(
                      message.sender,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    )
                    : const SizedBox(),
                Text(_getTags(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[900])),
                Text(message.text, style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : null, fontWeight: FontWeight.bold)),
              ],
            );
          },
        ),
      ),
    );
  }
}