import 'package:flutter/material.dart';
import '/views/pages/chat_page.dart';
import '/views/pages/page_animation.dart';
import '/views/pages/home_page.dart';
import '/views/pages/login_page.dart';
import '/views/pages/schedule_page.dart';
import '/views/pages/tasks_page.dart';
import '/views/widgets/navigation_bar_widget.dart';
import '/views/widgets/theme_color_button.dart';
import '/views/widgets/theme_mode_button.dart';
import '/data/message.dart';
import '/data/notifiers.dart';
import '/data/pdf.dart';
import '/data/task.dart';
import '/data/user_info.dart';
import '/networking/tcp_networking.dart';

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

  void tcpSendTask(dynamic taskToSend) {
    taskToSend is Task ?
    _tcpNetworking.sendTask(taskToSend) : _tcpNetworking.sendPoll(taskToSend);
  }

  void tcpSendPdf(Pdf pdfToSend) {
    _tcpNetworking.sendPdf(pdfToSend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crisma PSVP"),
        centerTitle: true,
        leading: ThemeColorButton(context: context),
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
            icon: const Icon(Icons.logout_rounded),
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
          final page = PageAnimation(
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
