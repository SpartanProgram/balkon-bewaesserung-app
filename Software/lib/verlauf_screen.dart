import 'package:flutter/material.dart';
import 'dart:ui';
import 'widgets/custom_scaffold.dart';
import 'package:flutter/services.dart';

class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdayLabels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"];

    // Liste der letzten 7 Tage (beginnend mit heute)
    final List<DateTime> last7Days = List.generate(
      7,
      (i) => now.subtract(Duration(days: i)),
    ).reversed.toList(); // Älteste zuerst → Heute zuletzt

    return CustomScaffold(
      title: 'Verlauf',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              "🕓 Verlauf der letzten 7 Tage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: last7Days.map((date) {
                  final label = weekdayLabels[date.weekday - 1];
                  final isToday = date.day == now.day &&
                      date.month == now.month &&
                      date.year == now.year;

                  final Color dayColor = isToday
                      ? Colors.orange
                      : Colors.green.shade700;

                  return _dayButton(context, label, date, dayColor, isToday);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayButton(BuildContext context, String label, DateTime date, Color color, bool isToday) {
    return _AnimatedDayBox(
      label: label,
      color: color,
      isToday: isToday,
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
                _buildDetailPopup(context, date, color),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDetailPopup(BuildContext context, DateTime date, Color borderColor) {
    final String formattedDate =
        "${_weekdayLong(date.weekday)} – ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";

    final entries = [
      {"time": "08:00", "event": "Sensor 1: ${40 + date.day % 10}% Bodenfeuchtigkeit"},
      {"time": "12:00", "event": "Automatisch bewässert (${100 + date.day % 50} ml)"},
      if (date.weekday == DateTime.friday)
        {"time": "18:00", "event": "Sensorfehler erkannt"},
    ];

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
                formattedDate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                          Positioned(
                            left: 22,
                            top: 0,
                            bottom: isLast ? 8 : 0,
                            child: Container(
                              width: 2,
                              color: isLast ? Colors.transparent : Colors.black26,
                            ),
                          ),
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

  String _weekdayLong(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Montag";
      case DateTime.tuesday:
        return "Dienstag";
      case DateTime.wednesday:
        return "Mittwoch";
      case DateTime.thursday:
        return "Donnerstag";
      case DateTime.friday:
        return "Freitag";
      case DateTime.saturday:
        return "Samstag";
      case DateTime.sunday:
        return "Sonntag";
      default:
        return "";
    }
  }
}

class _AnimatedDayBox extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isToday;

  const _AnimatedDayBox({
    required this.label,
    required this.color,
    required this.onTap,
    this.isToday = false,
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
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1.5,
                      ),
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
