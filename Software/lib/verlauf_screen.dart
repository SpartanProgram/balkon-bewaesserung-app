import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';
import 'dart:ui';


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
      onTap: () async {
        // Optional: simulate tap effect (can be animated)
        await Future.delayed(const Duration(milliseconds: 100));

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Stack(
              children: [
                // Blur background
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Sliding popup
                _buildDetailPopup(context, label, color),
              ],
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
        {"time": "06:00", "event": "20% Bodenfeuchtigkeit"},
        {"time": "10:00", "event": "10% Wasserstand"},
        {"time": "12:30", "event": "Automatisch bewässert (100 ml)"},
        {"time": "20:00", "event": "Manuell bewässert (150 ml)"},
        {"time": "22:00", "event": "Sensorfehler erkannt"},
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

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FDEB),
            border: Border.all(color: borderColor, width: 2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              Text(
                dateTitles[day] ?? "Unbekannter Tag",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 0, color: Colors.black12),
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    final event = entry["event"]!.toLowerCase();

                    IconData icon;
                    Color iconColor;

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

                    return ListTile(
                      leading: Text(entry["time"]!, style: const TextStyle(fontSize: 16)),
                      title: Row(
                        children: [
                          Icon(icon, size: 20, color: iconColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(entry["event"]!, style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
