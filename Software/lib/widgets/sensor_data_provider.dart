import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mqtt_service.dart';

class SensorDataProvider extends ChangeNotifier {
  final List<Map<String, String>> _sensorData = List.generate(3, (index) => {
    "sensor": "Sensor ${index + 1}",
    "moisture": "--",
    "waterLevel": "--",
    "lastWatered": "--",
  });

  final List<Map<String, dynamic>> _history = [];

  final MqttService mqtt = MqttService();

  List<Map<String, String>> get sensorData => _sensorData;
  List<Map<String, dynamic>> get history => _history;

  // 🔌 Connect to broker
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

  // 🚿 Manual watering command
  Future<void> triggerWatering() async {
    mqtt.publish('esp32/watering', 'start');

    _history.add({
      'timestamp': DateTime.now(),
      'type': 'watering',
      'message': 'Manuelle Bewässerung gestartet',
    });

    await _saveHistoryToPrefs();
    notifyListeners();
  }

  // 🌱 Sensor update from MQTT
  Future<void> updateSensorFromJson(String jsonString) async {
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

        _history.add({
          'timestamp': DateTime.now(),
          'type': 'sensor',
          'sensorId': id,
          'moisture': data["moisture"],
          'waterLevel': data["waterLevel"],
          'lastWatered': data["lastWatered"],
        });

        await _saveHistoryToPrefs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Sensor JSON parse error: $e");
    }
  }

  // 💾 Save to SharedPreferences
  Future<void> _saveHistoryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((entry) {
      return {
        ...entry,
        'timestamp': (entry['timestamp'] as DateTime).toIso8601String(),
      };
    }).toList());
    await prefs.setString('sensor_history', encoded);
  }

  // 🔁 Load from SharedPreferences on app start
  Future<void> loadHistoryFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = prefs.getString('sensor_history');
  if (encoded != null) {
    final List<dynamic> decoded = jsonDecode(encoded);
    _history.clear();
    _history.addAll(decoded.map((entry) {
      final map = Map<String, dynamic>.from(entry);
      return {
        ...map,
        'timestamp': DateTime.parse(map['timestamp']),
      };
    }).toList());
    notifyListeners();
  }
}

}
