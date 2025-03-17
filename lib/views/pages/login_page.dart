import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widget_tree.dart';
import 'package:crisma/views/widgets/tag_button_widget.dart';
import 'package:crisma/views/widgets/theme_mode_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/constants.dart';
import '../../data/user_info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _hasName = false;

  @override
  void initState(){
    super.initState();
    resetUser();
    _nameController.addListener(() {
      setState((){
        _hasName = _nameController.text.isNotEmpty;
      });
    });
  }

  void resetUser() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.username);
    for(String tag in userTags.keys){
      userTags[tag] = false;
    }
  }

  @override
  void dispose() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.username, _nameController.text);
    userName = _nameController.text;
    _nameController.dispose();
    for(String tag in userTags.keys) {
      await prefs.setBool(tag, userTags[tag]!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [ThemeModeButton()]),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20.0,
            children: [
              ValueListenableBuilder(
                valueListenable: isDarkModeNotifier,
                builder: (context, darkMode, child) {
                  return Image.asset(
                    darkMode
                        ? 'assets/images/compact_dark_logo.png'
                        : 'assets/images/compact_light_logo.png',
                    height: 300.0,
                    width: 200.0,
                  );
                },
              ),
              TextField(
                textAlign: TextAlign.center,
                enableSuggestions: false,
                decoration: InputDecoration(hintText: "Digite seu nome aqui"),
                controller: _nameController,
              ),
              Text("Selecione os grupos dos quais voce faz parte:"),
              Wrap(
                spacing: 10.0,
                alignment: WrapAlignment.center,
                children: List.generate(userTags.length,(index) {
                  return TagButtonWidget(text: userTags.keys.elementAt(index), tagMap: userTags,);
                },)
                ,
              ),
              FilledButton(
                onPressed: _hasName? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return WidgetTree();
                      },
                    ),
                  );
                } : null,
                child: Text("Continuar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}