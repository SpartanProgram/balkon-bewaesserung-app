import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/sensor_data_provider.dart';
import '../services/sensor_name_service.dart';
import 'widgets/animated_water_level.dart'; // <-- Added import

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
      provider.reconnectIfNeeded();
    }
  }

    Widget _animatedMoistureCard(int moisture) {
    final double moistureValue = moisture.clamp(0, 100) / 100;
    final Color moistureColor = moisture >= 60
        ? Colors.green
        : moisture >= 30
            ? Colors.orange
            : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: moistureValue),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(moistureColor),
                      backgroundColor: Colors.grey.shade300,
                    );
                  },
                ),
              ),
              Text(
                "$moisture%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bodenfeuchtigkeit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  moisture >= 60
                      ? "Sehr gut"
                      : moisture >= 30
                          ? "OK"
                          : "Trocken",
                  style: TextStyle(
                    color: moistureColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plantBackground(String plantName, Widget child) {
  String emoji = plantName.trim().split(" ").first;
  String asset = "assets/placeholder.jpg"; // fallback

  final Map<String, String> emojiToAsset = {
    '🌱': 'assets/plants/basilikum.jpg',
    '🍅': 'assets/plants/tomate.jpg',
    '🫑': 'assets/plants/paprika.jpg',
    '🌶': 'assets/plants/chili.jpg',
    '🥬': 'assets/plants/salat.jpg',
    '🍓': 'assets/plants/erdbeere.jpg',
    '🌼': 'assets/plants/minze.jpg',
    '🧅': 'assets/plants/schnittlauch.jpg',
  };

  if (emojiToAsset.containsKey(emoji)) {
    asset = emojiToAsset[emoji]!;
  }

  return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(asset),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(16),
    child: child,
  );
}


      Widget _animatedWateringCard(String lastWateredText) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.green, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Letzte Bewässerung",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastWateredText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    

    @override
  @override
  Widget build(BuildContext context) {
    final sensorData = context.watch<SensorDataProvider>().sensorData;
    final isConnected = context.watch<SensorDataProvider>().isConnected;

    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScaffold(
      title: 'Hauptmenü',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
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
            const SizedBox(height: 20),

            // Sensor Page Slider
            SizedBox(
              height: 420, // Adjust as needed
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
                  return FutureBuilder<String>(
                    future: SensorNameService.getName(index, fallback: sensor["sensor"]!),
                    builder: (context, snapshot) {
                      final sensorName = snapshot.data ?? sensor["sensor"]!;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24), // Prevent cut off
                        child: _plantBackground(
                          sensorName,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(sensorName, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showRenameDialog(context, index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _animatedMoistureCard(
                                int.tryParse(sensor["moisture"]!.replaceAll('%', '')) ?? 0
                              ),
                              const SizedBox(height: 12),
                              _animatedWateringCard(sensor["lastWatered"]!),
                              const SizedBox(height: 12),                              ElevatedButton(
                                onPressed: () {
                                  context.read<SensorDataProvider>().triggerWatering(sensorId: index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("🚿 $sensorName bewässert")),
                                  );
                                },
                                child: const Text("Bewässern"),
                              ),
                              const SizedBox(height: 12), // optional spacing

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(sensorData.length, (dotIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(
                                      _currentSensorIndex == dotIndex
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      size: 10,
                                      color: _currentSensorIndex == dotIndex
                                          ? (isDark ? Colors.white : Colors.black)
                                          : (isDark ? Colors.white54 : Colors.grey),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            if (sensorData.isNotEmpty)
              _waterLevelIndicator(sensorData[0]["waterLevel"]!),

            const SizedBox(height: 16),

            // Manual All Water Button
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
                    const SnackBar(content: Text("🚿 Alle Pflanzen manuell bewässert")),
                  );
                },
                child: const Text(
                  'Alle Pflanzen manuell bewässern',
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

  void _showRenameDialog(BuildContext context, int sensorIndex) async {
    final List<String> plantOptions = [
      '🌱 Basilikum',
      '🍅 Tomate',
      '🫑 Paprika',
      '🌶 Chili',
      '🥬 Salat',
      '🍓 Erdbeere',
      '🌼 Minze',
      '🧅 Schnittlauch',
      '🔤 Benutzerdefiniert',
    ];

    String selectedOption = plantOptions[0];
    String customName = '';

    final currentName = await SensorNameService.getName(sensorIndex, fallback: 'Sensor ${sensorIndex + 1}');
    if (plantOptions.contains(currentName)) {
      selectedOption = currentName;
    } else {
      selectedOption = '🔤 Benutzerdefiniert';
      customName = currentName;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sensor umbenennen"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedOption,
                    items: plantOptions.map((plant) {
                      return DropdownMenuItem(
                        value: plant,
                        child: Text(plant),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedOption = value!;
                        if (value != '🔤 Benutzerdefiniert') {
                          customName = '';
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Pflanze auswählen",
                    ),
                  ),
                  if (selectedOption == '🔤 Benutzerdefiniert')
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Individueller Name",
                      ),
                      onChanged: (value) => customName = value,
                      controller: TextEditingController(text: customName),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () async {
                final finalName = selectedOption == '🔤 Benutzerdefiniert'
                    ? customName.trim()
                    : selectedOption;

                if (finalName.isNotEmpty) {
                  await SensorNameService.saveName(sensorIndex, finalName);
                  Navigator.of(context).pop();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('🌿 Sensor ${sensorIndex + 1} als "$finalName" gespeichert')),
                  );
                }
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  Widget _waterLevelIndicator(String waterLevelStr) {
    int level = int.tryParse(waterLevelStr.replaceAll('%', '')) ?? -1;
    double levelPercent = level.clamp(0, 100) / 100;

    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    String statusText;
    if (level >= 70) {
      statusText = "Wasserstand: In Ordnung";
    } else if (level >= 30) {
      statusText = "Wasserstand: Mittel";
    } else if (level >= 0) {
      statusText = "Wasserstand: Niedrig";
    } else {
      statusText = "Wasserstand: --";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: levelPercent),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return AnimatedWaterLevel(levelPercent: value);
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
          Text(
            "$level%",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  static Widget _infoCard(String title, String value, {required Color cardColor, required Color textColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, color: textColor)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}
