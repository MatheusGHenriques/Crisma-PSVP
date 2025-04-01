import 'package:crisma/data/poll.dart';
import 'package:crisma/data/task.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'data/custom_themes.dart';
import 'data/message.dart';
import 'hive/hive_adapters.dart';
import 'views/pages/login_page.dart';
import 'views/widget_tree.dart';
import 'data/notifiers.dart';
import 'data/user_info.dart';

int colorTheme = 0;
late Box chatBox;
late Box taskBox;
late Box pdfBox;
late Box homeBox;

void main() async {
  await initHive();
  runApp(MyApp());
}

Future<void> initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PdfAdapter());
  Hive.registerAdapter(PollAdapter());

  await Hive.openBox("chatBox");
  await Hive.openBox("taskBox");
  await Hive.openBox("pdfBox");
  await Hive.openBox("homeBox");

  chatBox = Hive.box("chatBox");
  taskBox = Hive.box("taskBox");
  pdfBox = Hive.box("pdfBox");
  homeBox = Hive.box("homeBox");
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
    _initThemeMode();
    _getUser();
    _deleteMessages();
    _deleteTasks();
    super.initState();
  }

  void _initThemeMode() async {
    colorTheme = await homeBox.get('colorTheme') ?? 0;
    bool? darkMode = await homeBox.get('themeMode');
    isDarkModeNotifier.value = darkMode ?? false;
  }

  void _getUser() async {
    userName = await homeBox.get("userName") ?? "";
    for (String tag in userTags.keys) {
      userTags[tag] = await homeBox.get(tag) ?? false;
    }
    setState(() {
      _loaded = true;
    });
  }

  void _deleteMessages() {
    DateTime now = DateTime.now();
    for (Message messageToDelete in chatBox.values) {
      if (messageToDelete.tags.isEmpty && messageToDelete.time.difference(now) > Duration(days: 1)) {
        messageToDelete.delete();
      }
    }
  }

  void _deleteTasks() {
    DateTime now = DateTime.now();
    for (var taskToDelete in taskBox.values) {
      if (taskToDelete.time.difference(now) > Duration(days: 1)) {
        if ((taskToDelete is Task && taskToDelete.numberOfPersons < 0) ||
            taskToDelete is Poll && !taskToDelete.tags.values.contains(true)) {
          taskToDelete.delete();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loaded
        ? ValueListenableBuilder(
          valueListenable: isDarkModeNotifier,
          builder: (context, darkMode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: CustomThemes.mainColor(colorTheme),
                  brightness: darkMode ? Brightness.dark : Brightness.light,
                ),
              ),
              home: userName == "" ? LoginPage() : WidgetTree(),
            );
          },
        )
        : ColoredBox(color: CustomThemes.mainColor(colorTheme));
  }
}
