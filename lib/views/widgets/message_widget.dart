import 'package:crisma/data/message.dart';
import 'package:crisma/data/user_info.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sender == userName? Alignment.centerRight : Alignment.centerLeft,
      child:  Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: Border.all(width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.text,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}