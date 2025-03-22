import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import '../../data/notifiers.dart';

class ThemeModeButton extends StatefulWidget {
  const ThemeModeButton({super.key});

  @override
  State<ThemeModeButton> createState() => _ThemeModeButtonState();
}

class _ThemeModeButtonState extends State<ThemeModeButton> {
  final Box _homeBox = Hive.box("homeBox");

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async{
        isDarkModeNotifier.value = !isDarkModeNotifier.value;
        await _homeBox.put("themeModeKey", isDarkModeNotifier.value);
      },
      icon: ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, darkMode, child) {
          return Icon(
            darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          );
        },
      ),
    );
  }
}