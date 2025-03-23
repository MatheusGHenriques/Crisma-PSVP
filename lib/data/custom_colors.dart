import 'package:flutter/material.dart';

class CustomColors {
  static final List<Color> _mainColor = [Colors.redAccent, Colors.greenAccent[400]!, Colors.blue];
  static final List<Color> _secondaryDarkColor = [Colors.red[900]!, Colors.green[900]!, Colors.blue[900]!];
  static final List<Color> _secondaryLightColor = [Colors.red[300]!, Colors.green[300]!, Colors.blue[300]!];
  static final List<Color> _darkModeBackgroundColor = [
    Color.alphaBlend(Colors.red.withAlpha(30), Colors.black38),
    Color.alphaBlend(Colors.green.withAlpha(30), Colors.black38),
    Color.alphaBlend(Colors.blue.withAlpha(30), Colors.black38),
  ];
  static final List<Color> _lightModeBackgroundColor = [
    Color.alphaBlend(Colors.red.withAlpha(50), Colors.white),
    Color.alphaBlend(Colors.green.withAlpha(50), Colors.white),
    Color.alphaBlend(Colors.blue.withAlpha(50), Colors.white),
  ];
  static final List<String> lightModeImages = [
    'assets/images/compact_light_logo.png',
    '',
    'assets/images/light_mini_logo.png',
  ];
  static final List<String> darkModeImages = [
    'assets/images/compact_dark_logo.png',
    '',
    'assets/images/dark_mini_logo.png',
  ];

  static Color mainColor(int index) {
    return _mainColor.elementAt(index);
  }

  static Color secondaryDarkColor(int index) {
    return _secondaryDarkColor.elementAt(index);
  }

  static Color secondaryLightColor(int index) {
    return _secondaryLightColor.elementAt(index);
  }

  static Color darkBackgroundColor(int index) {
    return _darkModeBackgroundColor.elementAt(index);
  }

  static Color lightBackgroundColor(int index) {
    return _lightModeBackgroundColor.elementAt(index);
  }

  static String image(int index, bool darkMode) {
    return darkMode ? darkModeImages.elementAt(index) : lightModeImages.elementAt(index);
  }
}
