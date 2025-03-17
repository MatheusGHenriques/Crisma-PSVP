import 'package:crisma/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: ""),
            NavigationDestination(icon: Icon(Icons.chat_rounded), label: ""),
            NavigationDestination(
              icon: Icon(Icons.checklist_rtl_rounded),
              label: "",
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule_rounded),
              label: "",
            ),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
