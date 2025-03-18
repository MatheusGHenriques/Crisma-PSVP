import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:crisma/data/notifiers.dart';
import 'package:crisma/data/user_info.dart';
import 'package:hive_ce/hive.dart';
import '../data/message.dart';

class PeerToPeerTcpNetworking {
  static const int port = 64128;
  ServerSocket? _serverSocket;
  RawDatagramSocket? _udpSocket;
  final String deviceName = userName;
  final Box chatBox = Hive.box("chatBox");
  final Box hashMessageBox = Hive.box("hashMessageBox");

  final List<Socket> _peers = [];
  final Map<Socket, String> _socketBuffers = {};

  // Track remote device names and connection type (outgoing/incoming)
  final Map<Socket, String> _socketDeviceNames = {};
  final Map<Socket, bool> _socketIsOutgoing = {};
  // Ensure we send a sync response only once per discovery on a given socket.
  final Set<Socket> _syncSentOnSocket = {};

  // In-memory set for deduplication.
  final Set<String> _inMemoryMessageHashes = {};

  Future<void> start() async {
    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket?.listen(_handleIncomingConnection);
    await _startUdpDiscovery();
    sendUdpDiscoveryRequest();
  }

  Future<void> _startUdpDiscovery() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
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
        log('Error decoding UDP message: $e');
        return;
      }

      if (jsonData['type'] == 'discovery_request') {
        _sendUdpDiscoveryResponse(datagram.address);
      } else if (jsonData['type'] == 'discovery_response') {
        if (jsonData['sender'] != deviceName) {
          String peerIp = datagram.address.address;
          bool alreadyConnected = _peers.any(
                (socket) => socket.remoteAddress.address == peerIp,
          );
          if (!alreadyConnected) {
            connectToPeer(peerIp);
          }
        }
      }
    }
  }

  void _sendUdpDiscoveryResponse(InternetAddress recipient) {
    String jsonString = json.encode({
      'type': 'discovery_response',
      'sender': deviceName,
    });
    _udpSocket?.send(utf8.encode(jsonString), recipient, port);
  }

  void sendUdpDiscoveryRequest() {
    String jsonString = json.encode({'type': 'discovery_request'});
    _udpSocket?.send(utf8.encode(jsonString), InternetAddress("255.255.255.255"), port);
  }

  /// Sends a TCP discovery request that includes the sender's name.
  void _sendTcpDiscoveryRequest(Socket socket) {
    String jsonString = json.encode({
      'type': 'discovery_request',
      'sender': deviceName,
    }) + "\n";
    socket.write(jsonString);
  }

  /// Instead of sending individual messages, send a "sync" message with all messages.
  void _sendSyncResponse(Socket socket) {
    List<Map<String, dynamic>> messages = chatBox.values
        .cast<Message>()
        .map((message) => message.toJson())
        .toList();

    String jsonString = json.encode({
      'type': 'sync',
      'payload': messages,
      'sender': deviceName,
    }) + "\n";
    socket.write(jsonString);
  }

  Future<void> connectToPeer(String ipAddress) async {
    try {
      Socket socket = await Socket.connect(ipAddress, port);
      _addPeer(socket, isOutgoing: true);
      _socketBuffers[socket] = '';

      // After connecting, send a TCP discovery request so the remote device sends a sync response.
      Future.delayed(const Duration(milliseconds: 100), () {
        _sendTcpDiscoveryRequest(socket);
      });

      socket.listen(
            (data) => _handleIncomingData(socket, data),
        onError: (error) {
          log('Error on socket from $ipAddress: $error');
          _removePeer(socket);
          socket.close();
        },
        onDone: () {
          _removePeer(socket);
          socket.close();
        },
      );
    } catch (e) {
      log('Failed to connect to peer $ipAddress: $e');
    }
  }

  void _handleIncomingConnection(Socket socket) {
    _addPeer(socket, isOutgoing: false);
    _socketBuffers[socket] = '';

    // For incoming connections, also trigger a TCP discovery request after a short delay.
    Future.delayed(const Duration(milliseconds: 100), () {
      _sendTcpDiscoveryRequest(socket);
    });

    socket.listen(
          (data) => _handleIncomingData(socket, data),
      onError: (error) {
        log('Error on incoming TCP socket: $error');
        _removePeer(socket);
        socket.close();
      },
      onDone: () {
        log('TCP peer disconnected: ${socket.remoteAddress.address}');
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
        } else if (type == 'sync') {
          // A sync payload containing a list of messages.
          List<dynamic> payload = jsonData['payload'];
          for (var messageJson in payload) {
            Message message = Message.fromJson(messageJson);
            if (message.sender != deviceName) {
              _addMessageToChatBox(message);
            }
          }
        } else if (type == 'discovery_request') {
          // Record the remote device name for connection arbitration.
          if (jsonData.containsKey('sender')) {
            String remoteName = jsonData['sender'];
            _socketDeviceNames[socket] = remoteName;
            // Connection arbitration logic (if duplicate exists, decide which one to keep).
            for (Socket other in _socketDeviceNames.keys) {
              if (other == socket) continue;
              if (_socketDeviceNames[other] == remoteName) {
                bool thisIsOutgoing = _socketIsOutgoing[socket] ?? false;
                bool otherIsOutgoing = _socketIsOutgoing[other] ?? false;
                if (thisIsOutgoing != otherIsOutgoing) {
                  if (deviceName.compareTo(remoteName) < 0) {
                    if (!thisIsOutgoing) {
                      log('Arbitration: closing duplicate incoming connection from $remoteName');
                      socket.close();
                      _removePeer(socket);
                      return;
                    }
                  } else {
                    if (thisIsOutgoing) {
                      log('Arbitration: closing duplicate outgoing connection to $remoteName');
                      socket.close();
                      _removePeer(socket);
                      return;
                    }
                  }
                } else {
                  log('Arbitration: duplicate connection with same type for $remoteName; closing later connection');
                  socket.close();
                  _removePeer(socket);
                  return;
                }
              }
            }
          }
          // When a discovery request arrives, send a sync response if not already sent on this socket.
          if (!_syncSentOnSocket.contains(socket)) {
            _syncSentOnSocket.add(socket);
            _sendSyncResponse(socket);
          }
        }
      } catch (e) {
        log('Error decoding message: $e');
      }
    }
  }

  void _addPeer(Socket socket, {required bool isOutgoing}) {
    if (!_peers.contains(socket)) {
      _peers.add(socket);
      _socketIsOutgoing[socket] = isOutgoing;
    }
    if (_peers.isNotEmpty) {
      hasConnectedPeerNotifier.value = true;
    }
  }

  void _removePeer(Socket socket) {
    _peers.remove(socket);
    _socketBuffers.remove(socket);
    _socketDeviceNames.remove(socket);
    _socketIsOutgoing.remove(socket);
    _syncSentOnSocket.remove(socket);
    if (_peers.isEmpty) {
      hasConnectedPeerNotifier.value = false;
    }
  }

  /// Sends a new message and propagates it to all connected peers.
  void sendMessage(Message message) {
    _addMessageToChatBox(message);
    String jsonString = json.encode({
      'type': 'message',
      'payload': message.toJson(),
    }) + "\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  /// Allows a device to actively trigger a discovery request over all TCP connections.
  void sendDiscoveryRequest() {
    String jsonString = json.encode({
      'type': 'discovery_request',
      'sender': deviceName,
    }) + "\n";
    for (Socket peer in _peers) {
      peer.write(jsonString);
    }
  }

  void _addMessageToChatBox(Message message) {
    String messageHash = _generateMessageHash(message);
    // Check for duplicates in persistent storage and in-memory.
    if (hashMessageBox.values.contains(messageHash) ||
        _inMemoryMessageHashes.contains(messageHash)) return;

    hashMessageBox.add(messageHash);
    chatBox.add(message);
    _inMemoryMessageHashes.add(messageHash);
    _cleanupDuplicateMessages();
  }

  void _cleanupDuplicateMessages() {
    Set<String> seenHashes = {};
    List<dynamic> duplicateKeys = [];

    for (var key in chatBox.keys) {
      Message message = chatBox.get(key);
      String hash = _generateMessageHash(message);
      if (seenHashes.contains(hash)) {
        duplicateKeys.add(key);
      } else {
        seenHashes.add(hash);
      }
    }

    for (var key in duplicateKeys) {
      chatBox.delete(key);
    }
    _inMemoryMessageHashes.clear();
    for (var key in chatBox.keys) {
      Message message = chatBox.get(key);
      _inMemoryMessageHashes.add(_generateMessageHash(message));
    }
  }

  String _generateMessageHash(Message message) {
    var sortedTags = message.tags.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    String tagsString = sortedTags
        .map((e) => '${e.key}:${e.value.toString()}')
        .join(',');
    return '${message.text}-${message.sender}-$tagsString-${message.time.toIso8601String()}';
  }
}