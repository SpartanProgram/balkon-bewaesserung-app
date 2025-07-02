import 'package:flutter/foundation.dart';
import 'dart:convert';


class SensorDataProvider extends ChangeNotifier {
  final List<Map<String, String>> _sensorData = List.generate(3, (index) => {
    "sensor": "Sensor ${index + 1}",
    "moisture": "--",
    "waterLevel": "--",
    "lastWatered": "--",
  });

  List<Map<String, String>> get sensorData => _sensorData;

  void updateSensorFromJson(String jsonString) {
  debugPrint("👀 Received MQTT payload: $jsonString");

  try {
    final data = Map<String, dynamic>.from(json.decode(jsonString));
    final int id = data["id"];
    final int moisture = data["moisture"];
    final int waterLevel = data["waterLevel"];
    final String lastWatered = data["lastWatered"];

    if (id >= 0 && id < _sensorData.length) {
      debugPrint("✅ Updating sensor $id → Moisture: $moisture%, Water: $waterLevel%, Time: $lastWatered");

      _sensorData[id] = {
        "sensor": "Sensor ${id + 1}",
        "moisture": "$moisture%",
        "waterLevel": "$waterLevel%",
        "lastWatered": lastWatered,
      };

      notifyListeners();
    } else {
      debugPrint("⚠️ Invalid sensor ID: $id");
    }
  } catch (e) {
    debugPrint("❌ MQTT JSON Error: $e");
  }
}

}
