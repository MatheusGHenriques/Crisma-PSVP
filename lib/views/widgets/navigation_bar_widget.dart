import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '/data/custom_themes.dart';
import '/main.dart';
import '/data/notifiers.dart';

class NavigationBarWidget extends StatelessWidget {
  final void Function(int)? onTabChange;
  const NavigationBarWidget({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context, selectedPage, child) {
          return GNav(
            duration: Duration(milliseconds: 100),
            selectedIndex: selectedPage,
            mainAxisAlignment: MainAxisAlignment.center,
            onTabChange: onTabChange,
            activeColor: isDarkMode ? Colors.white : Colors.black,
            color: isDarkMode ? CustomThemes.secondaryDarkColor(colorTheme) : CustomThemes.secondaryLightColor(colorTheme),
            tabs:[
              GButton(icon: Icons.home_rounded,iconSize: selectedPage == 0 ? 30 : 20,),
              GButton(icon: Icons.message_rounded,iconSize: selectedPage == 1 ? 30 : 20,),
              GButton(icon: Icons.checklist_rtl_rounded,iconSize: selectedPage == 2 ? 30 : 20,),
              GButton(icon: Icons.schedule_rounded,iconSize: selectedPage == 3 ? 30 : 20,),
            ],
          );
        },);
      },
    );
  }
}
