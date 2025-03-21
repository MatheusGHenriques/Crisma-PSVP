import 'dart:developer';

import 'package:crisma/views/pages/chat_page.dart';
import 'package:crisma/views/pages/custom_page.dart';
import 'package:crisma/views/pages/home_page.dart';
import 'package:crisma/views/pages/login_page.dart';
import 'package:crisma/views/pages/schedule_page.dart';
import 'package:crisma/views/pages/tasks_page.dart';
import 'package:crisma/views/widgets/navigation_bar_widget.dart';
import 'package:crisma/views/widgets/theme_mode_button.dart';

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

  void tcpSendTask(Task taskToSend){
    _tcpNetworking.sendTask(taskToSend);
  }

  void tcpSendPdf(Pdf pdfToSend){
    _tcpNetworking.sendPdf(pdfToSend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crisma PSVP"),
        centerTitle: true,
        leading: ValueListenableBuilder(
          valueListenable: connectedPeersNotifier,
          builder: (context, connectedPeers, child) {
            return connectedPeers > 0
                ? Icon(Icons.signal_wifi_4_bar_rounded)
                : IconButton(
                  onPressed: _tcpNetworking.sendUdpDiscoveryRequest,
                  icon: Icon(Icons.signal_wifi_off_rounded),
                );
          },
        ),
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
          final pages = [HomePage(tcpNetworking: _tcpNetworking,), ChatPage(onSendMessage: tcpSendMessage), TasksPage(onSendTask: tcpSendTask), SchedulePage(onSendPdf: tcpSendPdf,)];
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
