import 'package:crisma/data/custom_colors.dart';
import 'package:crisma/main.dart';
import 'package:flutter/material.dart';

import '../../data/notifiers.dart';

class HomeInfoWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;

  const HomeInfoWidget({super.key, required this.title, required this.description, required this.icon});

  @override
  State<HomeInfoWidget> createState() => _HomeInfoWidgetState();
}

class _HomeInfoWidgetState extends State<HomeInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color:
                isDarkMode
                    ? CustomColors.darkBackgroundColor(colorTheme)
                    : CustomColors.lightBackgroundColor(colorTheme),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                widget.title,
                style: TextStyle(color: CustomColors.mainColor(colorTheme), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Icon(widget.icon),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CustomColors.secondaryDarkColor(colorTheme)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
