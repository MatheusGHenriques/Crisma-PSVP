import 'package:flutter/material.dart';

import '../../data/notifiers.dart';

class HomeInfoWidget extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  const HomeInfoWidget({super.key, required this.title, required this.description, required this.icon});

  @override
  State<HomeInfoWidget> createState() => _HomeInfoWidgetState();
}

class _HomeInfoWidgetState extends State<HomeInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: isDarkModeNotifier, builder: (context, value, child) {
      return Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width/2.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            color:
            isDarkModeNotifier.value
                ? Color.alphaBlend(Colors.red.withAlpha(30), Colors.black38)
                : Color.alphaBlend(Colors.red.withAlpha(50), Colors.white),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Icon(widget.icon),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[900]),
                  ),
                ],
              ),
            ],
          ),
      );
    },);
  }
}
