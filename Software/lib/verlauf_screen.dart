import 'package:flutter/material.dart';
import 'dart:ui';
import 'widgets/custom_scaffold.dart';
import 'package:flutter/services.dart';

class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Verlauf',
            body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              "🕓 Verlauf der letzten 7 Tage",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
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
          ),
        ],
      ),
    );
  }

Widget _dayButton(BuildContext context, String label, Color color) {
  final now = DateTime.now();
  final weekdayMap = {
    1: "Mo",
    2: "Di",
    3: "Mi",
    4: "Do",
    5: "Fr",
    6: "Sa",
    7: "So",
  };

  final currentDayLabel = weekdayMap[now.weekday];

  return _AnimatedDayBox(
    label: label,
    color: color,
    isToday: label == currentDayLabel, // ✅ HERVORHEBEN!
    onTap: () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              _buildDetailPopup(context, label, color),
            ],
          );
        },
      );
    },
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
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isLast = index == entries.length - 1;
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

                    // Animation
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + index * 70),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: child,
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          // Vertical line
                          Positioned(
                            left: 22,
                            top: 0,
                            bottom: isLast ? 8 : 0,
                            child: Container(
                              width: 2,
                              color: isLast ? Colors.transparent : Colors.black26,
                            ),
                          ),
                          // Event box
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.only(left: 48, right: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry["time"]!,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 12),
                                Icon(icon, size: 20, color: iconColor),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(entry["event"]!,
                                      style: const TextStyle(fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                          // Dot indicator
                          Positioned(
                            left: 16,
                            top: 14,
                            child: CircleAvatar(
                              radius: 6,
                              backgroundColor: iconColor,
                            ),
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

class _AnimatedDayBox extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isToday; // ⬅️ NEU

  const _AnimatedDayBox({
    required this.label,
    required this.color,
    required this.onTap,
    this.isToday = false, // ⬅️ Standard false
  });

  @override
  State<_AnimatedDayBox> createState() => _AnimatedDayBoxState();
}

class _AnimatedDayBoxState extends State<_AnimatedDayBox>
    with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.lightImpact();
    setState(() => _opacity = 0.3);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _opacity = 1.0);
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _opacity,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: widget.isToday
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1.5,
                      )
                    ]
                  : [],
              border: widget.isToday
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}