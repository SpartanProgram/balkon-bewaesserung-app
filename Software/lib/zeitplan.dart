import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/custom_scaffold.dart';
import 'widgets/sensor_data_provider.dart';
import 'widgets/light_box.dart';

class ZeitplanScreen extends StatelessWidget {
  const ZeitplanScreen({super.key});

  void _showStyledTimePicker(BuildContext context, TimeOfDay currentTime) {
    int hour = currentTime.hour;
    int minute = currentTime.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            height: 340,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "⏰ Uhrzeit wählen",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hour picker
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: hour),
                          itemExtent: 40,
                          useMagnifier: true,
                          looping: true,
                          onSelectedItemChanged: (value) {
                            HapticFeedback.selectionClick();
                            hour = value;
                          },
                          children: List.generate(24,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Text(":", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      // Minute picker
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: minute),
                          itemExtent: 40,
                          useMagnifier: true,
                          looping: true,
                          onSelectedItemChanged: (value) {
                            HapticFeedback.selectionClick();
                            minute = value;
                          },
                          children: List.generate(60,
                            (index) => Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: const Text("Abbrechen", style: TextStyle(fontSize: 16)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final provider = context.read<SensorDataProvider>();
                          provider.updateSchedule(
                            isActive: provider.isScheduleActivated,
                            time: TimeOfDay(hour: hour, minute: minute),
                          );
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: const Text("Fertig", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDurationPicker(BuildContext context, int initialDurationSeconds) {
    int selectedDuration = initialDurationSeconds;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            height: 340,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "💧 Gießdauer wählen",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: (initialDurationSeconds - 5)),
                    itemExtent: 40,
                    useMagnifier: true,
                    looping: false,
                    onSelectedItemChanged: (value) {
                      HapticFeedback.selectionClick();
                      selectedDuration = value + 5;
                    },
                    children: List.generate(56, (i) => Center(child: Text("${i + 5} Sekunden"))),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: const Text("Abbrechen", style: TextStyle(fontSize: 16)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('watering_duration_ms', selectedDuration * 1000);
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: const Text("Fertig", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SensorDataProvider>();

    return CustomScaffold(
      title: 'Zeitplan',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Uhrzeit der\nautomatischen\nBewässerung einstellen\n(bei fehlenden Sensoren)",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 32),

          // Activation Switch Box
          LightBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Aktivieren", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Switch(
                  value: provider.isScheduleActivated,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade600,                  
                  onChanged: (value) {
                    HapticFeedback.mediumImpact();
                    provider.updateSchedule(
                      isActive: value,
                      time: provider.scheduledTime,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Time Picker Box
          GestureDetector(
            onTap: () => _showStyledTimePicker(context, provider.scheduledTime),
            child: LightBox(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "${provider.scheduledTime.hour.toString().padLeft(2, '0')} : ${provider.scheduledTime.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
          ),

          // Watering Duration Picker
          const SizedBox(height: 32),
          FutureBuilder<int>(
            future: SharedPreferences.getInstance().then((prefs) =>
              (prefs.getInt('watering_duration_ms') ?? 15000) ~/ 1000),
            builder: (context, snapshot) {
              final seconds = snapshot.data ?? 15;
              return GestureDetector(
                onTap: () => _showDurationPicker(context, seconds),
                child: LightBox(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("💧 Gießdauer", style: Theme.of(context).textTheme.titleMedium),
                      Text("$seconds Sekunden", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
