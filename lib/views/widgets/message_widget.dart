import 'package:flutter/material.dart';
import '/main.dart';
import '/views/widgets/home_info_widget.dart';
import '/data/message.dart';
import '/data/user_info.dart';
import '/data/custom_themes.dart';
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
    String hours = message.time.hour < 10 ? '0${message.time.hour}' : message.time.hour.toString();
    String minutes = message.time.minute < 10 ? '0${message.time.minute}' : message.time.minute.toString();
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
                      ? CustomThemes.secondaryLightColor(colorTheme)
                      : isDarkMode
                      ? CustomThemes.darkBackgroundColor(colorTheme)
                      : CustomThemes.lightBackgroundColor(colorTheme),
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
                            color: CustomThemes.mainColor(colorTheme),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _getTags(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: CustomThemes.secondaryDarkColor(colorTheme),
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
                        Text(
                          '$hours:$minutes',
                          textAlign: TextAlign.end,
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    )
                    : InkWell(
                      onLongPress: message.readBy.isNotEmpty? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    children: List.generate(message.readBy.length, (index) {
                                      return HomeInfoWidget(
                                        title: message.readBy.elementAt(index),
                                        description: "Lida",
                                        icon: Icons.mark_chat_read_rounded,
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          Text(
                            _getTags(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CustomThemes.secondaryDarkColor(colorTheme),
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
                          Text("$hours:$minutes", style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }
}
