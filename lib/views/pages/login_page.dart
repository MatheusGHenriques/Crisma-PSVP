import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/views/widget_tree.dart';
import '/views/widgets/tag_selection_widget.dart';
import '/views/widgets/theme_color_button.dart';
import '/views/widgets/theme_mode_button.dart';
import '/data/user_info.dart';

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
    resetUser();
    _nameController.addListener(() {
      setState(() {
        _hasName = _nameController.text.isNotEmpty;
      });
    });
    super.initState();
  }

  void resetUser() async {
    await homeBox.delete("userName");
  }

  @override
  void dispose() {
    super.dispose();
  }

  void pressedContinueButton() async {
    userName = _nameController.text;
    selectedPageNotifier.value = 0;
    for (String tag in loginTags.keys) {
      userTags[tag] = loginTags[tag]!;
    }
    userTags["Geral"] = true;
    await homeBox.put("userName", userName);
    for (String tag in userTags.keys) {
      await homeBox.put(tag, userTags[tag]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: ThemeColorButton(context: context), actions: [ThemeModeButton()]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            Lottie.asset(
              CustomThemes.lottie(colorTheme),
              width: MediaQuery.of(context).size.width / 2,
            ),
            ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, darkMode, child) {
                return Image.asset(
                  CustomThemes.image(colorTheme, darkMode),
                  width: MediaQuery.of(context).size.width / 2,
                );
              },
            ),
            TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(hintText: "Digite seu nome aqui"),
              controller: _nameController,
            ),
            const Text("Selecione os grupos dos quais você faz parte:", textAlign: TextAlign.center),
            TagSelectionWidget(tags: loginTags, login: true),
            ValueListenableBuilder(
              valueListenable: selectedTagsNotifier,
              builder: (context, selectedTagsNumber, child) {
                return FilledButton(
                  onPressed:
                      _hasName && (loginTags['Homens']! || loginTags['Mulheres']!)
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
                  child: const Text("Continuar"),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
