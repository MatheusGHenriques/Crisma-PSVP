import 'package:crisma/data/notifiers.dart';
import 'package:crisma/views/widget_tree.dart';
import 'package:crisma/views/widgets/tag_selection_widget.dart';
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
  Map<String, bool> loginTags = {
    "Coordenação": false,
    "Música": false,
    "Suporte": false,
    "Animação": false,
    "Cozinha": false,
    "Mídias": false,
    "Homens": false,
    "Mulheres": false,
  };

  @override
  void initState() {
    super.initState();
    resetUser();
    _nameController.addListener(() {
      setState(() {
        _hasName = _nameController.text.isNotEmpty;
      });
    });
  }

  void resetUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.username);
  }

  @override
  void dispose(){
    super.dispose();
  }

  void pressedContinueButton() async {
    userName = _nameController.text;
    selectedPageNotifier.value = 0;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String tag in loginTags.keys) {
      userTags[tag] = loginTags[tag]!;
    }
    await prefs.setString(Constants.username, userName);
    for (String tag in userTags.keys) {
      await prefs.setBool(tag, userTags[tag]!);
    }
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
                    darkMode ? 'assets/images/compact_dark_logo.png' : 'assets/images/compact_light_logo.png',
                    height: 200.0,
                    width: 117.0,
                  );
                },
              ),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: "Digite seu nome aqui"),
                controller: _nameController,
              ),
              Text("Selecione os grupos dos quais você faz parte:", textAlign: TextAlign.center),
              TagSelectionWidget(tags: loginTags),
              FilledButton(
                onPressed:
                    _hasName
                        ? () {
                          pressedContinueButton();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return WidgetTree();
                              },
                            ),
                          );
                        }
                        : null,
                child: Text("Continuar"),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}