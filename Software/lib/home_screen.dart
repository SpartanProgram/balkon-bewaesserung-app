import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/sensor_data_provider.dart';
import '../services/sensor_name_service.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/moisture_chart.dart';
import 'dart:convert';




class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final AudioPlayer _wateringPlayer = AudioPlayer();
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
    if (value < 30) return "🦀";
    if (value < 60) return "🌿";
    return "💧";
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final provider = context.read<SensorDataProvider>();

    // ✅ Listen to watering end to close dialog
    provider.wateringEnded.addListener(() {
      if (provider.wateringEnded.value && mounted) {
        if (Navigator.canPop(context)) Navigator.of(context, rootNavigator: true).pop();
        provider.wateringEnded.value = false;
      }
    });

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
      context.read<SensorDataProvider>().reconnectIfNeeded();
    }
  }

  void _showWateringDialog(String title, {required bool isGlobal}) async {
    final prefs = await SharedPreferences.getInstance();
    final durationMs = prefs.getInt('watering_duration_ms') ?? 15000;

    // Start sound at full volume
    await _wateringPlayer.setVolume(1.0);
    await _wateringPlayer.play(AssetSource('sounds/watering.mp3'));

    // Show dialog with animation
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
              isGlobal ? 'assets/animations/watering_all.json' : 'assets/animations/watering.json',
              width: isGlobal ? 160 : 120,
              repeat: true,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Start fade-out 1 second before stop
    Future.delayed(Duration(milliseconds: durationMs - 1000), () async {
      for (double v = 1.0; v >= 0.0; v -= 0.1) {
        await _wateringPlayer.setVolume(v);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });

    // Stop sound and close dialog
    Future.delayed(Duration(milliseconds: durationMs + 200), () {
      if (mounted) {
        _wateringPlayer.stop();
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });
  }

Widget _buildWaterLevelStatus(String value) {
  int level = int.tryParse(value.replaceAll('%', '')) ?? 0;

  late IconData icon;
  late Color color;
  late String label;
  bool shouldAnimate = false;

  if (level > 60) {
    icon = Icons.check_circle;
    color = Colors.green;
    label = 'Wasserstand: Gut';
  } else if (level > 20) {
    icon = Icons.warning_amber_rounded;
    color = Colors.orange;
    label = 'Wasserstand: Niedrig';
    shouldAnimate = true;
  } else {
    icon = Icons.error_outline;
    color = Colors.red;
    label = 'Wasserstand: Kritisch';
    shouldAnimate = true;
  }

  Widget card = Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  if (shouldAnimate) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.05),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        if (mounted) setState(() {}); // Loop animation
      },
      child: card,
    );
  } else {
    return card;
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
    bool isGlobalWatering = false;


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
              height: 670,
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
                        child: Padding(
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
                              Builder(
                                builder: (_) {
                                  final raw = sensor["history"];
                                  final now = DateTime.now();

                                  final List<Map<String, dynamic>> history = (raw != null)
                                      ? (jsonDecode(raw) as List)
                                          .map((entry) => Map<String, dynamic>.from(entry))
                                          .where((entry) {
                                            final timestamp = DateTime.tryParse(entry["timestamp"] ?? "");
                                            return timestamp != null && now.difference(timestamp).inHours < 24;
                                          })
                                          .toList()
                                      : [];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20, bottom: 32),
                                    child: MoistureChart(rawData: history),
                                  );
                                },
                              ),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isWatering ? Colors.grey : const Color.fromARGB(255, 207, 207, 207),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                      onPressed: () async {
                                              HapticFeedback.mediumImpact();
                                              // 🔊 Play watering sound
                                              await context.read<SensorDataProvider>().triggerWatering(sensorId: index);
                                              _showWateringDialog("$sensorName wird gerade bewässert 💧", isGlobal: false);
                                              // Show dialog
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
                          ],
                        ),
                        ),
                      );   
                    },
                  );
                },
              ),                         
            ),
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
           const SizedBox(height: 16),
           if (sensorData.isNotEmpty)
            _buildWaterLevelStatus(sensorData[_currentSensorIndex]["waterLevel"] ?? '0'),
           const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isGlobalWatering ? Colors.grey : Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: isGlobalWatering
                          ? null
                          : () async {
                              HapticFeedback.heavyImpact();
                              setState(() => isGlobalWatering = true);

                              // 🔊 Play watering sound
                          await context.read<SensorDataProvider>().triggerWatering();
                          _showWateringDialog("Alle Pflanzen werden gerade bewässert 💧", isGlobal: true);
                          setState(() => isGlobalWatering = false);
                            },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isGlobalWatering
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
                                'Alle Pflanzen manuell bewässern',
                                key: ValueKey(2),
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    );
                  },
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

    final TextEditingController customController = TextEditingController(text: customName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/watering_all.json',
                      height: 80,
                      repeat: false,
                    ),
                    const SizedBox(height: 8),
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
                            customController.clear();
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
                        controller: customController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: "Individueller Name",
                        ),
                        onChanged: (value) => customName = value,
                      ),
                  ],
                ),
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
                    ? customController.text.trim()
                    : selectedOption;

                if (finalName.isNotEmpty) {
                  await SensorNameService.saveName(sensorIndex, finalName);
                  Navigator.of(context).pop(); // Close the rename dialog

                  // Show success dialog that closes itself
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.black54,
                      transitionDuration: const Duration(milliseconds: 200),
                      pageBuilder: (_, __, ___) => const SizedBox.shrink(), // required but unused
                      transitionBuilder: (context, animation, _, child) {
                        return _FadingSuccessDialog(finalName: finalName);
                      },
                    );                                         
                  setState(() {
                    // Trigger refresh
                  });
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



class _FadingSuccessDialog extends StatefulWidget {
  final String finalName;

  const _FadingSuccessDialog({required this.finalName});

  @override
  State<_FadingSuccessDialog> createState() => _FadingSuccessDialogState();
}

class _FadingSuccessDialogState extends State<_FadingSuccessDialog> {
  double opacity = 1.0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // 🔊 Play sound on open
    _audioPlayer.play(AssetSource('sounds/success.mp3'));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => opacity = 0.0);
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: opacity, end: opacity),
        duration: const Duration(milliseconds: 600),
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/animations/success.json', height: 80),
              const SizedBox(height: 12),
              Text(
                '🌿 "${widget.finalName}" wurde gespeichert!',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}