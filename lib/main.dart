import 'package:crisma/data/custom_colors.dart';
import 'package:crisma/hive/hive_adapters.dart';
import 'package:crisma/views/pages/login_page.dart';
import 'package:crisma/views/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';

import 'data/notifiers.dart';
import 'data/user_info.dart';

late int colorTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PdfAdapter());
  await Hive.openBox("chatBox");
  await Hive.openBox("taskBox");
  await Hive.openBox("pdfBox");
  await Hive.openBox("homeBox");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loaded = false;
  final Box _homeBox = Hive.box("homeBox");

  @override
  void initState() {
    initThemeMode();
    getUser();
    super.initState();
  }

  void initThemeMode() async {
    bool? darkMode = await _homeBox.get('themeMode');
    isDarkModeNotifier.value = darkMode ?? false;
    colorTheme = await _homeBox.get('colorTheme') ?? 0;
  }

  void getUser() async {
    userName = await _homeBox.get("userName") ?? "";
    for (String tag in userTags.keys) {
      userTags[tag] = await _homeBox.get(tag) ?? false;
    }
    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child:
          _loaded
              ? ValueListenableBuilder(
                valueListenable: isDarkModeNotifier,
                builder: (context, darkMode, child) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: CustomColors.mainColor(colorTheme),
                        brightness: darkMode ? Brightness.dark : Brightness.light,
                      ),
                    ),
                    home: userName == "" ? LoginPage() : WidgetTree(),
                  );
                },
              )
              : ColoredBox(color: CustomColors.mainColor(colorTheme)),
    );
  }
}
