import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/custom_scaffold.dart';

class ZeitplanScreen extends StatefulWidget {
  const ZeitplanScreen({super.key});

  @override
  State<ZeitplanScreen> createState() => _ZeitplanScreenState();
}

class _ZeitplanScreenState extends State<ZeitplanScreen> {
  bool isActivated = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

  void _showStyledTimePicker() {
    int hour = selectedTime.hour;
    int minute = selectedTime.minute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            height: 340,
            decoration: const BoxDecoration(
              color: Color(0xFFF7FDEB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          setState(() {
                            selectedTime = TimeOfDay(hour: hour, minute: minute);
                          });
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FDEB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Aktivieren", style: TextStyle(fontSize: 18)),
                Switch(
                  value: isActivated,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      isActivated = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Time Picker Box
          GestureDetector(
            onTap: _showStyledTimePicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FDEB),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  "${selectedTime.hour.toString().padLeft(2, '0')} : ${selectedTime.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
