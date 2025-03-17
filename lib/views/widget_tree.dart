import 'package:crisma/views/pages/chat_page.dart';
import 'package:crisma/views/pages/schedule_page.dart';
import 'package:crisma/views/pages/home_page.dart';
import 'package:crisma/views/pages/login_page.dart';
import 'package:crisma/views/pages/to_do_page.dart';
import 'package:crisma/views/widgets/navigation_bar_widget.dart';
import 'package:crisma/views/widgets/theme_mode_button.dart';
import 'package:flutter/material.dart';

import '../data/notifiers.dart';
import '../data/user_info.dart';

List<Widget> pages = [HomePage(), ChatPage(), ToDoPage(), SchedulePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crisma PSVP"),
        centerTitle: true,
        actions: [
          ThemeModeButton(),
          IconButton(onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
              for(String tag in userTags.keys) {
                userTags[tag] = false;
              }
              userName = null;
              return LoginPage();
            },));
          }, icon: Icon(Icons.logout_rounded)),
        ],
      ),
      body: ValueListenableBuilder(
            valueListenable: selectedPageNotifier,
            builder: (context, selectedPage, child) {
              return pages.elementAt(selectedPage);
            },
          ),
      bottomNavigationBar: NavigationBarWidget(),
    );
  }
}
