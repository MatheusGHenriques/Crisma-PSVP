import 'package:crisma/main.dart';

import '/services/networking.dart';
import '/data/user_info.dart';
import '/views/pages/music_page.dart';
import 'package:flutter/material.dart';
import '/views/widgets/logout_button.dart';
import '/views/pages/chat_page.dart';
import '/views/pages/page_animation.dart';
import '/views/pages/home_page.dart';
import '/views/pages/schedule_page.dart';
import '/views/pages/tasks_page.dart';
import '/views/widgets/navigation_bar_widget.dart';
import '/views/widgets/theme_color_button.dart';
import '/views/widgets/theme_mode_button.dart';
import '/data/message.dart';
import '/data/notifiers.dart';
import '/data/pdf.dart';
import '/data/task.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  late PeerToPeerNetworking _networking;
  int _previousPage = 0;

  @override
  void initState() {
    unreadMessagesNotifier.value = homeBox.get('unreadMessages') ?? 0;
    newTasksNotifier.value = homeBox.get('newTasks') ?? 0;
    newPollsNotifier.value = homeBox.get('newPolls') ?? 0;
    newCiphersNotifier.value = homeBox.get('newCiphers') ?? 0;
    updatedScheduleNotifier.value = homeBox.get('updatedSchedule') ?? false;
    _initNetworking();
    super.initState();
  }

  @override
  void dispose() {
    _networking.dispose();
    homeBox.put('unreadMessages', unreadMessagesNotifier.value);
    homeBox.put('newTasks', newTasksNotifier.value);
    homeBox.put('newPolls', newPollsNotifier.value);
    homeBox.put('newCiphers', newCiphersNotifier.value);
    homeBox.put('updatedSchedule', updatedScheduleNotifier.value);
    super.dispose();
  }

  void _initNetworking() async {
    _networking = PeerToPeerNetworking();
    await _networking.start();
  }

  void tcpSendMessage(Message messageToSend) {
    _networking.addMessageToChatBox(messageToSend);
  }

  void tcpSendTask(dynamic taskToSend) {
    taskToSend is Task ? _networking.addTaskToTaskBox(taskToSend) : _networking.addPollToTaskBox(taskToSend);
  }

  void tcpSendPdf(Pdf pdfToSend) {
    _networking.addPdfToPdfBox(pdfToSend);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(tcpNetworking: _networking),
      ChatPage(onSendMessage: tcpSendMessage),
      TasksPage(onSendTask: tcpSendTask),
      SchedulePage(onSendPdf: tcpSendPdf),
    ];
    if (userTags['Música'] == true) pages.add(MusicPage(onSendPdf: tcpSendPdf));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crisma PSVP"),
        centerTitle: true,
        forceMaterialTransparency: true,
        leading: ThemeColorButton(context: context),
        actions: [ThemeModeButton(), LogoutButton()],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
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
      bottomNavigationBar: NavigationBarWidget(onTabChange: (index) => selectedPageNotifier.value = index),
    );
  }
}
