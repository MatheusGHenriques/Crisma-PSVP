import 'dart:convert';
import 'dart:io';
import 'package:crisma/data/notifiers.dart';
import 'package:crisma/data/user_info.dart';
import 'package:crisma/views/pages/chat_page.dart';
import 'package:crisma/views/pages/tasks_page.dart';
import 'package:hive_ce/hive.dart';
import '../data/message.dart';
import '../data/pdf.dart';
import '../data/task.dart';

class PeerToPeerTcpNetworking {
  static const int port = 64128;
  ServerSocket? _serverSocket;
  RawDatagramSocket? _udpSocket;
  final String deviceName = userName;
  final Box chatBox = Hive.box("chatBox");
  final Box taskBox = Hive.box("taskBox");
  final Box pdfBox = Hive.box("pdfBox");

  final List<Socket> _peers = [];
  final Map<Socket, String> _socketBuffers = {};

  final Map<Socket, String> socketDeviceNames = {};
  final Map<Socket, bool> _socketIsOutgoing = {};
  final Set<Socket> _syncSentOnSocket = {};

  late Set<Message> _chatBoxMessages;

  Future<void> start() async {
    _chatBoxMessages = chatBox.values.cast<Message>().toSet();
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
    _serverSocket?.listen(_handleIncomingConnection);
    await _startUdpDiscovery();
    sendUdpDiscoveryRequest();
  }

  void dispose(){
    _serverSocket?.close();
    _serverSocket = null;
    _udpSocket?.close();
    _udpSocket = null;
    for (Socket peer in _peers) {
      peer.close();
    }
    _peers.clear();
    _socketBuffers.clear();
    socketDeviceNames.clear();
    _socketIsOutgoing.clear();
    _syncSentOnSocket.clear();
    connectedPeersNotifier.value = 0;
  }

  Future<void> _startUdpDiscovery() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port, reuseAddress: true, reusePort: true);
    _udpSocket!.broadcastEnabled = true;
    _udpSocket!.listen(_handleUdpData);
  }

  void _handleUdpData(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = _udpSocket?.receive();
      if (datagram == null) return;
      String dataStr = utf8.decode(datagram.data);
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(dataStr);
      } catch (e) {
        return;
      }

      if (jsonData['type'] == 'discovery_request') {
        _sendUdpDiscoveryResponse(datagram.address);
      } else if (jsonData['type'] == 'discovery_response') {
        if (jsonData['sender'] != deviceName) {
          String peerIp = datagram.address.address;
          bool alreadyConnected = _peers.any((socket) => socket.remoteAddress.address == peerIp);
          if (!alreadyConnected) {

            connectToPeer(peerIp);
          }
        }
      }
    }
  }

  void _sendUdpDiscoveryResponse(InternetAddress recipient) {
    String jsonString = json.encode({'type': 'discovery_response', 'sender': deviceName});
    _udpSocket?.send(utf8.encode(jsonString), recipient, port);
  }

  void sendUdpDiscoveryRequest() {
    String jsonString = json.encode({'type': 'discovery_request'});
    _udpSocket?.send(utf8.encode(jsonString), InternetAddress("255.255.255.255"), port);
  }

  void _sendTcpDiscoveryRequest(Socket socket) {
    String jsonString = "${json.encode({'type': 'discovery_request', 'sender': deviceName})}\n";
    socket.write(jsonString);
  }

  void _sendSyncResponse(Socket socket) {
    List<Map<String, dynamic>> messages = chatBox.values
        .cast<Message>()
        .map((message) => message.toJson())
        .toList();

    List<Map<String, dynamic>> tasks = taskBox.values
        .cast<Task>()
        .map((task) => task.toJson())
        .toList();

    String jsonString = "${json.encode({
      'type': 'sync',
      'payload': {'messages': messages, 'tasks': tasks},
      'sender': deviceName
    })}\n";

    socket.write(jsonString);
  }

  Future<void> connectToPeer(String ipAddress) async {
    try {
      Socket socket = await Socket.connect(ipAddress, port);
      _addPeer(socket, isOutgoing: true);
      _socketBuffers[socket] = '';

      Future.delayed(const Duration(milliseconds: 100), () {
        _sendTcpDiscoveryRequest(socket);
      });

      socket.listen(
            (data) => _handleIncomingData(socket, data),
        onError: (error) {
          _removePeer(socket);
          socket.close();
        },
        onDone: () {
          _removePeer(socket);
          socket.close();
        },
      );
    } catch (e) {
      return;
    }
  }

  void _handleIncomingConnection(Socket socket) {
    _addPeer(socket, isOutgoing: false);
    _socketBuffers[socket] = '';

    Future.delayed(const Duration(milliseconds: 100), () {
      _sendTcpDiscoveryRequest(socket);
    });

    socket.listen(
          (data) => _handleIncomingData(socket, data),
      onError: (error) {
        _removePeer(socket);
        socket.close();
      },
      onDone: () {
        _removePeer(socket);
        socket.close();
      },
    );
  }

  void _handleIncomingData(Socket socket, List<int> data) {
    String dataStr = utf8.decode(data);
    _socketBuffers[socket] = _socketBuffers[socket]! + dataStr;
    List<String> messages = _socketBuffers[socket]!.split("\n");
    _socketBuffers[socket] = messages.removeLast();

    for (String messageStr in messages) {
      if (messageStr.trim().isEmpty) continue;
      try {
        Map<String, dynamic> jsonData = json.decode(messageStr);
        String type = jsonData['type'];
        if (type == 'message') {
          Message message = Message.fromJson(jsonData['payload']);
          if (message.sender == deviceName) continue;
          _addMessageToChatBox(message);
        } else if (type == 'task') {
          Task task = Task.fromJson(jsonData['payload']);
          _addTaskToTaskBox(task);
        } else if(type == 'pdf'){
          Pdf pdf = Pdf.fromJson(jsonData['payload']);
          _addPdfToPdfBox(pdf);
        } else if (type == 'sync') {
          Map<String, dynamic> payload = jsonData['payload'];
          if (payload.containsKey('messages')) {
            for (var messageJson in payload['messages']) {
              Message message = Message.fromJson(messageJson);
              if (message.sender != deviceName) {
                _addMessageToChatBox(message);
              }
            }
          }
          if (payload.containsKey('tasks')) {
            for (var taskJson in payload['tasks']) {
              Task task = Task.fromJson(taskJson);
              _addTaskToTaskBox(task);
            }
          }
          if(payload.containsKey('pdf')){
            Pdf pdf = Pdf.fromJson(payload['pdf']);
            _addPdfToPdfBox(pdf);
          }
        } else if (type == 'discovery_request') {
          if (jsonData.containsKey('sender')) {
            String remoteName = jsonData['sender'];
            socketDeviceNames[socket] = remoteName;
            for (Socket other in socketDeviceNames.keys) {
              if (other == socket) continue;
              if (socketDeviceNames[other] == remoteName) {
                bool thisIsOutgoing = _socketIsOutgoing[socket] ?? false;
                bool otherIsOutgoing = _socketIsOutgoing[other] ?? false;
                if (thisIsOutgoing != otherIsOutgoing) {
                  if (deviceName.compareTo(remoteName) < 0) {
                    if (!thisIsOutgoing) {
                      socket.close();
                      _removePeer(socket);
                      return;
                    }
                  } else {
                    if (thisIsOutgoing) {
                      socket.close();
                      _removePeer(socket);
                      return;
                    }
                  }
                } else {
                  socket.close();
                  _removePeer(socket);
                  return;
                }
              }
            }
          }
          if (!_syncSentOnSocket.contains(socket)) {
            _syncSentOnSocket.add(socket);
            _sendSyncResponse(socket);
          }
        }
      } catch (e) {
        return;
      }
    }
  }

  void _addPeer(Socket socket, {required bool isOutgoing}) {
    if (!_peers.contains(socket)) {
      _peers.add(socket);
      _socketIsOutgoing[socket] = isOutgoing;
    }
    connectedPeersNotifier.value = _peers.length;
  }

  void _removePeer(Socket socket) {
    _peers.remove(socket);
    _socketBuffers.remove(socket);
    socketDeviceNames.remove(socket);
    _socketIsOutgoing.remove(socket);
    _syncSentOnSocket.remove(socket);

    connectedPeersNotifier.value = _peers.length;
  }

  void sendMessage(Message message) {
    _addMessageToChatBox(message);
    String jsonString = "${json.encode({'type': 'message', 'payload': message.toJson()})}\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  void sendTask(Task task) {
    _addTaskToTaskBox(task);
    String jsonString = "${json.encode({'type': 'task', 'payload': task.toJson()})}\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  void sendPdf(Pdf pdf){
    String jsonString = "${json.encode({'type': 'pdf', 'payload': pdf.toJson()})}\n";
    for(Socket peer in _peers){
      peer.write(jsonString);
    }
  }

  void sendDiscoveryRequest() {
    String jsonString = "${json.encode({'type': 'discovery_request', 'sender': deviceName})}\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  void _addMessageToChatBox(Message message) async {
    if (!_chatBoxMessages.contains(message)) {
      if(ChatPage.userHasMessageTags(message) && message.sender != userName){
        unreadMessagesNotifier.value++;
      }
      _chatBoxMessages.add(message);
      await chatBox.add(message);
    }
  }

  void _addTaskToTaskBox(Task task) async {
    bool containsTask = false, addTask = false;
    for (Task boxTask in taskBox.values) {
      if(task == boxTask){
        containsTask = true;
        if(task.numberOfPersons < boxTask.numberOfPersons || task.persons != boxTask.persons){
          addTask = true;
          await boxTask.delete();
        }
        break;
      }
    }

    if (addTask || !containsTask) {
      if(TasksPage.userHasTaskTags(task) && task.numberOfPersons > 0){
        newTasksNotifier.value++;
      }
      await taskBox.add(task);
      await task.save();
    }
  }

  void _addPdfToPdfBox(Pdf pdf) async {
    if(pdfBox.isEmpty || await pdfBox.get("pdf").time.isBefore(pdf.time)){
      await pdfBox.put("pdf", pdf);
      updatedScheduleNotifier.value = true;
    }
  }
}