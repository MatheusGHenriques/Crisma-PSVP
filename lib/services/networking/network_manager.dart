import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cryptography_plus/cryptography_plus.dart';
import '/services/cryptography/ecdh_manager.dart';
import '/services/notifications/notifications.dart';
import '/main.dart';
import '/data/poll.dart';
import '/data/notifiers.dart';
import '/data/message.dart';
import '/data/pdf.dart';
import '/data/task.dart';
import 'peer_connection.dart';
import 'peer_discovery.dart';
import 'data_sync_handler.dart';

class PeerToPeerNetworking {
  static const int port = 64128;
  ServerSocket? serverSocket;
  RawDatagramSocket? udpSocket;

  final Map<Socket, String> socketBuffers = {};
  final Map<Socket, String?> connectedPeers = {};
  final Set<String> connectedPeersIp = {};
  final Set<Socket> syncSentOnSocket = {};
  final Map<Socket, DateTime> lastHeartbeat = {};
  final String heartbeatMessage = json.encode({'type': 'heartbeat'});
  final List<Socket> peersToRemove = [];
  final Map<Socket, EcdhManager> handshakes = {};
  final Map<Socket, SecretKey> aesKeys = {};
  final Map<Socket, List<String>> pendingMessages = {};

  late Set<Message> chatBoxMessages;
  late Set<Poll> taskBoxPolls;
  late Set<Task> taskBoxTasks;
  late Set<Pdf> pdfBoxPdfs;

  late Notifications notifications;

  Future<void> start() async {
    notifications = Notifications();
    notifications.initNotifications();

    chatBoxMessages = chatBox.values.cast<Message>().toSet();
    taskBoxTasks = taskBox.values.whereType<Task>().cast<Task>().toSet();
    taskBoxPolls = taskBox.values.whereType<Poll>().cast<Poll>().toSet();
    pdfBoxPdfs = pdfBox.values.cast<Pdf>().toSet();
    serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
    serverSocket?.listen(handleIncomingConnection);
    await startUdp();
    sendUdpDiscoveryRequest();
    startHeartbeat();
  }

  Future<void> dispose() async {
    await serverSocket?.close();
    serverSocket = null;
    udpSocket?.close();
    udpSocket = null;
    for (Socket peer in connectedPeers.keys) {
      await peer.close();
    }
    connectedPeers.clear();
    socketBuffers.clear();
    syncSentOnSocket.clear();
    connectedPeersNotifier.value = 0;
  }

  void restart() async {
    await dispose();
    await start();
  }

  void sendMessage(Message message) {
    addMessageToChatBox(message);
    writeToPeers("${json.encode({'type': 'message', 'payload': message.toJson()})}\n");
  }

  void sendTask(Task task) {
    addTaskToTaskBox(task);
    writeToPeers("${json.encode({'type': 'task', 'payload': task.toJson()})}\n");
  }

  void sendPoll(Poll poll) {
    addPollToTaskBox(poll);
    writeToPeers("${json.encode({'type': 'poll', 'payload': poll.toJson()})}\n");
  }

  void sendPdf(Pdf pdf) {
    addPdfToPdfBox(pdf);
    writeToPeers("${json.encode({'type': 'pdf', 'payload': pdf.toJson()})}\n");
  }

  void writeToPeers(String jsonString) {
    for (Socket peer in connectedPeers.keys) {
      sendEncrypted(peer, jsonString);
    }
  }
}
