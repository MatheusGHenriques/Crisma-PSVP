import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/notifiers.dart';

class TagButtonWidget extends StatefulWidget {
  final String text;
  final Map<String, bool> tagMap;
  final bool? login;

  const TagButtonWidget({super.key, required this.text, required this.tagMap, bool? login}) : login = login ?? false;

  @override
  State<TagButtonWidget> createState() => _TagButtonWidgetState();
}

class _TagButtonWidgetState extends State<TagButtonWidget> {
  bool active = false;

  Map<String, String> groupPasswords = {
    'Coordenação': 'saoPedro',
    'Música': 'santaCecilia',
    'Suporte': 'santoExpedido',
    'Animação': 'saoJoaoBosco',
    'Cozinha': 'saoLourenco',
    'Mídias': 'saoMaximiliano',
    'Homens': 'saoJose',
    'Mulheres': 'santaMaria',
  };

  Future<bool> checkGroupPassword() async{
    TextEditingController controller = TextEditingController();
    ValueNotifier<bool> buttonEnabledNotifier = ValueNotifier(false);
    Completer<bool> completer = Completer<bool>();
    controller.addListener(() {
      if(controller.text.isNotEmpty){
          buttonEnabledNotifier.value = true;
      }
    });
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Digite a senha para entrar no grupo "${widget.text}"',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  TextField(controller: controller, textAlign: TextAlign.center, maxLength: 20, obscureText: true,),
                  ValueListenableBuilder(valueListenable: buttonEnabledNotifier, builder: (context, buttonEnabled, child) {
                    return FilledButton(onPressed: buttonEnabled ? () {
                      if (controller.text == groupPasswords[widget.text]){
                        completer.complete(true);
                      }else{
                        completer.complete(false);
                      }
                      Navigator.pop(context);
                    } : null, child: Text('Entrar'));
                  },),
                ],
              ),
            ),
          ),
        );
      },
    );
    return completer.future;
  }

  bool _oneGenderSelected(){
    return (widget.text == 'Homens' && widget.tagMap['Mulheres']!) || (widget.text == 'Mulheres' && widget.tagMap['Homens']!);
  }

  @override
  Widget build(BuildContext context) {
    active = widget.tagMap[widget.text] ?? false;
    return OutlinedButton(
      onPressed: () async {
        if (widget.tagMap["Geral"] == false || widget.text == "Geral" || widget.tagMap["Geral"] == null) {
          if (widget.text == "Geral") {
            for (String tag in widget.tagMap.keys) {
              if (tag != "Geral" && widget.tagMap[tag]!) {
                return;
              }
            }
          }
          if(widget.login! && !active && _oneGenderSelected()){
            return;
          }
          if (widget.login! && !active && !await checkGroupPassword()) {
            return;
          }
          setState(() {
            active = !active;
          });
          widget.tagMap[widget.text] = active;
          selectedTagsNotifier.value--;
          for (String tag in widget.tagMap.keys) {
            if (widget.tagMap[tag] == true) {
              selectedTagsNotifier.value++;
              return;
            }
          }
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? Colors.white : Colors.redAccent,
        backgroundColor: active ? Colors.redAccent : null,
        side: BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      child: Text(widget.text),
    );
  }
}