import 'package:flutter/material.dart';
import '/main.dart';

class ThemeColorButton extends StatelessWidget {
  final BuildContext context;

  const ThemeColorButton({super.key, required this.context});

  void _switchTheme() {
    ++colorTheme == 3 ? colorTheme = 0 : colorTheme;
    homeBox.put('colorTheme', colorTheme);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyApp(),), (route) => false,);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: _switchTheme, icon: const Icon(Icons.format_paint_rounded));
  }
}
