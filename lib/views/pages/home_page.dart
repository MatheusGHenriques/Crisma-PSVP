import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/data/custom_themes.dart';
import '/data/notifiers.dart';
import '/main.dart';
import '/networking/tcp_networking.dart';
import '/views/widgets/home_info_widget.dart';

class HomePage extends StatelessWidget {
  final PeerToPeerTcpNetworking tcpNetworking;

  const HomePage({super.key, required this.tcpNetworking});

  @override
  Widget build(BuildContext context) {
    bool enabledConnectionsButton = true;
    unreadMessagesNotifier.value = homeBox.get("unreadMessages") ?? 0;
    newTasksNotifier.value = homeBox.get("newTasks") ?? 0;
    updatedScheduleNotifier.value = homeBox.get("updatedSchedule") ?? false;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Lottie.asset(CustomThemes.lottie(colorTheme), width: MediaQuery.of(context).size.width / 2),
                  ValueListenableBuilder(
                    valueListenable: isDarkModeNotifier,
                    builder: (context, darkMode, child) {
                      return Image.asset(
                        CustomThemes.image(colorTheme, darkMode),
                        width: MediaQuery.of(context).size.width / 2,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: connectedPeersNotifier,
                        builder: (context, connectedPeers, child) {
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap:
                                connectedPeers > 0
                                    ? () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Wrap(
                                                spacing: 5,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                alignment: WrapAlignment.center,
                                                children: List.generate(tcpNetworking.socketDeviceNames.length, (
                                                  index,
                                                ) {
                                                  return HomeInfoWidget(
                                                    title: tcpNetworking.socketDeviceNames.values.elementAt(index),
                                                    description: "Conectado",
                                                    icon: Icons.check_circle_rounded,
                                                  );
                                                }),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    : enabledConnectionsButton
                                    ? () async {
                                      enabledConnectionsButton = false;
                                      tcpNetworking.restart();
                                      await Future.delayed(Duration(seconds: 5));
                                      enabledConnectionsButton = true;
                                    }
                                    : null,
                            child: HomeInfoWidget(
                              title: "Conexões",
                              description: connectedPeers.toString(),
                              icon: Icons.smartphone_rounded,
                            ),
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: unreadMessagesNotifier,
                        builder: (context, unreadMessages, child) {
                          homeBox.put("unreadMessages", unreadMessages);
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              selectedPageNotifier.value = 1;
                            },
                            child: HomeInfoWidget(
                              title: "Novas Mensagens",
                              description: unreadMessages > 0 ? "+$unreadMessages" : "0",
                              icon: Icons.message_rounded,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: newTasksNotifier,
                        builder: (context, newTasks, child) {
                          homeBox.put("newTasks", newTasks);
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              selectedPageNotifier.value = 2;
                            },
                            child: HomeInfoWidget(
                              title: "Novas Tarefas",
                              description: newTasks > 0 ? "+$newTasks" : "0",
                              icon: Icons.checklist_rtl_rounded,
                            ),
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: updatedScheduleNotifier,
                        builder: (context, updatedSchedule, child) {
                          homeBox.put("updatedSchedule", updatedSchedule);
                          return InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              selectedPageNotifier.value = 3;
                            },
                            child: HomeInfoWidget(
                              title: "Cronograma",
                              description: updatedSchedule ? "Atualizado!" : "Ver",
                              icon: Icons.schedule_rounded,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
