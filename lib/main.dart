import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '/data/poll.dart';
import '/data/task.dart';
import '/data/message.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/data/user_info.dart';
import '/services/storage/hive/hive_adapters.dart';
import 'views/pages/login_page.dart';
import 'views/widget_tree.dart';

late Box chatBox;
late Box taskBox;
late Box pdfBox;
late Box homeBox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  await _initSession();
  await _initTheme();

  runApp(const MyApp());
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PdfAdapter());
  Hive.registerAdapter(PollAdapter());

  chatBox = await Hive.openBox('chatBox');
  taskBox = await Hive.openBox('taskBox');
  pdfBox = await Hive.openBox('pdfBox');
  homeBox = await Hive.openBox('homeBox');
}

Future<void> _initSession() async {
  userName = await homeBox.get('userName');
  userId = await homeBox.get('userId');

  for (final tag in userTags.keys) {
    userTags[tag] = await homeBox.get(tag) ?? false;
  }
}

Future<void> _initTheme() async {
  colorThemeNotifier.value = await homeBox.get('colorTheme') ?? 0;
  isDarkModeNotifier.value = await homeBox.get('themeMode') ?? false;
}

double responsiveWidth(BoxConstraints constraints) {
  if (constraints.maxWidth < 600) return 300;
  if (constraints.maxWidth < 1200) return 600;
  return 300;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _cleanupOldData();
    return ValueListenableBuilder(
      valueListenable: colorThemeNotifier,
      builder: (context, value, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkModeNotifier,
          builder: (context, darkMode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: CustomThemes.mainColor(colorThemeNotifier.value),
                  brightness: darkMode ? Brightness.dark : Brightness.light,
                ),
              ),
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final double contentWidth =
                        screenWidth < 600 ? screenWidth : 600;
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      alignment: Alignment.topCenter,
                      child: SizedBox(width: contentWidth, child: child),
                    );
                  },
                );
              },
              home:
                  userName == null || userName!.isEmpty
                      ? LoginPage()
                      : WidgetTree(),
            );
          },
        );
      },
    );
  }

  void _cleanupOldData() {
    final now = DateTime.now();

    for (final message in chatBox.values) {
      if (message is Message &&
          message.encryptedAesKey.isEmpty &&
          now.difference(message.time) > const Duration(days: 1)) {
        message.delete();
      }
    }

    for (final task in taskBox.values) {
      if (now.difference(task.time) > const Duration(days: 1)) {
        if ((task is Task && task.numberOfPersons < 0) ||
            (task is Poll && task.encryptedAesKey.isEmpty)) {
          task.delete();
        }
      }
    }
  }
}
