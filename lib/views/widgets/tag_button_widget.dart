import 'package:flutter/material.dart';

import '../../data/notifiers.dart';

class TagButtonWidget extends StatefulWidget {
  final String text;
  final Map<String, bool> tagMap;
  const TagButtonWidget({super.key, required this.text, required this.tagMap});

  @override
  State<TagButtonWidget> createState() => _TagButtonWidgetState();
}

class _TagButtonWidgetState extends State<TagButtonWidget> {
  bool active = false;
  @override
  Widget build(BuildContext context) {
    active = widget.tagMap[widget.text]?? false;
    return OutlinedButton(onPressed: (){
      if(widget.tagMap["Geral"] == false || widget.text == "Geral" || widget.tagMap["Geral"] == null){
        if(widget.text == "Geral"){
          for(String tag in widget.tagMap.keys){
            if(tag != "Geral" && widget.tagMap[tag]!){
              return;
            }
          }
        }
      setState(() {
        active = !active;
      });
      widget.tagMap[widget.text] = active;
      hasSelectedTagNotifier.value = false;
      for (String tag in widget.tagMap.keys) {
        if (widget.tagMap[tag] == true) {
          hasSelectedTagNotifier.value = true;
          return;
        }
      }
      }
    },
      style: OutlinedButton.styleFrom(
        foregroundColor: active? Colors.white : Colors.redAccent,
        backgroundColor: active? Colors.redAccent : null,
        side: BorderSide(
          color: Colors.redAccent,
          width: 2.0,
        )
      ), child: Text(widget.text),
    );
  }
}