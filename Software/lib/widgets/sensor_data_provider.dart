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

  bool _isConnected = false;
  bool get isConnected => _isConnected;


  List<Map<String, String>> get sensorData => _sensorData;
  List<Map<String, dynamic>> get history => _history;

  void connectToMqtt({
    required String broker,
    required int port,
    String? username,
    String? password,
    bool useTLS = true,
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
        _isConnected = true;
        mqtt.subscribe('pflanzen/pflanze01');
        if (onConnected != null) onConnected();
      },
    );
  }

  /// Reconnect if disconnected
  void reconnectIfNeeded() {
    if (!_isConnected) {
      connectToMqtt(
        broker: 'your_broker_ip_or_hostname',
        port: 1883,
        // username/password if needed
      );
    }
  }

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

  Future<void> updateSensorFromJson(String jsonString) async {
    debugPrint("📥 Received MQTT: $jsonString");

    try {
      final data = Map<String, dynamic>.from(json.decode(jsonString));

      for (int i = 0; i < 3; i++) {
        final key = "sensor${i + 1}";
        if (data.containsKey(key)) {
          final moisture = data[key];
          if (moisture is int || moisture is double) {
            _sensorData[i]["moisture"] = "$moisture%";

            if (moisture <= 20) {
              _history.add({
                'timestamp': DateTime.now(),
                'type': 'sensor',
                'sensorId': i,
                'event': 'Sensor ${i + 1}: $moisture% Feuchtigkeit',
              });
            }
          }
        }
      }

      if (data.containsKey("sensor4")) {
        final waterLevel = data["sensor4"];
        final waterLevelStr = "$waterLevel%";

        for (int i = 0; i < _sensorData.length; i++) {
          _sensorData[i]["waterLevel"] = waterLevelStr;
        }

        if (waterLevel <= 20) {
          _history.add({
            'timestamp': DateTime.now(),
            'type': 'sensor',
            'sensorId': -1,
            'event': 'Wasserstand niedrig: $waterLevel%',
          });
        }
      }

      await _saveHistoryToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Sensor JSON parse error: $e");
    }
  }

      // Save broker credentials
      Future<void> saveBrokerCredentials({
        required String broker,
        required int port,
        String? username,
        String? password,
      }) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mqtt_broker', broker);
        await prefs.setInt('mqtt_port', port);
        if (username != null) await prefs.setString('mqtt_user', username);
        if (password != null) await prefs.setString('mqtt_pass', password);
      }

      // Load broker credentials
      Future<void> loadAndConnectFromPrefs() async {
        final prefs = await SharedPreferences.getInstance();
        final broker = prefs.getString('mqtt_broker');
        final port = prefs.getInt('mqtt_port');
        final username = prefs.getString('mqtt_user');
        final password = prefs.getString('mqtt_pass');

        if (broker != null && port != null) {
          connectToMqtt(
            broker: broker,
            port: port,
            username: username,
            password: password,
          );
        }
      }

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