#include <Arduino.h>
#include <Preferences.h>

Preferences preferences;

void setup() {
  Serial.begin(115200);
  
  // Initialisierung des Preferences-Speichers
  preferences.begin("moisture", false);

  // Überprüfen, ob die Kalibrierungsdaten bereits gelöscht wurden
  bool isCleared = preferences.getBool("isCleared", false);

  if (!isCleared) {
    // Löschen des Speicherbereichs, wenn er noch nicht gelöscht wurde
    Serial.println("Lösche Kalibrierungsdaten...");
    preferences.clear();

    // Setzen der Flagge, dass die Daten gelöscht wurden
    preferences.putBool("isCleared", true);

    // Bestätigung der Löschung
    Serial.println("Kalibrierungsdaten wurden zurückgesetzt.");
  } else {
    Serial.println("Kalibrierungsdaten wurden bereits gelöscht.");
  }

  // Schließen der Preferences
  preferences.end();

  // Warten, um die Ausgabe im seriellen Monitor zu sehen
  delay(2000);

  // Neustart oder weiteren Code ausführen
  Serial.println("System wird neu gestartet.");
  ESP.restart();
}

void loop() {
  // Der Loop-Block bleibt leer, da alle Aktionen im Setup-Block durchgeführt werden.
}