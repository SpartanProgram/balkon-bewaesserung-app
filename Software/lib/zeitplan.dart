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

  void _showCustomTimePicker() {
    int hour = selectedTime.hour;
    int minute = selectedTime.minute;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text("Zeit wählen", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: hour),
                        itemExtent: 40,
                        onSelectedItemChanged: (value) {
                          HapticFeedback.selectionClick();
                          hour = value;
                        },
                        children: List.generate(24, (index) => Center(child: Text(index.toString().padLeft(2, '0')))),
                      ),
                    ),
                    const Text(":", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    // Minute picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: minute),
                        itemExtent: 40,
                        onSelectedItemChanged: (value) {
                          HapticFeedback.selectionClick();
                          minute = value;
                        },
                        children: List.generate(60, (index) => Center(child: Text(index.toString().padLeft(2, '0')))),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Text("Abbrechen"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      child: const Text("Fertig"),
                      onPressed: () {
                        setState(() {
                          selectedTime = TimeOfDay(hour: hour, minute: minute);
                        });
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
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
                    HapticFeedback.lightImpact(); // Haptic on toggle
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
            onTap: _showCustomTimePicker,
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
