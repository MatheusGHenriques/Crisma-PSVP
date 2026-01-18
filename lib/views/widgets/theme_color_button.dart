import 'package:flutter/material.dart';
import '/data/notifiers.dart';
import '/main.dart';

class ThemeColorButton extends StatelessWidget {
  final BuildContext context;

  const ThemeColorButton({super.key, required this.context});

  void _switchTheme() {
    ++colorThemeNotifier.value == 3
        ? colorThemeNotifier.value = 0
        : colorThemeNotifier.value;
    homeBox.put('colorTheme', colorThemeNotifier.value);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _switchTheme,
      icon: const Icon(Icons.format_paint_rounded),
    );
  }
}
