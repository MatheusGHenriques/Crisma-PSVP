import 'package:crisma/views/pages/chat_page.dart';
import 'package:crisma/views/pages/home_page.dart';
import 'package:crisma/views/pages/login_page.dart';
import 'package:crisma/views/pages/schedule_page.dart';
import 'package:crisma/views/pages/tasks_page.dart';
import 'package:crisma/views/widgets/navigation_bar_widget.dart';
import 'package:crisma/views/widgets/theme_mode_button.dart';

import '../data/message.dart';
import '../data/notifiers.dart';
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

  @override
  void initState() {
    _initNetworking();
    super.initState();
  }

  void _initNetworking() async {
    _tcpNetworking = PeerToPeerTcpNetworking();
    await _tcpNetworking.start();
  }

  void tcpSendMessage(Message messageToSend) {
    _tcpNetworking.sendMessage(messageToSend);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crisma PSVP"),
        centerTitle: true,
        leading: ValueListenableBuilder(
          valueListenable: hasConnectedPeerNotifier,
          builder: (context, hasConnectedPeer, child) {
            return hasConnectedPeer
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
          final pages = [HomePage(), ChatPage(onSendMessage: tcpSendMessage), TasksPage(), SchedulePage()];

          return Navigator(pages: [MaterialPage(key: ValueKey(selectedPage), child: pages[selectedPage])]);
        },
      ),
      bottomNavigationBar: NavigationBarWidget(),
    );
  }
}
