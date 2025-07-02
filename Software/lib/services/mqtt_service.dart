import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient _client;
  bool _isConnected = false;

  void Function(String)? onMessage;

  Future<void> connect({
    required String broker,
    required int port,
    String? username,
    String? password,
    bool useTLS = false,
    void Function()? onConnected,
    void Function()? onDisconnected,
  }) async {
    _client = MqttServerClient(broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
    _client.port = port;
    _client.secure = useTLS;
    _client.useWebSocket = false;
    _client.logging(on: true);
    _client.keepAlivePeriod = 20;

    _client.onDisconnected = () {
      _isConnected = false;
      debugPrint('🔌 MQTT disconnected');
      if (onDisconnected != null) onDisconnected();
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect(
        username?.isNotEmpty == true ? username : null,
        password?.isNotEmpty == true ? password : null,
      );
    } catch (e) {
      _client.disconnect();
      debugPrint("❌ MQTT Connect failed: $e");
      return;
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint("✅ MQTT connected");
      _isConnected = true;
      if (onConnected != null) onConnected();

      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        debugPrint("📨 MQTT message on ${c[0].topic}: $payload");
        onMessage?.call(payload);
      });
    } else {
      debugPrint("❌ Connection failed: ${_client.connectionStatus}");
      _client.disconnect();
    }
  }

  void subscribe(String topic) {
    if (_isConnected) {
      _client.subscribe(topic, MqttQos.atMostOnce);
      debugPrint("📡 Subscribed to $topic");
    }
  }

  void publish(String topic, String message) {
    if (_isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      debugPrint("📤 Published to $topic: $message");
    }
  }

  void disconnect() {
    if (_isConnected) {
      _client.disconnect();
      debugPrint("🔌 Disconnected from broker");
    }
  }

  bool get isConnected => _isConnected;
}
