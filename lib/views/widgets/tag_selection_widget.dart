import '/views/widgets/tag_button_widget.dart';
import 'package:flutter/material.dart';

class TagSelectionWidget extends StatelessWidget {
  final Map<String, bool> tags;
  final bool login;

  const TagSelectionWidget({super.key, required this.tags, bool? login}) : login = login ?? false;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: List.generate(tags.length, (index) {
        return TagButtonWidget(text: tags.keys.elementAt(index), tagMap: tags, login: login);
      }),
    );
  }
}
