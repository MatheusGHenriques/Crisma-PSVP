import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/data/notifiers.dart';
import '/data/message.dart' as data;
import '/data/task.dart';
import '/data/poll.dart';
import '/data/pdf.dart';

class Notifications {
  Notifications._();

  static final Notifications _instance = Notifications._();

  factory Notifications() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'crisma_channel',
    'Crisma PSVP Alerts',
    description: 'Notificações de mensagens, tarefas, enquetes, cifras e cronograma',
    importance: Importance.max,
  );

  bool _initialized = false;
  bool _shownSchedule = false;

  Future<void> initNotifications() async {
    if (_initialized) return;
    _initialized = true;

    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final enabled = await androidImpl?.areNotificationsEnabled() ?? false;
      if (!enabled) {
        await androidImpl?.requestNotificationsPermission();
      }
      await androidImpl?.createNotificationChannel(_androidChannel);
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    await _plugin.initialize(InitializationSettings(android: androidInit, iOS: iosInit));

    unreadMessagesNotifier.addListener(() {
      if (unreadMessagesNotifier.value == 0) {
        _plugin.cancel(1);
      }
    });
    newTasksNotifier.addListener(() {
      if (newTasksNotifier.value == 0) {
        _plugin.cancel(2);
      }
    });
    newPollsNotifier.addListener(() {
      if (newPollsNotifier.value == 0) {
        _plugin.cancel(3);
      }
    });
    newCiphersNotifier.addListener(() {
      if (newCiphersNotifier.value == 0) {
        _plugin.cancel(5);
      }
    });
    updatedScheduleNotifier.addListener(_onScheduleChanged);
  }

  void _onScheduleChanged() {
    final nowTrue = updatedScheduleNotifier.value;
    if (nowTrue && !_shownSchedule) {
      _plugin.show(
        4,
        'Cronograma Atualizado!',
        'Toque para ver o novo cronograma',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            priority: Priority.high,
            showWhen: true,
            channelShowBadge: false,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      _shownSchedule = true;
    } else if (!nowTrue && _shownSchedule) {
      _shownSchedule = false;
      _plugin.cancel(4);
    }
  }

  void _notify(ValueNotifier<dynamic> notifier, String plural, String singular, String description, int nId) {
    final count = notifier.value as int;
    if (count > 0) {
      _plugin.show(
        nId,
        count > 1 ? '$count Novas $plural!' : 'Nova $singular!',
        description,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: _androidChannel.importance,
            priority: Priority.high,
            showWhen: true,
            channelShowBadge: true,
            number: count,
          ),
          iOS: DarwinNotificationDetails(badgeNumber: count),
        ),
      );
    } else {
      _plugin.cancel(nId);
    }
  }

  void newNotification(dynamic message) {
    if (message is data.Message) {
      _notify(unreadMessagesNotifier, 'Mensagens', 'Mensagem', '${message.sender}: ${message.text}', 1);
    } else if (message is Task) {
      _notify(newTasksNotifier, 'Tarefas', 'Tarefa', '${message.sender}: ${message.description}', 2);
    } else if (message is Poll) {
      _notify(newPollsNotifier, 'Enquetes', 'Enquete', '${message.sender}: ${message.description}', 3);
    } else if (message is Pdf) {
      _notify(newCiphersNotifier, 'Cifras', 'Cifra', '${message.type}: ${message.title}', 5);
    }
  }
}
