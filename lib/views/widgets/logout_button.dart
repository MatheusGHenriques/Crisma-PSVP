import 'package:flutter/material.dart';
import '/data/user_info.dart';
import '/views/pages/login_page.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _checkForLogout(BuildContext context){
    showDialog(context: context, builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text('Deseja sair da sua conta?', style: TextStyle(fontSize: 18),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    FilledButton(onPressed: () => _logout(context), child: Text('Sim')),
                    FilledButton(onPressed: () => Navigator.pop(context), child: Text('Não')),
                  ],
                )
              ],
            )
          ),
        ),
      );
    },);
  }

  void _logout(BuildContext context){
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          for (String tag in userTags.keys) {
            userTags[tag] = false;
          }
          userName = "";
          return LoginPage();
        },
      ),(route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _checkForLogout(context);
      },
      icon: const Icon(Icons.logout_rounded),
    );
  }
}
