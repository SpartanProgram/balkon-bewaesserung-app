import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/mqtt_service.dart';
import '../services/notification_service.dart';



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

  bool _scheduleActivated = false;
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 8, minute: 0);
  Timer? _scheduleTimer;

  List<Map<String, String>> get sensorData => _sensorData;
  List<Map<String, dynamic>> get history => _history;
  bool get isScheduleActivated => _scheduleActivated;
  TimeOfDay get scheduledTime => _scheduledTime;

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
        onConnected?.call();
        notifyListeners();
      },
    );
  }

  void reconnectIfNeeded() {
    if (!_isConnected) {
      connectToMqtt(broker: 'your_broker_ip_or_hostname', port: 1883);
    }
  }

  Future<void> triggerWatering({int? sensorId, String source = 'manual'}) async {
    debugPrint("🚿 triggerWatering called with source=$source");

    List<bool> pumpStates = List.filled(3, false);

    if (sensorId != null) {
      pumpStates[sensorId] = true;
      _sensorData[sensorId]["lastWatered"] = _formattedNow();

      _history.add({
        'timestamp': DateTime.now(),
        'type': 'watering',
        'sensorId': sensorId,
        'message': source == 'schedule'
            ? 'Zeitplan: Sensor ${sensorId + 1} automatisch bewässert'
            : 'Manuelle Bewässerung Sensor ${sensorId + 1}',
      });
    } else {
      pumpStates = List.filled(3, true);
      for (int i = 0; i < 3; i++) {
        _sensorData[i]["lastWatered"] = _formattedNow();
      }

      _history.add({
        'timestamp': DateTime.now(),
        'type': 'watering',
        'sensorId': -1,
        'message': source == 'schedule'
            ? 'Zeitplan: Alle Pflanzen automatisch bewässert'
            : 'Alle Pflanzen manuell bewässert',
      });
    }
    final prefs = await SharedPreferences.getInstance();
  final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

  if (notificationsEnabled && source == 'schedule') {
    await NotificationService.show(
      title: '🌱 Automatische Bewässerung',
      body: 'Sensoren wurden gemäß Zeitplan bewässert',
    );
  }

    mqtt.publish('pflanzen/pflanze01/control', jsonEncode({"pump": pumpStates}));
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
              final prefs = await SharedPreferences.getInstance();
              final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;

              if (notificationsEnabled) {
                await NotificationService.show(
                  title: '🌱 Niedrige Bodenfeuchtigkeit',
                  body: 'Sensor ${i + 1}: nur $moisture%',
                );
              }
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
          final prefs = await SharedPreferences.getInstance();
          final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;

          if (notificationsEnabled) {
            await NotificationService.show(
              title: '💧 Niedriger Wasserstand',
              body: 'Wasserstand: $waterLevel%',);
          }
        }
      }

      await _saveHistoryToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Sensor JSON parse error: $e");
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

  Future<void> loadScheduleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _scheduleActivated = prefs.getBool('schedule_active') ?? false;
    final hour = prefs.getInt('schedule_hour') ?? 8;
    final minute = prefs.getInt('schedule_minute') ?? 0;
    _scheduledTime = TimeOfDay(hour: hour, minute: minute);
    _startScheduleTimer();
    notifyListeners();
  }

  Future<void> saveScheduleToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('schedule_active', _scheduleActivated);
    await prefs.setInt('schedule_hour', _scheduledTime.hour);
    await prefs.setInt('schedule_minute', _scheduledTime.minute);
  }

  void updateSchedule({required bool isActive, required TimeOfDay time}) {
    _scheduleActivated = isActive;
    _scheduledTime = time;
    saveScheduleToPrefs();
    _startScheduleTimer();
    notifyListeners();
  }

  void _startScheduleTimer() {
    _scheduleTimer?.cancel();

    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = TimeOfDay.now();
      debugPrint("🕐 Checking schedule: ${now.hour}:${now.minute}");

      if (_scheduleActivated &&
          now.hour == _scheduledTime.hour &&
          now.minute == _scheduledTime.minute) {
        debugPrint("🚿 Zeitplan ausgelöst: automatische Bewässerung");
        triggerWatering(source: 'schedule');
      }
    });
  }

  String _formattedNow() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} Uhr";
  }

  @override
  void dispose() {
    _scheduleTimer?.cancel();
    super.dispose();
  }

    void disconnectFromMqtt() {
    mqtt.disconnect(); // Make sure this is implemented in your MqttService
    _isConnected = false;
    notifyListeners();
  }

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = mode;
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }
  
}
