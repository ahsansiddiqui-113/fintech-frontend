import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class WebSocketController extends GetxController {
  static const platformChannel =
      MethodChannel('net.inexor.sockets/websocket_channel');
  static const platformEvent =
      EventChannel('net.inexor.sockets/websocket_event');

  final RxBool isConnected = false.obs;
  final RxString receivedMessage = ''.obs;

  StreamSubscription? eventSubscription;

  onListenStream(
      {required Function(String message) onDataReceived,
      required VoidCallback onConnectionSuccess}) {
    return platformEvent.receiveBroadcastStream().listen((event) {
      if (event['type'] == "open") {
        onConnectionSuccess();
        log("Connection opened");
      }

      if (event['type'] == "onMessage") {
        onDataReceived(event['message'].toString());
        log("Message received: ${event['message']}");
      }
    });
  }

  Future<void> startWebSocket(
      {required String url,
      String pingMessage = "",
      bool isCustomPingMessage = false,
      bool activatePing = false}) async {
    try {
      await platformChannel.invokeMethod('connect', {
        "url": url,
        "pingMessage": pingMessage,
        "isCustomPingMessage": isCustomPingMessage ? "true" : "false",
        "activatePing": activatePing ? "true" : "false",
      });
    } catch (e) {
      log("Error starting WebSocket: $e");
    }
  }

  Future<bool> isOpen() async {
    try {
      bool status = await platformChannel.invokeMethod('isOpen');
      return status;
    } catch (e) {
      log("Error checking WebSocket status: $e");
      return false;
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      var res = await platformChannel.invokeMethod("message", message);
      log("Message sent: $res");
    } catch (e) {
      log("Error sending message: $e");
    }
  }

  Future<void> disconnectWebSocket() async {
    try {
      var res = await platformChannel.invokeMethod("disconnect");
      log("WebSocket disconnected: $res");
    } catch (e) {
      log("Error disconnecting WebSocket: $e");
    }
  }

  @override
  void onClose() {
    eventSubscription?.cancel();
    super.onClose();
  }
}
