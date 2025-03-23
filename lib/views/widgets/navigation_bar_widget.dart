import 'package:flutter/material.dart';
import '/data/notifiers.dart';

class NavigationBarWidget extends StatelessWidget {
  const NavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          height: 70,
          labelPadding: EdgeInsets.zero,
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_rounded), label: ""),
            NavigationDestination(icon: const Icon(Icons.chat_rounded), label: ""),
            NavigationDestination(icon: const Icon(Icons.checklist_rtl_rounded), label: ""),
            NavigationDestination(icon: const Icon(Icons.schedule_rounded), label: ""),
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
