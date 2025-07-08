#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <Preferences.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "Pixel 6";
const char* password = "namasaya";

// MQTT broker info (HiveMQ Cloud)
const char* mqttServer = "cd5a01681d434871ab7952c6e6b0252d.s1.eu.hivemq.cloud";
const int mqttPort = 8883;
const char* mqttUser = "dzaid";
const char* mqttPassword = "Ffsnoway1!";
const char* mqttPubTopic = "pflanzen/pflanze01";
const char* mqttSubTopic = "pflanzen/pflanze01/control";

// TLS Root Certificate
const char* root_ca = \
"-----BEGIN CERTIFICATE-----\n" \
"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\n" \
"-----END CERTIFICATE-----";

// Pins
const int moisturePins[3] = {35, 32, 33};
const int pumpPins[3] = {25, 26, 27};

// Timing
const unsigned long publishInterval = 60000; // 60 seconds
unsigned long lastPublishTime = 0;
const unsigned long calibrationPeriod = 20000;

// Pump control timing
const unsigned long pumpDuration = 15000;  // 15 seconds
unsigned long pumpStartTimes[3] = {0, 0, 0};  // Track when each pump was turned on
bool pumpActive[3] = {false, false, false};  // Track pump state

// Preferences
Preferences preferences;
int airValues[3];
int waterValues[3];
unsigned long startTime;
bool isCalibrated;

// WiFi & MQTT
WiFiClientSecure secureClient;
PubSubClient client(secureClient);

// Function declarations
void setup_wifi();
void reconnect();
void publishSensorData();
void mqttCallback(char* topic, byte* payload, unsigned int length);

void setup() {
  Serial.begin(115200);

  for (int i = 0; i < 3; i++) {
    pinMode(pumpPins[i], OUTPUT);
    digitalWrite(pumpPins[i], LOW);
  }

  preferences.begin("moisture", false);

  isCalibrated = preferences.getBool("isCalibrated", false);
  for (int i = 0; i < 3; i++) {
    airValues[i] = preferences.getInt(("air" + String(i)).c_str(), 4095);
    waterValues[i] = preferences.getInt(("water" + String(i)).c_str(), 0);
  }

  if (!isCalibrated) {
    Serial.println("Calibration mode: insert sensors into dry/wet soil alternately.");
    startTime = millis();
  } else {
    Serial.println("Loaded calibration values.");
  }

  setup_wifi();

  secureClient.setCACert(root_ca);
  client.setServer(mqttServer, mqttPort);
  client.setCallback(mqttCallback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Auto-calibration logic
  if (!isCalibrated && millis() - startTime < calibrationPeriod) {
    for (int i = 0; i < 3; i++) {
      int value = analogRead(moisturePins[i]);
      waterValues[i] = max(waterValues[i], value);
      airValues[i] = min(airValues[i], value);
    }
    Serial.println("Calibrating...");
  } else if (!isCalibrated) {
    for (int i = 0; i < 3; i++) {
      preferences.putInt(("air" + String(i)).c_str(), airValues[i]);
      preferences.putInt(("water" + String(i)).c_str(), waterValues[i]);
    }
    preferences.putBool("isCalibrated", true);
    isCalibrated = true;
    Serial.println("Calibration complete.");
  }

  // Periodic data publish
  if (millis() - lastPublishTime >= publishInterval && isCalibrated) {
    publishSensorData();
    lastPublishTime = millis();
  }
  // Pump autoshutoff
  for (int i = 0; i < 3; i++) {
  if (pumpActive[i] && millis() - pumpStartTimes[i] >= pumpDuration) {
    digitalWrite(pumpPins[i], LOW);
    pumpActive[i] = false;
    Serial.printf("Pump %d OFF (timer ended)\n", i + 1);
  }
}

}

void publishSensorData() {
  StaticJsonDocument<200> doc;

  for (int i = 0; i < 3; i++) {
    int value = analogRead(moisturePins[i]);
    int percent = map(value, airValues[i], waterValues[i], 100, 0);
    percent = constrain(percent, 0, 100);

    doc["sensor" + String(i + 1)] = percent;

    Serial.printf("Sensor %d: %d%% (Raw: %d)\n", i + 1, percent, value);
  }

  char buffer[256];
  size_t len = serializeJson(doc, buffer);
  client.publish(mqttPubTopic, buffer, len);
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("MQTT message arrived [");
  Serial.print(topic);
  Serial.print("] ");

  payload[length] = '\0'; // Null-terminate
  String msg = String((char*)payload);
  Serial.println(msg);

  StaticJsonDocument<128> doc;
  DeserializationError error = deserializeJson(doc, payload);

  if (error) {
    Serial.println("Failed to parse control JSON");
    return;
  }

  for (int i = 0; i < 3; i++) {
  if (doc["pump"][i]) {
    digitalWrite(pumpPins[i], HIGH);
    pumpStartTimes[i] = millis();
    pumpActive[i] = true;
    Serial.printf("Pump %d ON (auto-off in 15s)\n", i + 1);
  }
}

}

void setup_wifi() {
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi connected. IP address: " + WiFi.localIP().toString());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Connecting to MQTT... ");
    if (client.connect("esp32Client", mqttUser, mqttPassword)) {
      Serial.println("connected.");
      client.subscribe(mqttSubTopic);
      Serial.printf("Subscribed to %s\n", mqttSubTopic);
    } else {
      Serial.print("Failed (rc=");
      Serial.print(client.state());
      Serial.println("). Retrying in 5 seconds...");
      delay(5000);
    }
  }
}
