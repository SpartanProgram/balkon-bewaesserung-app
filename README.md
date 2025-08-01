# 🌱 Balkon Bewässerung / Balcony Irrigation – Mobile App

*Automatisiertes Pflanzenbewässerungssystem mit Flutter, MQTT & ESP32*  

*A smart IoT plant watering system using Flutter, MQTT & ESP32*

---

## 📱 Funktionen / Features

### ✅ Echtzeitdaten / Live Monitoring  
- 🌿 Feuchtigkeitsanzeige (bis zu 3 Sensoren, einzeln dargestellt)  
- 💧 Anzeige des Wasserstands in % (Sensor 4)  
- 📊 Verlaufsgrafik der letzten 24 Stunden je Pflanze

- 🌿 Real-time moisture display (up to 3 individual sensors)  
- 💧 Water tank level display (Sensor 4)  
- 📊 Historical moisture charts (last 24h per plant)

### ✅ Steuerung / Smart Controls 
- 🚿 Manuelle Bewässerung (einzeln oder alle Pflanzen auf Knopfdruck)  
- ⏰ Zeitplan: automatische Bewässerung zu bestimmter Uhrzeit  
- 🔁 Gießdauer: 1–60 Sekunden einstellbar  
- 🔌 MQTT-Kommunikation mit dem ESP32  
- ✅ Steuerung mehrerer Pumpen

- 🚿 Manual watering (individual or all plants)  
- ⏰ Scheduled automatic watering (customizable time)  
- 🔁 Adjustable watering duration (1–60 seconds)  
- 🔌 MQTT communication with ESP32 microcontroller  
- ✅ Multiple pump control with per-plant logic

### ✅ Benachrichtigungen / Notifications  
- 🛎 Push-Benachrichtigungen bei:
  - ⚠️ Niedriger Feuchtigkeitswert (20%, 10%, 0%)  
  - 💧 Niedriger Wasserstand (< 20%)  
  - 🚱 Kein Wasser mehr (0%)  
  - 🚿 Automatische Bewässerung gestartet  
- 🟢 In-App-Warnungen mit Dialogfenster bei kritischen Zuständen

- 🛎 Push notifications for:
  - ⚠️ Low soil moisture (20%, 10%, 0%)
  - 💧 Low water tank level (< 20%)
  - 🚱 Water tank empty (0%)
  - 🚿 Automatic watering triggered  
- 🟢 In-app alert dialogs when thresholds are reached

### ✅ Speicherfunktionen / Persistence 
- 💾 Speicherung von „Letzte Bewässerung“ (bleibt auch nach App-Neustart erhalten)  
- 🕓 Speichern und Wiederherstellen des Zeitplans  
- 🧠 Verlaufshistorie der Sensorwerte (lokal gespeichert über 24h)  
- ⚙️ Shared Preferences für alle Einstellungen

- 💾 Last watering time per plant (saved across app restarts)  
- 🕓 Schedule is stored and automatically reloaded  
- 🧠 Sensor history (local 24h storage)  
- ⚙️ Uses Shared Preferences for all user settings

---

### Voraussetzungen / Requirements

- ✅ Flutter SDK (3.x)  
- ✅ Ein MQTT-Broker (z. B. Mosquitto, HiveMQ)  
- ✅ ESP32 mit Firmware zur MQTT-Kommunikation  
- 📱 iOS & Android-Unterstützung  

## 🚀 Installation & Ausführen / Getting Started

### 1. Projekt klonen / Clone the project

```bash
git clone https://github.com/your-username/bewaesserung-mobile-app.git
cd bewaesserung-mobile-app
flutter pub get
```

### 2. App starten / Run the app

```bash
flutter run
```

Hinweis: MQTT-Verbindung muss über die App-Einstellungen eingerichtet werden.

## ⚙️  MQTT Kommunikation / MQTT Integration

### 📥 Empfang /  Incoming Data (ESP → App)
Topic: pflanzen/pflanze01

```bash
{
  "sensor1": 55,
  "sensor2": 43,
  "sensor3": 87,
  "sensor4": 18,
  "pump": [false, false, false]
}
```

### 📤 Steuerung / Outgoing Control (App → ESP)
Topic: pflanzen/pflanze01/control

```bash
{
  "pump": [true, false, true],
  "duration": 15000
}
```

pump: Liste mit 3 Booleans für jede Pflanze / List of 3 booleans (one per plant)

duration: Dauer in Millisekunden (z. B. 15000 = 15 Sekunden) / Watering duration in milliseconds (e.g., 15000 = 15 seconds)

## 🧪 ESP Setup

Beim ersten Start: / On first setup:

Stecke die Sensoren kurz in trockene und feuchte Erde (für Kalibrierung)

Falls Feuchtigkeit nicht korrekt erkannt wird:

  Erstelle eine reset.txt auf dem ESP

  Lade die Firmware erneut hoch


Place the moisture sensors briefly in dry and wet soil for calibration

If readings appear inaccurate:

Create a reset.txt file on the ESP

Upload the firmware again to trigger sensor reset

## 🔐 Berechtigungen / Permissions

POST_NOTIFICATIONS (Android)

Lokale Benachrichtigungen (iOS & Android)

## 🛠 Verwendete Technologien / Tech Stack

Flutter

Provider (State Management)

mqtt_client

shared_preferences

flutter_local_notifications

Cupertino Widgets (iOS-Style Picker)

JSON-basiertes Datenmodell

## 👥 Team

👨‍💻 Zul Fahmi Nur Vagala – App-Entwicklung / Mobile App (Flutter)

🔌 Dzaid Abiyyu Siregar – ESP32-Entwicklung / ESP32 Firmware(Firmware)

🛠 Johannes Berg – Mechanik & Hardware / Mechanical Design & Hardware Integration

## 🧠 Projektziel / Project Scope

Dieses Projekt entstand im Rahmen des Fachprojekts (SoSe 2025) an der HTW Berlin und verfolgt das Ziel, ein günstiges, modulares und einfach bedienbares IoT-Bewässerungssystem zu entwickeln, das lokal und sicher arbeitet.

This project was developed as part of a student project (Summer Semester 2025) at HTW Berlin.
It aims to provide a smart, affordable, and locally controlled irrigation system for small balcony gardens.

## 📝 Lizenz / License

Dieses Projekt ist Teil des Fachprojekts an der HTW Berlin.
Nur für Studien- & Forschungszwecke freigegeben.

MIT License (bei öffentlicher Veröffentlichung)


This project is intended for educational and research use only.
Not licensed for commercial distribution.

MIT License (if publicly released)

## 📸 Screenshots 