import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '/services/cryptography/aes_manager.dart';
import '/services/cryptography/ecdh_manager.dart';
import 'peer_discovery.dart';
import 'network_manager.dart';
import 'data_sync_handler.dart';
import '/main.dart';
import '/data/poll.dart';
import '/data/notifiers.dart';
import '/data/user_info.dart';
import '/data/message.dart';
import '/data/pdf.dart';
import '/data/task.dart';

extension PeerConnection on PeerToPeerNetworking {
  void startHeartbeat() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      sendUdpDiscoveryRequest();
      for (Socket peer in connectedPeers.keys) {
        sendEncrypted(peer, '$heartbeatMessage\n');
        if (lastHeartbeat[peer] == null ||
            (lastHeartbeat.containsKey(peer) &&
                DateTime.now().difference(lastHeartbeat[peer]!) > Duration(seconds: 90))) {
          removePeer(peer);
        }
      }
    });
  }

  Future<void> initEcdhHandshake(Socket socket) async {
    final ecdh = EcdhManager();
    await ecdh.generateKeyPair();
    final nonce = ecdh.generateNonce();
    final String publicKey = ecdh.getPublicKey();
    handshakes[socket] = ecdh;

    final msg = {'type': 'ECDH_INIT', 'publicKey': publicKey, 'nonce': base64Encode(nonce)};
    socket.write('${json.encode(msg)}\n');
  }

  Future<void> replyEcdhHandshake(Socket socket, Map<String, dynamic> initMsg) async {
    final ecdh = handshakes.remove(socket);
    if (ecdh == null) return;

    final String peerPub = initMsg['publicKey'];
    final nonce = base64Decode(initMsg['nonce'] as String);
    ecdh.nonce = nonce;
    final myPub = ecdh.getPublicKey();
    final reply = {'type': 'ECDH_REPLY', 'publicKey': myPub};
    socket.write('${json.encode(reply)}\n');

    final aesKey = await ecdh.deriveAesKey(peerPub);
    aesKeys[socket] = aesKey;
  }

  Future<void> finishEcdhHandshake(Socket socket, Map<String, dynamic> replyMsg) async {
    final ecdh = handshakes.remove(socket);
    if (ecdh == null) return;

    final String peerPublicKey = replyMsg['publicKey'];
    final aesKey = await ecdh.deriveAesKey(peerPublicKey);
    aesKeys[socket] = aesKey;

    _processPendingMessages(socket);
    sendSyncRequest(socket);
  }

  Future<void> connectToPeer(String ipAddress) async {
    Socket socket = await Socket.connect(ipAddress, PeerToPeerNetworking.port);
    await initEcdhHandshake(socket);
    addPeer(socket, isOutgoing: true);

    socket.listen(
      (data) => handleIncomingData(socket, data),
      onError: (error) {
        removePeer(socket);
      },
      onDone: () {
        removePeer(socket);
      },
    );
  }

  void handleIncomingConnection(Socket socket) {
    addPeer(socket, isOutgoing: false);
    handshakes[socket] = EcdhManager();
    handshakes[socket]?.generateKeyPair();

    socket.listen(
      (data) => handleIncomingData(socket, data),
      onError: (error) {
        removePeer(socket);
      },
      onDone: () {
        removePeer(socket);
      },
    );
  }

  void handleIncomingData(Socket socket, List<int> data) async {
    socketBuffers[socket] = (socketBuffers[socket] ?? "") + utf8.decode(data, allowMalformed: true);
    List<String> dataBuffer = socketBuffers[socket]!.split("\n");
    socketBuffers[socket] = dataBuffer.removeLast();

    for (String data in dataBuffer) {
      if (data.trim().isEmpty) continue;
      bool isJsonMessage = data.trim().startsWith('{');

      if (isJsonMessage) {
        handleHandshake(socket, data);
      } else if (aesKeys.containsKey(socket)) {
        handleAesDecryption(socket, data);
      }
    }
  }

  void handleHandshake(Socket socket, String data) async {
    if (handshakes.containsKey(socket)) {
      final Map<String, dynamic> jsonData = json.decode(data);
      final String type = jsonData['type'];
      if (type == 'ECDH_INIT') {
        await replyEcdhHandshake(socket, jsonData);
      } else if (type == 'ECDH_REPLY') {
        await finishEcdhHandshake(socket, jsonData);
      }
    }
  }

  void handleAesDecryption(Socket socket, String data) async {
    final aesKey = aesKeys[socket]!;
    final Map<String, dynamic> clearMsg = json.decode(await AesManager.decrypt(aesKey, data)) as Map<String, dynamic>;

    final handlers = {
      'heartbeat': () => lastHeartbeat[socket] = DateTime.now(),
      'message': () => addMessageToChatBox(Message.fromJson(clearMsg['payload'])),
      'task': () => addTaskToTaskBox(Task.fromJson(clearMsg['payload'])),
      'poll': () => addPollToTaskBox(Poll.fromJson(clearMsg['payload'])),
      'pdf': () => addPdfToPdfBox(Pdf.fromJson(clearMsg['payload'])),
      'sync': () => handleSync(clearMsg['payload']),
      'sync_request': () => handleSyncRequest(socket, clearMsg),
    };

    if (handlers.containsKey(clearMsg['type'])) {
      handlers[clearMsg['type']]?.call();
    }
  }

  void handleSync(Map<String, dynamic> payload) {
    final typeHandlers = {
      'messages': (json) => Message.fromJson(json),
      'tasks': (json) => Task.fromJson(json),
      'polls': (json) => Poll.fromJson(json),
      'pdf': (json) => Pdf.fromJson(json),
    };

    final addToBox = {
      'messages': (obj) => addMessageToChatBox(obj as Message),
      'tasks': (obj) => addTaskToTaskBox(obj as Task),
      'polls': (obj) => addPollToTaskBox(obj as Poll),
      'pdf': (obj) => addPdfToPdfBox(obj as Pdf),
    };

    for (var key in typeHandlers.keys) {
      for (var jsonItem in payload[key]) {
        var obj = typeHandlers[key]!(jsonItem);
        addToBox[key]!(obj);
      }
    }
  }

  void handleSyncRequest(Socket socket, Map<String, dynamic> jsonData) {
    if (!jsonData.containsKey('sender')) return;
    String remoteName = jsonData['sender'];
    connectedPeers[socket] = remoteName;
    connectedPeersNotifier.value = connectedPeers.length;

    if (syncSentOnSocket.add(socket)) {
      _processPendingMessages(socket);
      sendSyncResponse(socket);
      sendSyncRequest(socket);
    }
  }

  void addPeer(Socket socket, {required bool isOutgoing}) {
    if (!connectedPeers.keys.contains(socket)) {
      connectedPeers[socket] = null;
      lastHeartbeat[socket] = DateTime.now();
      socketBuffers[socket] = '';
      connectedPeersIp.add(socket.remoteAddress.address);
    }
  }

  void removePeer(Socket socket) {
    connectedPeersIp.remove(socket.remoteAddress.address);
    aesKeys.remove(socket);
    pendingMessages.remove(socket);
    socketBuffers.remove(socket);
    connectedPeers.remove(socket);
    syncSentOnSocket.remove(socket);
    connectedPeersNotifier.value = connectedPeers.length;
    socket.close();
  }

  void sendSyncRequest(Socket socket) {
    String jsonString = "${json.encode({'type': 'sync_request', 'sender': userName})}\n";
    sendEncrypted(socket, jsonString);
  }

  void sendSyncResponse(Socket socket) {
    List<Task> tasks = [];
    List<Poll> polls = [];
    for (var item in taskBox.values) {
      if (item is Task) {
        tasks.add(item);
      } else {
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
    sendEncrypted(socket, jsonString);
  }

  void sendEncrypted(Socket socket, String data) async {
    if (aesKeys.containsKey(socket)) {
      String encryptedData = await AesManager.encrypt(aesKeys[socket]!, data);
      socket.write('$encryptedData\n');
    } else {
      if (!pendingMessages.containsKey(socket)) {
        pendingMessages[socket] = [];
      }
      pendingMessages[socket]?.add(data);
    }
  }

  void _processPendingMessages(Socket socket) {
    if (pendingMessages.containsKey(socket)) {
      final queue = pendingMessages.remove(socket)!;
      for (final message in queue) {
        sendEncrypted(socket, message);
      }
    }
  }
}
