import 'dart:ui';
import 'package:flutter/material.dart';

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
  bool _drawerOpen = false;

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
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFD7),
      body: Stack(
        children: [
          _buildMainContent(context), // base layer
          _buildBlurOverlay(),        // fading + blur backround
          _buildDrawer(context),      // sliding drawer on top
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    setState(() {
                      _drawerOpen = true;
                    });
                  },
                ),
                const Spacer(),
              ],
            ),
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
      ),
    );
  }

Widget _buildBlurOverlay() {
  return _drawerOpen
      ? AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _drawerOpen = false;
              });
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        )
      : const SizedBox.shrink(); // Empty when closed
}


 Widget _buildDrawer(BuildContext context) {
  return AnimatedPositioned(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    top: 0,
    bottom: 0,
    left: _drawerOpen ? 0 : -240,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(100),
        bottomRight: Radius.circular(100),
      ),
      child: Container(
        color: Colors.white,
        width: 240,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _drawerOpen = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            _drawerItem(context, 'Hauptmenü', Icons.home, () {
              setState(() {
                _drawerOpen = false;
              });
            }),
            _drawerItem(context, 'Verlauf', Icons.history, () {}),
            _drawerItem(context, 'Zeitplan', Icons.schedule, () {}),
            _drawerItem(context, 'Einstellungen', Icons.settings, () {}),
          ],
        ),
      ),
    ),
  );
}

  Widget _drawerItem(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Material(
      color: Colors.transparent, // Needed for ripple to show
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.green.withOpacity(0.3),
        highlightColor: Colors.green.withOpacity(0.1),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
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
