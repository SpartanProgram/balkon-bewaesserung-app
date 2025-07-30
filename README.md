# 🌱 Balkon Bewässerung – Mobile App

Dies ist eine Flutter-App zur Überwachung und Steuerung eines automatisierten Bewässerungssystems für den Balkon. Die App kommuniziert über MQTT mit einem ESP32-basierten Microcontroller und unterstützt sowohl manuelle als auch automatische Bewässerung per Zeitplan.

---

## 📱 Funktionen

- Anzeige von Bodenfeuchtigkeit (bis zu 3 Sensoren)
- Anzeige des Wasserstands
- Manuelle Bewässerung einzelner oder aller Sensoren
- Automatische Bewässerung nach Zeitplan
- Verlauf (Verlaufsanzeige von Bewässerungs- und Sensordaten)
- Push-Benachrichtigungen:
  - 🚿 Automatische Bewässerung
  - 🌱 Niedrige Bodenfeuchtigkeit
  - 💧 Niedriger Wasserstand
- Verbindung zu MQTT-Broker mit TLS-Unterstützung
- Speicherung der Einstellungen lokal (Shared Preferences)
- Unterstützung für Android und iOS

---

## 🚀 Installation & Ausführung

### Voraussetzungen
- Flutter SDK installiert
- Ein MQTT-Broker (z. B. HiveMQ, Mosquitto)
- ESP32 mit passender Firmware zur Datenübertragung via MQTT

### App ausführen

```bash
flutter pub get
flutter run
```
## ⚙️ ESP Setup

Beim ersten Einschalten alle sensoren in trockene Erde (0) und auch in feuchte/nass Erde für 20 Sekunde stecken
Wenn Sensoren das Prozent nicht richtig anzeigen >>> bitte Esp Preferences resetten(reset.txt) und dann main nochmal hochladen.

## ⚙️ MQTT Setup

Topic (Empfang): pflanzen/pflanze01

Topic (Senden): pflanzen/pflanze01/control

Payload Beispiel (ESP → App):
```bash
{
  "sensor1": 55,
  "sensor2": 43,
  "sensor3": 87,
  "sensor4": 100
}
```
Payload Beispiel (App → ESP):
```bash
{
  "pump": [true, false, true]
}
```

## 🔐 Berechtigungen

POST_NOTIFICATIONS (Android)

Lokale Benachrichtigungen (iOS & Android)

## 🛠 Verwendete Technologien

Flutter

Provider

flutter_local_notifications

shared_preferences

mqtt_client

## 👥 Team

- Zul Fahmi Nur Vagala (Software)
- Dzaid Abiyyu Siregar (ESP32)
- Johannes Berg (Konstruktion)


## 📝 Lizenz

Dieses Projekt ist Teil des Fachprojekts an der HTW Berlin (SoSe 2025). Die Nutzung ist nur zu Studienzwecken gestattet.