import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balkon Bewässerung',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
          background: const Color(0xFFDFFFD7),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentSensorIndex = 0;

  final List<Map<String, String>> sensorData = [
    {
      "sensor": "Sensor 1",
      "moisture": "45%",
      "waterLevel": "75%",
      "lastWatered": "Heute",
    },
    {
      "sensor": "Sensor 2",
      "moisture": "50%",
      "waterLevel": "60%",
      "lastWatered": "Gestern",
    },
    {
      "sensor": "Sensor 3",
      "moisture": "38%",
      "waterLevel": "85%",
      "lastWatered": "2 Tage",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Hauptmenü',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Automatische Balkonpflanzen-\nBewässerung',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                    _infoCard("Wasserstand", sensor["waterLevel"]!),
                    const SizedBox(height: 16),
                    _infoCard("Letzte Bewässerung", sensor["lastWatered"]!),
                  ],
                );
              },
            ),
          ),

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

          // Button
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
                // Trigger watering here
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
