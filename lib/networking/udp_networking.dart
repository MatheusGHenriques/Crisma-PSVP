import 'dart:convert';
import 'dart:io';

import '../data/message.dart';

class UdpNetworking {
  static const int port = 64128;
  RawDatagramSocket? _socket;
  final String deviceName;
  final Function(Message) onMessageReceived;
  final List<Message> _messageHistory = []; // Stores past messages

  UdpNetworking({required this.deviceName, required this.onMessageReceived});

  Future<void> start() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _socket?.broadcastEnabled = true;
    _socket?.listen(_handleIncomingMessage);

    _sendDiscoveryRequest();
  }

  void _handleIncomingMessage(RawSocketEvent event) {
    Datagram? datagram = _socket?.receive();
    if (datagram == null) return;

    String data = utf8.decode(datagram.data);
    Map<String, dynamic> jsonData = json.decode(data);

    if (jsonData['type'] == 'message') {
      Message message = Message.fromJson(jsonData['payload']);
      _messageHistory.add(message); // Save the message
      onMessageReceived(message);
    } else if (jsonData['type'] == 'discovery_request') {
      _sendAllMessages(datagram.address); // Send all stored messages
    }
  }

  void sendMessage(Message message) {
    _messageHistory.add(message); // Save the message locally
    String jsonString = json.encode({'type': 'message', 'payload': message.toJson()});
    _socket?.send(utf8.encode(jsonString), InternetAddress('255.255.255.255'), port);
  }

  void _sendDiscoveryRequest() {
    String jsonString = json.encode({'type': 'discovery_request'});
    _socket?.send(utf8.encode(jsonString), InternetAddress('255.255.255.255'), port);
  }

  void _sendAllMessages(InternetAddress recipient) {
    for (Message message in _messageHistory) {
      String jsonString = json.encode({'type': 'message', 'payload': message.toJson()});
      _socket?.send(utf8.encode(jsonString), recipient, port);
    }
  }
}