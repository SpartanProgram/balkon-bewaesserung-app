import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/sensor_data_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentSensorIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final provider = context.read<SensorDataProvider>();
      provider.reconnectIfNeeded(); // This assumes you have reconnect logic in the provider
    }
  }

  @override
  Widget build(BuildContext context) {
    final sensorData = context.watch<SensorDataProvider>().sensorData;
    final isConnected = context.watch<SensorDataProvider>().isConnected;


    return CustomScaffold(
      title: 'Hauptmenü',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Automatische Balkonpflanzen-\nBewässerung',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.cancel,
                color: isConnected ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'Verbunden mit MQTT' : 'Nicht verbunden',
                style: TextStyle(
                  fontSize: 16,
                  color: isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 30),

          // Sensor Page Slider
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: sensorData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentSensorIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final sensor = sensorData[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      sensor["sensor"]!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoCard("Bodenfeuchtigkeit", sensor["moisture"]!),
                    const SizedBox(height: 16),
                    _infoCard("Letzte Bewässerung", sensor["lastWatered"]!),
                  ],
                );
              },
            ),
          ),

          if (sensorData.isNotEmpty)
            _waterLevelIndicator(sensorData[0]["waterLevel"]!),
          const SizedBox(height: 8),

          // Dot Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(sensorData.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  _currentSensorIndex == index
                      ? Icons.circle
                      : Icons.circle_outlined,
                  size: 12,
                  color: _currentSensorIndex == index
                      ? Colors.black
                      : Colors.grey,
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                HapticFeedback.heavyImpact();
                context.read<SensorDataProvider>().triggerWatering();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🚿 Bewässerung gestartet")),
                );
              },
              child: const Text(
                'Jetzt bewässern',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _waterLevelIndicator(String waterLevelStr) {
    int level = int.tryParse(waterLevelStr.replaceAll('%', '')) ?? -1;

    IconData icon = Icons.water_drop;
    Color iconColor;
    String statusText;

    if (level >= 70) {
      iconColor = Colors.green;
      statusText = "Wasserstand: In Ordnung";
    } else if (level >= 30) {
      iconColor = Colors.orange;
      statusText = "Wasserstand: Mittel";
    } else if (level >= 0) {
      iconColor = Colors.red;
      statusText = "Wasserstand: Niedrig";
    } else {
      iconColor = Colors.grey;
      statusText = "Wasserstand: --";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FDEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static Widget _infoCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FDEB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
