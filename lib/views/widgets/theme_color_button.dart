import 'package:flutter/material.dart';
import '/main.dart';

class ThemeColorButton extends StatelessWidget {
  final BuildContext context;

  const ThemeColorButton({super.key, required this.context});

  void _switchTheme() {
    if (colorTheme == 2) {
      homeBox.put('colorTheme', 0);
    } else {
      homeBox.put('colorTheme', colorTheme + 1);
    }
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text('Tema alterado!', style: TextStyle(fontSize: 14)),
                Text('Reinicie o App para aplicar!', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: _switchTheme, icon: const Icon(Icons.format_paint_rounded));
  }
}
