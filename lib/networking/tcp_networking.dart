import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '/main.dart';
import '/data/poll.dart';
import '/data/notifiers.dart';
import '/data/user_info.dart';
import '/views/pages/chat_page.dart';
import '/views/pages/tasks_page.dart';
import '/data/message.dart';
import '/data/pdf.dart';
import '/data/task.dart';

class PeerToPeerTcpNetworking {
  static const int port = 64128;
  ServerSocket? _serverSocket;
  RawDatagramSocket? _udpSocket;

  final List<Socket> _peers = [];
  final Map<Socket, String> _socketBuffers = {};
  final Map<Socket, DateTime> _lastHeartbeat = {};
  final String _heartbeatMessage = json.encode({'type': 'heartbeat'});
  final List<Socket> _peersToRemove = [];

  final Map<Socket, String> socketDeviceNames = {};
  final Map<Socket, bool> _socketIsOutgoing = {};
  final Set<Socket> _syncSentOnSocket = {};

  late Set<Message> _chatBoxMessages;
  late Set<Poll> _taskBoxPolls;
  late Set<Task> _taskBoxTasks;

  Future<void> start() async {
    _chatBoxMessages = chatBox.values.cast<Message>().toSet();
    _taskBoxTasks = taskBox.values.whereType<Task>().cast<Task>().toSet();
    _taskBoxPolls = taskBox.values.whereType<Poll>().cast<Poll>().toSet();
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
    _serverSocket?.listen(_handleIncomingConnection);
    await _startUdp();
    sendUdpDiscoveryRequest();
    _startHeartbeat();
  }

  void _startHeartbeat() {
    Timer.periodic(Duration(seconds: 15), (timer) {
      sendUdpDiscoveryRequest();
      for (Socket peer in _peers) {
        peer.write("$_heartbeatMessage\n");
        if (_lastHeartbeat[peer] == null ||
            (_lastHeartbeat.containsKey(peer) &&
                DateTime.now().difference(_lastHeartbeat[peer]!) > Duration(seconds: 30))) {
          _peersToRemove.add(peer);
        }
      }
      for (Socket peer in _peersToRemove) {
        _removePeer(peer);
      }
      _peersToRemove.clear();
    });
  }

  void dispose() {
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

  Future<void> _startUdp() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port, reuseAddress: true, reusePort: true);
    _udpSocket!.broadcastEnabled = true;
    _udpSocket!.listen(_handleUdpData);
  }

  void _handleUdpData(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    Datagram? datagram = _udpSocket?.receive();
    if (datagram == null) return;
    Map<String, dynamic> jsonData;
    jsonData = json.decode(utf8.decode(datagram.data));
    if (jsonData['type'] == 'discovery_request' && jsonData['sender'] != userName) {
      String peerIp = datagram.address.address;
      bool alreadyConnected = _peers.any((socket) => socket.remoteAddress.address == peerIp);
      if (!alreadyConnected) {
        connectToPeer(peerIp);
      }
    }
  }

  void sendUdpDiscoveryRequest() {
    String jsonString = json.encode({'type': 'discovery_request', 'sender': userName});
    _udpSocket?.send(utf8.encode(jsonString), InternetAddress("255.255.255.255"), port);
  }

  void _sendTcpDiscoveryRequest(Socket socket) {
    String jsonString = "${json.encode({'type': 'discovery_request', 'sender': userName})}\n";
    socket.write(jsonString);
    socket.write("$_heartbeatMessage\n");
  }

  void _sendSyncResponse(Socket socket) {
    List<Task> tasks = [];
    List<Poll> polls = [];
    for (var item in taskBox.values) {
      if (item is Task) {
        tasks.add(item);
      } else if (item is Poll) {
        polls.add(item);
      }
    }
    List<Map<String, dynamic>> messages = chatBox.values.cast<Message>().map((message) => message.toJson()).toList();
    List<Map<String, dynamic>> taskMaps = tasks.map((task) => task.toJson()).toList();
    List<Map<String, dynamic>> pollMaps = polls.map((poll) => poll.toJson()).toList();
    List<Map<String, dynamic>> pdf = pdfBox.values.cast<Pdf>().map((pdf) => pdf.toJson()).toList();

    String jsonString =
        "${json.encode({
          'type': 'sync',
          'payload': {'messages': messages, 'tasks': taskMaps, 'polls': pollMaps, 'pdf': pdf},
          'sender': userName,
        })}\n";
    socket.write("$_heartbeatMessage\n");
    socket.write(jsonString);
  }

  Future<void> connectToPeer(String ipAddress) async {
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
      },
      onDone: () {
        _removePeer(socket);
      },
    );
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
      },
      onDone: () {
        _removePeer(socket);
      },
    );
  }

  void _handleIncomingData(Socket socket, List<int> data) {
    String dataStr = utf8.decode(data);
    _socketBuffers[socket] = (_socketBuffers[socket] ?? "") + dataStr;
    List<String> messages = _socketBuffers[socket]!.split("\n");
    _socketBuffers[socket] = messages.removeLast();

    for (String messageStr in messages) {
      if (messageStr.trim().isEmpty) continue;

      Map<String, dynamic> jsonData = json.decode(messageStr);
      String type = jsonData['type'];

      final handlers = {
        'heartbeat': () => _lastHeartbeat[socket] = DateTime.now(),
        'message': () => _addMessageToChatBox(Message.fromJson(jsonData['payload'])),
        'task': () => _addTaskToTaskBox(Task.fromJson(jsonData['payload'])),
        'poll': () => _addPollToTaskBox(Poll.fromJson(jsonData['payload'])),
        'pdf': () => _addPdfToPdfBox(Pdf.fromJson(jsonData['payload'])),
        'sync': () => _handleSync(jsonData['payload']),
        'discovery_request': () => _handleDiscoveryRequest(socket, jsonData),
      };

      handlers[type]?.call();
    }
  }

  void _handleSync(Map<String, dynamic> payload) {
    final typeHandlers = {
      'messages': (json) => Message.fromJson(json),
      'tasks': (json) => Task.fromJson(json),
      'polls': (json) => Poll.fromJson(json),
      'pdf': (json) => Pdf.fromJson(json),
    };

    final addToBox = {
      'messages': (obj) => _addMessageToChatBox(obj as Message),
      'tasks': (obj) => _addTaskToTaskBox(obj as Task),
      'polls': (obj) => _addPollToTaskBox(obj as Poll),
      'pdf': (obj) => _addPdfToPdfBox(obj as Pdf),
    };

    for (var key in typeHandlers.keys) {
      for (var jsonItem in payload[key]) {
        var obj = typeHandlers[key]!(jsonItem);
        addToBox[key]!(obj);
      }
    }
  }

  void _handleDiscoveryRequest(Socket socket, Map<String, dynamic> jsonData) {
    if (!jsonData.containsKey('sender')) return;

    String remoteName = jsonData['sender'];
    socketDeviceNames[socket] = remoteName;

    for (Socket other in socketDeviceNames.keys) {
      if (other == socket) continue;
      if (socketDeviceNames[other] == remoteName && _shouldRemovePeer(socket, other, remoteName)) {
        _removePeer(socket);
        return;
      }
    }

    if (_syncSentOnSocket.add(socket)) {
      _sendSyncResponse(socket);
    }
  }

  bool _shouldRemovePeer(Socket socket, Socket other, String remoteName) {
    bool thisIsOutgoing = _socketIsOutgoing[socket] ?? false;
    bool otherIsOutgoing = _socketIsOutgoing[other] ?? false;

    if (thisIsOutgoing != otherIsOutgoing) {
      return (userName.compareTo(remoteName) < 0) ? !thisIsOutgoing : thisIsOutgoing;
    }

    return true;
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
    socket.close();
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

  void sendPoll(Poll poll) {
    _addPollToTaskBox(poll);
    String jsonString = "${json.encode({'type': 'poll', 'payload': poll.toJson()})}\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  void sendPdf(Pdf pdf) {
    String jsonString = "${json.encode({'type': 'pdf', 'payload': pdf.toJson()})}\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  void _addMessageToChatBox(Message message) async {
    if (!_chatBoxMessages.contains(message)) {
      _chatBoxMessages.add(message);
      for (Message boxMessage in chatBox.values) {
        if (message.compare(boxMessage) && message.readBy.length > boxMessage.readBy.length) {
          _chatBoxMessages.remove(boxMessage);
          boxMessage.delete();
          break;
        }
      }
      if (ChatPage.userHasMessageTags(message) && message.sender != userName && !message.readBy.contains(userName)) {
        unreadMessagesNotifier.value++;
      }
      await chatBox.add(message);
      await message.save();
      sendMessage(message);
    }
  }

  void _addTaskToTaskBox(Task task) async {
    if (_taskBoxTasks.contains(task)) return;
    _taskBoxTasks.add(task);
    bool addTask = false, comparable = false;
    for (var boxTask in taskBox.values) {
      if (boxTask is Task) {
        if (task.compare(boxTask)) {
          comparable = true;
          if (task.numberOfPersons < boxTask.numberOfPersons ||
              (task.persons != boxTask.persons && task.persons.isNotEmpty && boxTask.persons.isNotEmpty)) {
            addTask = true;
            await boxTask.delete();
          }
          break;
        }
      }
    }

    if (addTask || !comparable) {
      if (TasksPage.userHasTaskTags(task) && task.numberOfPersons > 0) {
        newTasksNotifier.value++;
      }
      await taskBox.add(task);
      await task.save();
      sendTask(task);
    }
  }

  bool _noTagsInPoll(Poll poll) {
    for (bool tag in poll.tags.values) {
      if (tag) {
        return false;
      }
    }
    return true;
  }

  void _addPollToTaskBox(Poll poll) async {
    if (_taskBoxPolls.contains(poll)) return;
    _taskBoxPolls.add(poll);
    bool addPoll = false, comparable = false;
    for (var boxPoll in taskBox.values) {
      if (boxPoll is Poll) {
        if (poll.compare(boxPoll)) {
          comparable = true;
          if (poll.votes.keys.length > boxPoll.votes.keys.length || _noTagsInPoll(poll)) {
            addPoll = true;
            await boxPoll.delete();
          } else if (poll.votes.keys.length == boxPoll.votes.keys.length) {
            int totalPollValues = 0, totalBoxPollValues = 0;
            for (String key in poll.votes.keys) {
              List<String> pollValues = poll.votes[key] ?? [];
              totalPollValues += pollValues.length;
              List<String> boxPollValues = boxPoll.votes[key] ?? [];
              totalBoxPollValues += boxPollValues.length;
            }
            if (totalPollValues > totalBoxPollValues) {
              addPoll = true;
            }
          }
        }
      }
    }
    if (addPoll || !comparable) {
      await taskBox.add(poll);
      await poll.save();
      sendPoll(poll);
      if (TasksPage.userHasPollTags(poll) &&
          !poll.votes.values.any((element) {
            for (String voted in element) {
              if (userName == voted) return true;
            }
            return false;
          })) {
        newTasksNotifier.value++;
      }
    }
  }

  void _addPdfToPdfBox(Pdf pdf) async {
    if (pdfBox.isEmpty || await pdfBox.get("pdf").time.isBefore(pdf.time)) {
      await pdfBox.put("pdf", pdf);
      updatedScheduleNotifier.value = true;
      sendPdf(pdf);
    }
  }
}
