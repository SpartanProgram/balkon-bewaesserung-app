import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/sensor_data_provider.dart';
import '../services/sensor_name_service.dart';
import 'widgets/water_level_droplet.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:lottie/lottie.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentSensorIndex = 0;

final Map<String, String> plantNameToAsset = {
  'Basilikum': 'assets/plants/basilikum.png',
  'Tomate': 'assets/plants/tomate.png',
  'Paprika': 'assets/plants/paprika.png',
  'Chili': 'assets/plants/chili.png',
  'Salat': 'assets/plants/salat.png',
  'Erdbeere': 'assets/plants/erdbeere.png',
  'Minze': 'assets/plants/minze.png',
  'Knoblauch': 'assets/plants/knoblauch.png',
};

  String _moistureEmoji(int value) {
  if (value < 30) return "🥀";
  if (value < 60) return "🌿";
  return "💧";
}


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

Widget _buildMoistureCard(int moisture) {
  double percent = (moisture.clamp(0, 100)) / 100;

  return Column(
    children: [
      const Text(
        "Feuchtigkeitsstand",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Tooltip(
        message: "Feuchtigkeit: $moisture%",
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(60),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: Colors.white, // background color
            ),
            child: LiquidCircularProgressIndicator(
              value: percent,
              valueColor: AlwaysStoppedAnimation(_getMoistureColor(moisture)),
              backgroundColor: Colors.grey.shade100,
              borderColor: Colors.grey.shade300,
              borderWidth: 2.0,
              direction: Axis.vertical,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _moistureEmoji(moisture),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      "$moisture%",
                      key: ValueKey(moisture),
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Color _getMoistureColor(int moisture) {
  if (moisture < 30) return Colors.redAccent;
  if (moisture < 60) return Colors.orange;
  return Colors.green;
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
  Widget build(BuildContext context) {
    final sensorData = context.watch<SensorDataProvider>().sensorData;
    final isConnected = context.watch<SensorDataProvider>().isConnected;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isWatering = false;


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
            SizedBox(
              height: 520,
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
                      final cleanedName = sensorName.trim().split(" ").first;
                      final moisture = int.tryParse(sensor["moisture"]!.replaceAll('%', '')) ?? 0;
                      return KeyedSubtree(
                        key: ValueKey(sensorName), // Force full widget rebuild if name changes
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (plantNameToAsset.containsKey(cleanedName))
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Image.asset(
                                        plantNameToAsset[cleanedName]!,
                                        width: 28,
                                        height: 28,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.error_outline, size: 20),
                                      ),
                                    ),
                                  Text(
                                    sensorName,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showRenameDialog(context, index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Add other widgets like moisture bar etc. here
                              _buildMoistureCard(moisture),
                              const SizedBox(height: 12),
                              _animatedWateringCard(sensor["lastWatered"]!),
                              const SizedBox(height: 12),                            
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isWatering ? Colors.grey : Colors.green[700],
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    onPressed: isWatering
                                        ? null
                                        : () async {
                                            HapticFeedback.mediumImpact();
                                            setState(() => isWatering = true);

                                            // Call watering
                                            await context.read<SensorDataProvider>().triggerWatering(sensorId: index);

                                            // Show success dialog with animation
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                contentPadding: const EdgeInsets.all(24),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Lottie.asset(
                                                      'assets/animations/watering.json',
                                                      width: 120,
                                                      repeat: false,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      "$sensorName wurde bewässert 💧",
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                            await Future.delayed(const Duration(seconds: 2));
                                            Navigator.of(context).pop();

                                            setState(() => isWatering = false);
                                          },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: isWatering
                                          ? Row(
                                              key: const ValueKey(1),
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Text("Wird bewässert..."),
                                              ],
                                            )
                                          : const Text(
                                              "Bewässern",
                                              key: ValueKey(2),
                                            ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
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
                        const SizedBox(height: 16),
            if (sensorData.isNotEmpty) ...[
              const Text(
                "Wasserstand",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              WaterLevelDroplet(
                waterPercent: int.tryParse(
                      sensorData[_currentSensorIndex]["waterLevel"]!.replaceAll('%', '')
                    ) ?? 0,
              ),
            ],
            const SizedBox(height: 16),
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
    final Map<String, String> plantOptions = {
      'Basilikum': 'basilikum.png',
      'Tomate': 'tomate.png',
      'Paprika': 'paprika.png',
      'Chili': 'chili.png',
      'Salat': 'salat.png',
      'Erdbeere': 'erdbeere.png',
      'Minze': 'minze.png',
      'Knoblauch': 'knoblauch.png',
      'Benutzerdefiniert': '', // No image
    };

    String selectedOption = plantOptions.keys.first;
    String customName = '';
    final currentName = await SensorNameService.getName(sensorIndex, fallback: 'Sensor ${sensorIndex + 1}');
    final cleanedName = currentName.trim().split(" ").first;


    if (plantOptions.containsKey(currentName)) {
      selectedOption = currentName;
    } else {
      selectedOption = 'Benutzerdefiniert';
      customName = currentName;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Sensor umbenennen"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              final imageAsset = plantOptions[selectedOption];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plantNameToAsset.containsKey(cleanedName))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        plantNameToAsset[cleanedName]!,
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedOption,
                    items: plantOptions.entries.map((entry) {
                      final label = entry.key;
                      final asset = entry.value;

                      return DropdownMenuItem(
                        value: label,
                        child: Row(
                          children: [
                            if (asset.isNotEmpty)
                              Image.asset('assets/plants/$asset', width: 30, height: 30),
                            if (asset.isNotEmpty) const SizedBox(width: 8),
                            Text(label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedOption = value!;
                        if (selectedOption != 'Benutzerdefiniert') {
                          customName = '';
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Pflanze auswählen",
                    ),
                  ),
                  if (selectedOption == 'Benutzerdefiniert')
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
                  final finalName = selectedOption == 'Benutzerdefiniert'
                      ? customName.trim()
                      : selectedOption;

                  if (finalName.isNotEmpty) {
                    await SensorNameService.saveName(sensorIndex, finalName);
                    Navigator.of(context).pop();

                    // Re-fetch the name and update UI
                    final newName = await SensorNameService.getName(sensorIndex, fallback: finalName);
                    setState(() {
                      // trigger rebuild with updated name
                      // no need to store locally because it's fetched inside FutureBuilder
                    });

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
}