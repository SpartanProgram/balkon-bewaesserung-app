import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  @override
  State<EinstellungenScreen> createState() => _EinstellungenScreenState();
}

class _EinstellungenScreenState extends State<EinstellungenScreen> {

  void _publishMessage(String topic, String message) {
  if (_mqttClient == null || _mqttClient!.connectionStatus!.state != MqttConnectionState.connected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nicht verbunden. Bitte zuerst verbinden.")),
    );
    return;
  }

  final builder = MqttClientPayloadBuilder();
  builder.addString(message);

  _mqttClient!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Gesendet: $message")),
  );
}
  bool _benachrichtigungenAktiv = true;
  bool _useTLS = false;

  final TextEditingController _brokerController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '1883');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  MqttServerClient? _mqttClient;

  Future<void> _connectToBroker() async {
  final broker = _brokerController.text.trim();
  final port = int.tryParse(_portController.text.trim()) ?? 1883;
  final username = _usernameController.text.trim();
  final password = _passwordController.text.trim();

  if (broker.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bitte Broker-Adresse eingeben")),
    );
    return;
  }

  _mqttClient = MqttServerClient(broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
  _mqttClient!.port = port;
  _mqttClient!.logging(on: false);
  _mqttClient!.useWebSocket = false;
  _mqttClient!.secure = _useTLS;
  _mqttClient!.keepAlivePeriod = 20;
  _mqttClient!.onDisconnected = _onDisconnected;

  final connMessage = MqttConnectMessage()
      .withClientIdentifier('flutter_client')
      .startClean()
      .withWillQos(MqttQos.atMostOnce);
  _mqttClient!.connectionMessage = connMessage;

  try {
    await _mqttClient!.connect(
      username.isNotEmpty ? username : null,
      password.isNotEmpty ? password : null,
    );
  } catch (e) {
    _mqttClient!.disconnect();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Verbindung fehlgeschlagen: $e")),
    );
    return;
  }

  if (_mqttClient!.connectionStatus!.state == MqttConnectionState.connected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Erfolgreich verbunden!")),
    );

    // Subscribe to test topic
    const testTopic = 'sensor/data';
    _mqttClient!.subscribe(testTopic, MqttQos.atMostOnce);

    _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      debugPrint('Nachricht von ${c[0].topic}: $payload');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Empfangen: $payload")),
      );
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Verbindung fehlgeschlagen: ${_mqttClient!.connectionStatus!.state}"),
      ),
    );
    _mqttClient!.disconnect();
  }
}

void _onDisconnected() {
  debugPrint("MQTT Verbindung getrennt.");
}


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Einstellungen",
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // Notification toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FDEB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      "Benach-\nrichtigungen",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Switch(
                    value: _benachrichtigungenAktiv,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    onChanged: (value) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _benachrichtigungenAktiv = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // MQTT Broker settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MQTT Verbindung",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _brokerController,
                    decoration: const InputDecoration(
                      labelText: "Broker-Adresse",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Port",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Benutzername (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Passwort (optional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _useTLS,
                        onChanged: (value) {
                          setState(() {
                            _useTLS = value ?? false;
                          });
                        },
                      ),
                      const Text("TLS/SSL verwenden"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _connectToBroker,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Verbinden"),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // TODO: Open browser or show supported providers
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Externe MQTT-Provider öffnen...")),
                        );
                      },
                      child: const Text("Noch kein Broker? Jetzt erstellen"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
