# 🌿 Smart Balcony Irrigation App / Intelligente Balkonbewässerung

A Flutter-based app to control and monitor an automatic balcony irrigation system  
Eine Flutter-App zur Steuerung und Überwachung einer automatischen Balkonbewässerung

---

## 📱 Features / Funktionen

- 🔧 **MQTT Configuration / MQTT-Konfiguration**
  - Connect to a custom broker with TLS / Verbindung zu einem eigenen Broker mit TLS

- 🌱 **Real-Time Sensor Monitoring / Live-Sensordaten**
  - Moisture sensors for up to 3 plants / Bodenfeuchtigkeit von bis zu 3 Sensoren
  - Water tank level / Wasserstand im Tank

- 📅 **Watering Schedule / Bewässerungszeitplan**
  - Automatic watering at set time / Automatische Bewässerung zur gewünschten Zeit
  - Manual watering per sensor or all / Manuelle Bewässerung einzelner oder aller Pflanzen

- 🔔 **Push Notifications / Push-Benachrichtigungen**
  - Low moisture or water level / Warnungen bei niedriger Feuchtigkeit oder Wasserstand
  - Scheduled watering completed / Erinnerung bei erfolgter Zeitplan-Bewässerung

- 🕘 **History View / Verlauf**
  - Log of all watering events and warnings / Verlauf aller Aktionen und Warnungen

---

## 📦 Installation

```bash
git clone https://gitlab.rz.htw-berlin.de/fachpro-2025/5-balkonbewaesserung.git
cd Software
flutter pub get
flutter run
```

## 🔧 MQTT Setup

MQTT Topic: pflanzen/pflanze01
Expected Payload (Erwartetes Format):

```bash
{
  "sensor1": 80,
  "sensor2": 62,
  "sensor3": 55,
  "sensor4": 92
}
```

sensor1-3: Soil moisture in % / Bodenfeuchtigkeit in %

sensor4: Water tank level / Wasserstand in %

## 🔐 Permissions / Berechtigungen

Make sure to enable notifications manually:
Stelle sicher, dass Benachrichtigungen auf dem Gerät aktiviert sind:
```bash
await Permission.notification.request();
```

## 🧱 Architecture / Architekturüberblick

| Component                     | Description                |
| ----------------------------- | -------------------------- |
| `SensorDataProvider`          | State management & MQTT    |
| `NotificationService`         | Push notifications (local) |
| `ZeitplanScreen`              | Scheduling interface       |
| `VerlaufScreen`               | History/log screen         |
| `EinstellungenScreen`         | MQTT and app settings      |
| `shared_preferences`          | Persistent local storage   |
| `flutter_local_notifications` | Native notifications       |


## 🚫 Known Issues / Bekannte Einschränkungen

Only one MQTT connection per session / Nur eine Verbindung pro Gerät/Sitzung möglich

Sensor data updates all 3 moisture values / Alle Sensorwerte werden gesendet, auch wenn deaktiviert

Limited notification customization / Nur grundlegende Icons/Symbole in Benachrichtigungen

## 💡 Future Work (Sprint 3)

📈 Calibration & sensor status icons

🎨 Better graphics and UI polish

🌍 Multilingual support (EN/DE toggle)

☁️ Optional cloud features (history sync or export)

## 👥 Authors / Entwicklerteam

Team 5

- Zul Fahmi Nur Vagala (Software)
- Dzaid Abiyyu Siregar (ESP32)
- Johannes Berg (Konstruktion)

## Screenshots of the current project / Screenshots des aktuellen Projekts
<img width="800" height="1500" alt="IMG_4496" src="https://github.com/user-attachments/assets/65537d3d-12b1-4951-bfe9-2002cf80b9a1" />
<img width="800" height="1500" alt="IMG_4495" src="https://github.com/user-attachments/assets/f80a1478-ce99-4ed8-b8e8-b998e050fd81" />
<img width="800" height="1500" alt="IMG_4494" src="https://github.com/user-attachments/assets/897d9c51-c877-421e-bd2b-b434b8facd0e" />
<img width="800" height="1500" alt="IMG_4493" src="https://github.com/user-attachments/assets/327d88e4-bdc5-427e-94db-5831c285067d" />
<img width="800" height="1500" alt="IMG_4491" src="https://github.com/user-attachments/assets/0158f4b8-e42f-416c-acdb-42f1cee4a5c7" />
<img width="800" height="1500" alt="IMG_4490" src="https://github.com/user-attachments/assets/873138d0-92ef-42e4-a394-e5602b71f7cf" />

