import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';

class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Verlauf',
      body: Center(
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            _dayButton(context, "Mo", Colors.green.shade700),
            _dayButton(context, "Di", Colors.yellow),
            _dayButton(context, "Mi", Colors.green.shade700),
            _dayButton(context, "Do", Colors.green.shade700),
            _dayButton(context, "Fr", Colors.red),
            _dayButton(context, "Sa", Colors.green.shade700),
            _dayButton(context, "So", Colors.green.shade700),
          ],
        ),
      ),
    );
  }

  Widget _dayButton(BuildContext context, String label, Color color) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "Popup",
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, anim1, anim2) {
            return _buildDetailPopup(context, label, color);
          },
          transitionBuilder: (context, anim1, anim2, child) {
            final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOut);

            return Transform.scale(
              scale: curved.value,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15), // Slide up from 15% below
                  end: Offset.zero,
                ).animate(curved),
                child: Opacity(
                  opacity: anim1.value,
                  child: child,
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

Widget _buildDetailPopup(BuildContext context, String day, Color borderColor) {
  final Map<String, String> dateTitles = {
    "Mo": "Montag – 24. April",
    "Di": "Dienstag – 25. April",
    "Mi": "Mittwoch – 26. April",
    "Do": "Donnerstag – 27. April",
    "Fr": "Freitag – 28. April",
    "Sa": "Samstag – 29. April",
    "So": "Sonntag – 30. April",
  };

  final Map<String, List<Map<String, String>>> dayEvents = {
    "Mo": [
      {"time": "06:00", "event": "Sensor 1: 40% Bodenfeuchtigkeit"},
      {"time": "12:00", "event": "Automatisch bewässert (150 ml)"},
    ],
    "Di": [
      {"time": "08:00", "event": "Sensor 1: 35% Bodenfeuchtigkeit"},
      {"time": "10:30", "event": "Wasserstand niedrig"},
      {"time": "13:00", "event": "Manuell bewässert (100 ml)"},
    ],
    "Mi": [
      {"time": "07:00", "event": "Automatische Kontrolle"},
      {"time": "18:00", "event": "Sensor 2: 60% Wasserstand"},
    ],
    "Do": [
      {"time": "09:00", "event": "Sensor 3: 63% Wasserstand"},
    ],
    "Fr": [
      {"time": "10:00", "event": "Notfallbewässerung (200 ml)"},
      {"time": "12:30", "event": "Sensorfehler erkannt"},
    ],
    "Sa": [
      {"time": "06:30", "event": "Sensor 3: 45% Bodenfeuchtigkeit"},
      {"time": "11:00", "event": "Automatisch bewässert (100 ml)"},
    ],
    "So": [
      {"time": "08:00", "event": "Wasserstand OK"},
      {"time": "20:00", "event": "Sensoren schlafen"},
    ],
  };

  final entries = dayEvents[day] ?? [];

  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7FDEB),
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                dateTitles[day] ?? "Unbekannter Tag",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ...entries.asMap().entries.map((entryWithIndex) {
            final index = entryWithIndex.key;
            final entry = entryWithIndex.value;
            final isLast = index == entries.length - 1;

            IconData icon;
            Color iconColor;
            final event = entry["event"]!.toLowerCase();

            if (event.contains("bodenfeuchtigkeit")) {
              icon = Icons.opacity;
              iconColor = Colors.teal;
            } else if (event.contains("wasserstand")) {
              icon = Icons.water_drop;
              iconColor = Colors.blue;
            } else if (event.contains("bewässert")) {
              icon = Icons.water;
              iconColor = Colors.green;
            } else if (event.contains("sensorfehler") || event.contains("fehler")) {
              icon = Icons.error_outline;
              iconColor = Colors.red;
            } else {
              icon = Icons.info_outline;
              iconColor = Colors.grey;
            }

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FDEB),
                border: Border(
                  bottom: isLast ? BorderSide.none : const BorderSide(color: Colors.black12),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry["time"]!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry["event"]!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}
}
