import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
      
  bool _hasInitializedWaterLevel = false;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    final ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(settings);
    print("🔧 Local notifications initialized");

  }

 static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> show({
    required String title,
    required String body,
    bool playWarningSound = false,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'watering_channel',
      'Bewässerung Benachrichtigungen',
      channelDescription: 'Benachrichtigungen für Pflanzenbewässerung',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(0, title, body, details);
    print("🔔 Local notification shown: $title - $body");

    if (playWarningSound) {
      try {
        print("🔊 Playing warning sound...");
        await _audioPlayer.stop(); // Stop any existing sound
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play(AssetSource('sounds/warning.mp3'));
      } catch (e) {
        print("❌ Failed to play warning sound: $e");
      }
    }
  }
}
