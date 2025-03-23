import 'package:crisma/main.dart';
import 'package:crisma/views/pages/chat_page.dart';
import 'package:crisma/views/pages/custom_page.dart';
import 'package:crisma/views/pages/home_page.dart';
import 'package:crisma/views/pages/login_page.dart';
import 'package:crisma/views/pages/schedule_page.dart';
import 'package:crisma/views/pages/tasks_page.dart';
import 'package:crisma/views/widgets/navigation_bar_widget.dart';
import 'package:crisma/views/widgets/theme_mode_button.dart';
import 'package:hive_ce/hive.dart';

import '../data/message.dart';
import '../data/notifiers.dart';
import '../data/pdf.dart';
import '../data/task.dart';
import '../data/user_info.dart';
import '../networking/tcp_networking.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  late PeerToPeerTcpNetworking _tcpNetworking;
  int _previousPage = 0;

  @override
  void initState() {
    _initNetworking();
    super.initState();
  }

  @override
  void dispose() {
    _tcpNetworking.dispose();
    super.dispose();
  }

  void _initNetworking() async {
    _tcpNetworking = PeerToPeerTcpNetworking();
    await _tcpNetworking.start();
  }

  void tcpSendMessage(Message messageToSend) {
    _tcpNetworking.sendMessage(messageToSend);
  }

  void tcpSendTask(Task taskToSend) {
    _tcpNetworking.sendTask(taskToSend);
  }

  void tcpSendPdf(Pdf pdfToSend) {
    _tcpNetworking.sendPdf(pdfToSend);
  }

  void _switchTheme() {
    if (colorTheme == 2) {
      Hive.box('homeBox').put('colorTheme', 0);
    } else {
      Hive.box('homeBox').put('colorTheme', colorTheme + 1);
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text('Tema alterado!', style: TextStyle(fontSize: 14)),
                Text('Reinicie o App para aplicar!', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crisma PSVP"),
        centerTitle: true,
        leading: IconButton(onPressed: _switchTheme, icon: Icon(Icons.format_paint_rounded)),
        actions: [
          ThemeModeButton(),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    for (String tag in userTags.keys) {
                      userTags[tag] = false;
                    }
                    userName = "";
                    return LoginPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          final pages = [
            HomePage(tcpNetworking: _tcpNetworking),
            ChatPage(onSendMessage: tcpSendMessage),
            TasksPage(onSendTask: tcpSendTask),
            SchedulePage(onSendPdf: tcpSendPdf),
          ];
          final page = CustomPage(
            key: ValueKey(selectedPage),
            newIndex: selectedPage,
            oldIndex: _previousPage,
            child: pages[selectedPage],
          );
          _previousPage = selectedPage;
          return Navigator(pages: [page]);
        },
      ),
      bottomNavigationBar: NavigationBarWidget(),
    );
  }
}
