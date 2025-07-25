import 'package:shared_preferences/shared_preferences.dart';

class SensorNameService {
  static const String _prefix = 'sensor_name_';

  /// Save a custom name for a sensor by its index
  static Future<void> saveName(int sensorIndex, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$sensorIndex', name);
  }

  /// Get the saved name for a sensor or fall back to a default name
  static Future<String> getName(int sensorIndex, {String fallback = 'Sensor'}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$sensorIndex') ?? '$fallback ${sensorIndex + 1}';
  }

  /// Optional: clear a name (if needed in future)
  static Future<void> clearName(int sensorIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$sensorIndex');
  }
}
