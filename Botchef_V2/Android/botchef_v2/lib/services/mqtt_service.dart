import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef MQTTMessageCallback = void Function(
  String topic,
  String message,
);

class MQTTService {
  MQTTService._();

  static final MQTTService instance = MQTTService._();

  final MqttServerClient client = MqttServerClient.withPort(
    '6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud',
    '',
    8883,
  );

  StreamSubscription? _subscription;

  bool _initialized = false;

  Future<void> mqttInit() async {
    if (_initialized) return;

    client.logging(on: true);

    client.autoReconnect = true;
    client.keepAlivePeriod = 300;

    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.onAutoReconnect = onReconnect;
    client.pongCallback = pong;

    final ByteData caCert = await rootBundle.load('assets/certs/ca.pem');

    final context = SecurityContext()
      ..setTrustedCertificatesBytes(
        caCert.buffer.asUint8List(),
      );

    client.secure = true;
    client.securityContext = context;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('android')
        .withWillTopic('willtopic')
        .withWillMessage('Will Message')
        .startClean();

    client.connectionMessage = connMessage;

    _initialized = true;
  }

  Future<void> connect({
    required String username,
    required String password,
  }) async {
    if (!_initialized) {
      await mqttInit();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    await client.connect(username, password);
  }

  void subscribe(
    String topic,
    MQTTMessageCallback onMessage,
  ) {
    client.subscribe(topic, MqttQos.atLeastOnce);

    _subscription?.cancel();

    _subscription = client.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;

        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        debugPrint(
          'Topic: ${c[0].topic}, Payload: $payload',
        );

        onMessage(c[0].topic, payload);
      },
    );
  }

  void unsubscribe(String topic) {
    client.unsubscribe(topic);
    _subscription?.cancel();
  }

  void disconnect() {
    _subscription?.cancel();
    client.disconnect();
  }

  void sendData(
    String message,
    String topic,
    bool retain,
  ) {
    final builder = MqttClientPayloadBuilder();

    builder.addString(message);

    client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: retain,
    );
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void onConnected() {
    debugPrint('Connected');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed to $topic');
  }

  void onReconnect() {
    client.port = 8883;
  }

  void pong() {
    debugPrint('Ping response received');
  }
}

