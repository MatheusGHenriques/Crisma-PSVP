import '/services/cryptography/argon2_manager.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/views/widget_tree.dart';
import '/views/widgets/tag_selection_widget.dart';
import '/views/widgets/theme_color_button.dart';
import '/views/widgets/theme_mode_button.dart';
import '/views/widgets/loading_filled_button.dart';
import '/data/user_info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _hasName = false;

  final Map<String, bool> loginTags = {
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
    _resetUser();
    _nameController.addListener(() {
      setState(() {
        _hasName = _nameController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _resetUser() async {
    await homeBox.delete("userName");
    await homeBox.delete("userId");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    userName = _nameController.text.trim();
    selectedPageNotifier.value = 0;

    for (final tag in loginTags.keys) {
      userTags[tag] = loginTags[tag]!;
    }
    userTags['Geral'] = true;

    await Argon2Manager.checkGroupPassword(generalPassword, 'Geral');
    await Argon2Manager.createUserKey();

    await homeBox.put("userName", userName);
    await homeBox.put("userId", userId);

    for (final tag in userTags.keys) {
      await homeBox.put(tag, userTags[tag]!);
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => WidgetTree()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ThemeColorButton(context: context),
        forceMaterialTransparency: true,
        actions: const [ThemeModeButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Lottie.asset(
                  CustomThemes.lottie(colorThemeNotifier.value),
                  width: responsiveWidth(constraints) / 1.3,
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, darkMode, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Image.asset(
                      CustomThemes.image(colorThemeNotifier.value, darkMode),
                      width: responsiveWidth(constraints) / 1.3,
                    );
                  },
                );
              },
            ),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              maxLength: 30,
              decoration: const InputDecoration(
                hintText: "Digite seu nome aqui",
                counterText: "",
              ),
            ),
            const Text(
              "Selecione os grupos dos quais você faz parte:",
              textAlign: TextAlign.center,
            ),
            TagSelectionWidget(tags: loginTags, login: true),
            LoadingFilledButton(
              label: "Continuar",
              onPressed:
                  _hasName && (loginTags['Homens']! || loginTags['Mulheres']!)
                      ? _handleLogin
                      : () async {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
