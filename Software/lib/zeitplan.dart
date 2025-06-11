import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';

class ZeitplanScreen extends StatefulWidget {
  const ZeitplanScreen({super.key});

  @override
  State<ZeitplanScreen> createState() => _ZeitplanScreenState();
}

class _ZeitplanScreenState extends State<ZeitplanScreen> {
  bool isActivated = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
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
            onTap: () => _selectTime(context),
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
