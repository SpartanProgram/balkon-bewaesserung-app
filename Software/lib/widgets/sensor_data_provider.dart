import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../services/mqtt_service.dart';


class SensorDataProvider extends ChangeNotifier {
  final List<Map<String, String>> _sensorData = List.generate(3, (index) => {
    "sensor": "Sensor ${index + 1}",
    "moisture": "--",
    "waterLevel": "--",
    "lastWatered": "--",
  });

  final MqttService mqtt = MqttService();

  List<Map<String, String>> get sensorData => _sensorData;

  void connectToMqtt({
    required String broker,
    required int port,
    String? username,
    String? password,
    bool useTLS = false,
    void Function()? onConnected,
  }) {
    mqtt.onMessage = updateSensorFromJson;

    mqtt.connect(
      broker: broker,
      port: port,
      username: username,
      password: password,
      useTLS: useTLS,
      onConnected: () {
        mqtt.subscribe('sensor/data');
        if (onConnected != null) onConnected();
      },
    );
  }

  void updateSensorFromJson(String jsonString) {
    try {
      final data = Map<String, dynamic>.from(json.decode(jsonString));
      final int id = data["id"];
      if (id >= 0 && id < _sensorData.length) {
        _sensorData[id] = {
          "sensor": "Sensor ${id + 1}",
          "moisture": "${data["moisture"]}%",
          "waterLevel": "${data["waterLevel"]}%",
          "lastWatered": data["lastWatered"],
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Sensor JSON parse error: $e");
    }
  }
}