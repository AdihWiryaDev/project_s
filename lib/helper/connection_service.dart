import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Strategy strategy = Strategy.P2P_CLUSTER;
  String? connectedEndpointId;
  Function(Map<String, dynamic>)? onDataReceived;

  // StreamController untuk broadcast payload
  final ValueNotifier<Map<String, dynamic>?> payloadNotifier =
      ValueNotifier(null);

  Future<void> startDiscovery(String userName, String expectedPassword,
      VoidCallback onSuccess, VoidCallback onFail) async {
    await Nearby().startDiscovery(
      userName,
      strategy,
      onEndpointFound: (id, name, serviceId) {
        Nearby().requestConnection(
          userName,
          id,
          onConnectionInitiated: (endpointId, info) {
            Nearby().acceptConnection(
              endpointId,
              onPayLoadRecieved: (endid, payload) {
                final decoded =
                    jsonDecode(String.fromCharCodes(payload.bytes!));
                final operationType = decoded['operationType'];

                if (operationType == 'connection') {
                  final receivedPassword = decoded['password'];
                  if (receivedPassword == expectedPassword) {
                    connectedEndpointId = endid;
                    payloadNotifier.value = decoded;
                    onSuccess();
                  } else {
                    Nearby().disconnectFromEndpoint(endpointId);
                    onFail();
                  }
                } else if (operationType == 'file') {
                  var fileData = decoded['file'];

                  payloadNotifier.value = fileData;
                }
              },
              onPayloadTransferUpdate: (_, __) {},
            );
          },
          onConnectionResult: (id, status) {
            if (status == Status.CONNECTED) {
              final bytes = Uint8List.fromList("Connected".codeUnits);
              Nearby().sendBytesPayload(id, bytes);
              ConnectionService().setConnectedEndpoint(id);
            }
          },
          onDisconnected: (id) {},
        );
      },
      onEndpointLost: (id) {},
    );
  }

  void setConnectedEndpoint(String id) {
    connectedEndpointId = id;
  }

  Future<void> sendToServer(Map<String, dynamic> message) async {
    if (connectedEndpointId == null) {
      return;
    }

    final jsonMessage = jsonEncode(message);
    final bytes = Uint8List.fromList(jsonMessage.codeUnits);

    try {
      await Nearby().sendBytesPayload(connectedEndpointId!, bytes);
    } catch (e) {}
  }

  void stopAll() {
    Nearby().stopAllEndpoints();
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    connectedEndpointId = null;
  }
}
