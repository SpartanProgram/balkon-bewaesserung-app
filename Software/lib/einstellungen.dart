import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/sensor_data_provider.dart';

class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  @override
  State<EinstellungenScreen> createState() => _EinstellungenScreenState();
}

class _EinstellungenScreenState extends State<EinstellungenScreen> {
  bool _benachrichtigungenAktiv = true;
  bool _useTLS = false;

  final TextEditingController _brokerController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '8883');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _connectToBroker() {
    final broker = _brokerController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ?? 8883;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (broker.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte Broker-Adresse eingeben")),
      );
      return;
    }

    context.read<SensorDataProvider>().connectToMqtt(
      broker: broker,
      port: port,
      username: username,
      password: password,
      useTLS: _useTLS,
      onConnected: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Erfolgreich verbunden")),
        );
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🔌 Verbindung wird aufgebaut...")),
    );
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
                        // Optional external link or provider info
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
