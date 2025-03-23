import 'package:flutter/material.dart';
import '/data/message.dart';
import '/data/user_info.dart';
import '/main.dart';
import '/data/custom_colors.dart';
import '/data/notifiers.dart';

class MessageWidget extends StatelessWidget {
  final Message message;

  const MessageWidget({super.key, required this.message});

  String _getTags() {
    String tags = "";
    for (String tag in message.tags.keys) {
      if (message.tags[tag]!) {
        tags += "@$tag ";
      }
    }
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sender == userName ? Alignment.centerRight : Alignment.centerLeft,
      child: ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color:
                  message.sender == userName
                      ? CustomColors.secondaryLightColor(colorTheme)
                      : isDarkMode
                      ? CustomColors.darkBackgroundColor(colorTheme)
                      : CustomColors.lightBackgroundColor(colorTheme),
            ),
            child:
                message.sender != userName
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(
                          message.sender,
                          style: TextStyle(
                            color: CustomColors.mainColor(colorTheme),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _getTags(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.secondaryDarkColor(colorTheme),
                          ),
                        ),
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 5,
                      children: [
                        Text(
                          _getTags(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomColors.secondaryDarkColor(colorTheme),
                          ),
                        ),
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          );
        },
      ),
    );
  }
}
