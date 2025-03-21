import 'package:crisma/data/notifiers.dart';
import 'package:crisma/networking/tcp_networking.dart';
import 'package:crisma/views/widgets/home_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  final PeerToPeerTcpNetworking tcpNetworking;

  const HomePage({super.key, required this.tcpNetworking});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Box homeBox = Hive.box("homeBox");

  @override
  void initState() {
    unreadMessagesNotifier.value = homeBox.get("unreadMessages") ?? 0;
    newTasksNotifier.value = homeBox.get("newTasks") ?? 0;
    updatedScheduleNotifier.value = homeBox.get("updatedSchedule") ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
              children: [
                ValueListenableBuilder(
                  valueListenable: isDarkModeNotifier,
                  builder: (context, darkMode, child) {
                    return Image.asset(
                      darkMode ? 'assets/images/compact_dark_logo.png' : 'assets/images/compact_light_logo.png',
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 2,
                    );
                  },
                ),
                SizedBox(height: 20),
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
                                              children: List.generate(widget.tcpNetworking.socketDeviceNames.length, (
                                                index,
                                              ) {
                                                return HomeInfoWidget(
                                                  title: widget.tcpNetworking.socketDeviceNames.values.elementAt(index),
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
        );
      },
    );
  }
}
