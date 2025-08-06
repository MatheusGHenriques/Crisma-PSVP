import 'dart:convert';
import 'dart:io';
import 'network_manager.dart';
import 'peer_connection.dart';
import '/data/user_info.dart';

extension PeerDiscovery on PeerToPeerNetworking {
  Future<void> startUdp() async {
    udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      PeerToPeerNetworking.port,
      reuseAddress: true,
      reusePort: true,
    );
    udpSocket?.broadcastEnabled = true;
    udpSocket?.listen(handleUdpData);
  }

  void handleUdpData(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    Datagram? datagram = udpSocket?.receive();
    if (datagram == null) return;

    Map<String, dynamic> jsonData = json.decode(utf8.decode(datagram.data));
    String remoteName = jsonData['sender'];
    String peerIp = datagram.address.address;

    if (jsonData['type'] != 'discovery_request' || remoteName == userName) {
      return;
    }

    if (connectedPeersIp.contains(peerIp)) {
      return;
    }

    if (userName.compareTo(remoteName) < 0) {
      connectToPeer(peerIp);
    }
  }

  void sendUdpDiscoveryRequest() {
    String jsonString = json.encode({'type': 'discovery_request', 'sender': userName});
    udpSocket?.send(utf8.encode(jsonString), InternetAddress("255.255.255.255"), PeerToPeerNetworking.port);
  }
}
