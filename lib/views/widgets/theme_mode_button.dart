import 'package:crisma/data/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/notifiers.dart';

class ThemeModeButton extends StatefulWidget {
  const ThemeModeButton({super.key});

  @override
  State<ThemeModeButton> createState() => _ThemeModeButtonState();
}

class _ThemeModeButtonState extends State<ThemeModeButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async{
        isDarkModeNotifier.value = !isDarkModeNotifier.value;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool(Constants.themeModeKey, isDarkModeNotifier.value);
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
