import 'package:crisma/data/constants.dart';
import 'package:crisma/hive/hive_adapters.dart';
import 'package:crisma/views/pages/login_page.dart';
import 'package:crisma/views/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/notifiers.dart';
import 'data/user_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox("chatBox");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    initThemeMode();
    getUser();
  }

  void initThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? darkMode = prefs.getBool(Constants.themeModeKey);
    isDarkModeNotifier.value = darkMode ?? false;
  }

  void getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(Constants.username);
    for (String tag in userTags.keys) {
      userTags[tag] = prefs.getBool(tag) ?? false;
    }
    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
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
                        seedColor: Colors.redAccent,
                        brightness: darkMode ? Brightness.dark : Brightness.light,
                      ),
                    ),
                    home: userName == null ? LoginPage() : WidgetTree(),
                  );
                },
              )
              : Container(
                color: Colors.redAccent,
                child: Center(child: Image.asset('assets/images/compact_dark_logo.png', width: 100, height: 150)),
              ),
    );
  }
}
