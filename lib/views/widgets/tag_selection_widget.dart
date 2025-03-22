import 'package:crisma/views/widgets/tag_button_widget.dart';
import 'package:flutter/material.dart';

class TagSelectionWidget extends StatefulWidget {
  final Map<String, bool> tags;
  final bool login;

  const TagSelectionWidget({super.key, required this.tags, bool? login}) : login = login ?? false;

  @override
  State<TagSelectionWidget> createState() => _TagSelectionWidgetState();
}

class _TagSelectionWidgetState extends State<TagSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: List.generate(widget.tags.length, (index) {
        return TagButtonWidget(text: widget.tags.keys.elementAt(index), tagMap: widget.tags, login: widget.login);
      }),
    );
  }
}
