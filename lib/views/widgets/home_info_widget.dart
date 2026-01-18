import 'package:flutter/material.dart';
import '/main.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';

class HomeInfoWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const HomeInfoWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: responsiveWidth(constraints) / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                color:
                    isDarkMode
                        ? CustomThemes.darkBackgroundColor(
                          colorThemeNotifier.value,
                        )
                        : CustomThemes.lightBackgroundColor(
                          colorThemeNotifier.value,
                        ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: CustomThemes.mainColor(colorThemeNotifier.value),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Icon(icon),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CustomThemes.secondaryDarkColor(
                            colorThemeNotifier.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
