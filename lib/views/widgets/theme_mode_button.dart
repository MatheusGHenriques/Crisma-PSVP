import 'package:flutter/material.dart';
import '/data/notifiers.dart';
import '/main.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        isDarkModeNotifier.value = !isDarkModeNotifier.value;
        await homeBox.put("themeMode", isDarkModeNotifier.value);
      },
      icon: ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, darkMode, child) {
          return Icon(darkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded);
        },
      ),
    );
  }
}
