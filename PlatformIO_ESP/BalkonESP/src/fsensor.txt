#include <Arduino.h>
#include <Preferences.h>

const int moistureSensorPin = 35;  // Pin-Nummer des Feuchtigkeitssensors

Preferences preferences;  // Präferenzenspeicher für Kalibrierungswerte
int airValue;             // Kalibrierungswert für trockene Umgebung
int waterValue;           // Kalibrierungswert für nasse Umgebung
unsigned long startTime;  // Startzeit für die Kalibrierungsphase
const unsigned long calibrationPeriod = 20000;  // Kalibrierungszeit in Millisekunden (20 Sekunden)
const unsigned long sleepTimeSeconds = 20;  // Schlafzeit des Sensors in Sekunden (hier auf 20 Sekunden gesetzt)

void setup() {
  Serial.begin(115200);  // Starten der seriellen Kommunikation
  preferences.begin("moisture", false);  // Öffnen des Präferenzenspeichers für den Feuchtigkeitssensor

  // Laden der gespeicherten Kalibrierungswerte
  airValue = preferences.getInt("airValue", 4095);
  waterValue = preferences.getInt("waterValue", 0);
  bool isCalibrated = preferences.getBool("isCalibrated", false);

  // Start der Kalibrierung, falls noch nicht kalibriert
  if (!isCalibrated) {
    Serial.println("Kalibrierung beginnt - Bitte den Sensor in unterschiedliche Feuchtigkeitszustände bringen.");
    startTime = millis();
  } else {
    Serial.println("Kalibrierung übersprungen.");
  }
}

void loop() {
  bool isCalibrated = preferences.getBool("isCalibrated", false);

  // Durchführung der Sensor-Kalibrierung
  if (!isCalibrated && millis() - startTime < calibrationPeriod) {
    int sensorValue = analogRead(moistureSensorPin);  // Lesen des Sensorwerts
    waterValue = max(waterValue, sensorValue);        // Aktualisieren des Wasserwerts
    airValue = min(airValue, sensorValue);            // Aktualisieren des Luftwerts
    Serial.println("Kalibrierung: Luftwert = " + String(airValue) + ", Wasserwert = " + String(waterValue));
  } else if (millis() - startTime >= calibrationPeriod && !isCalibrated) {
    // Speichern der Kalibrierungswerte
    preferences.putInt("airValue", airValue);
    preferences.putInt("waterValue", waterValue);
    preferences.putBool("isCalibrated", true);
  }

  // Messung und Übermittlung der Bodenfeuchtigkeit, falls kalibriert
  if (isCalibrated) {
    int sensorValue = analogRead(moistureSensorPin);
    int moisturePercent = waterValue == airValue ? 0 : map(sensorValue, airValue, waterValue, 100, 0);
    moisturePercent = constrain(moisturePercent, 0, 100);  // Sicherstellen, dass der Wert zwischen 0 und 100 liegt
    Serial.println("Bodenfeuchtigkeit: " + String(moisturePercent) + "%");
    Serial.println("Raw: "+ String(sensorValue));
    Serial.println("Air: "+ String(airValue));
    Serial.println("Water: "+ String(waterValue));
    delay(1000);  // Kurze Verzögerung, um sicherzustellen, dass die Nachricht gesendet wurde
 }
}