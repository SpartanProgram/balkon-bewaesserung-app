import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'widgets/sensor_data_provider.dart';


class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

@override
Widget build(BuildContext context) {
  final history = context.watch<SensorDataProvider>().history;
  final now = DateTime.now();

  // Group by date
  final Map<String, List<Map<String, dynamic>>> grouped = {};
  for (var entry in history) {
    final key = _formatDateKey(entry['timestamp'] as DateTime);
    grouped.putIfAbsent(key, () => []).add(entry);
  }

  final todayKey = _formatDateKey(now);
  final todayEntries = grouped[todayKey] ?? [];

  final previousDays = List.generate(6, (i) {
    final day = now.subtract(Duration(days: i + 1));
    return {
      "label": _formatDateLabel(day),
      "key": _formatDateKey(day),
      "date": day,
    };
  }).where((d) => grouped.containsKey(d["key"])).toList();

  return CustomScaffold(
    title: 'Verlauf',
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (todayEntries.isNotEmpty) ...[
          const Text("Heute", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List.generate(todayEntries.length, (index) {
            return buildTimelineEntry(todayEntries[index], index == todayEntries.length - 1);
          }),
          const SizedBox(height: 24),
        ],
        if (previousDays.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: previousDays.map((d) {
              return _dayButton(
                context,
                d["label"] as String,
                d["date"] as DateTime,
                Colors.green.shade700,
                false,
                entries: grouped[d["key"]as String]!,
              );
            }).toList(),
          )
        else
          const Center(child: Text("Kein Verlauf für die letzten 7 Tage.")),
      ],
    ),
  );
}

String _formatDateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

String _formatDateLabel(DateTime dt) {
  const weekdaysShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  return weekdaysShort[dt.weekday - 1];
}

    Widget _dayButton(
      BuildContext context,
      String label,
      DateTime date,
      Color color,
      bool isToday, {
      required List<Map<String, dynamic>> entries,
    }) {
      return _AnimatedDayBox(
        label: label,
        color: color,
        isToday: isToday,
        entryCount: entries.length,
        onTap: () {
          showModalBottomSheet(
          context: context,
           isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return _buildDetailPopup(context, date, color, entries);
          },
        );
      },
    );
  }
}

Widget _buildDetailPopup(BuildContext context, DateTime date, Color borderColor, List<Map<String, dynamic>> entries) {
  final String formattedDate =
      "${_weekdayLong(date.weekday)} – ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFF7FDEB),
      border: Border.all(color: borderColor, width: 2),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.max,
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
            itemCount: entries.length,
            itemBuilder: (context, index) {
            final entry = entries[index];
            final isLast = index == entries.length - 1;

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
              child: buildTimelineEntry(entry, isLast),
            );
            },
          ),
        ),
      ],
    ),
  );
}
class _AnimatedDayBox extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isToday;
  final int entryCount;

  const _AnimatedDayBox({
    required this.label,
    required this.color,
    required this.onTap,
    this.isToday = false,
    this.entryCount = 0,
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
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ Badge if count > 0
              if (widget.entryCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: widget.entryCount > 0
                      ? Container(
                          key: ValueKey<int>(widget.entryCount),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent,
                          ),
                          child: Text(
                            '${widget.entryCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

  Widget buildTimelineEntry(Map<String, dynamic> entry, bool isLast) {
  final String event = entry["event"] ??
      (entry["type"] == "sensor"
          ? "Sensor ${entry["sensorId"] + 1}: ${entry["moisture"]}% Bodenfeuchtigkeit, ${entry["waterLevel"]}% Wasser"
          : entry["message"] ?? "Unbekannt");

  IconData icon;
  Color iconColor;

  if (event.toLowerCase().contains("feuchtigkeit")) {
    icon = Icons.opacity;
    iconColor = Colors.teal;
  } else if (event.toLowerCase().contains("wasserstand")) {
    icon = Icons.water_drop;
    iconColor = Colors.blue;
  } else if (event.toLowerCase().contains("bewässert")) {
    icon = Icons.water;
    iconColor = Colors.green;
  } else if (event.toLowerCase().contains("sensorfehler") || event.toLowerCase().contains("fehler")) {
    icon = Icons.error_outline;
    iconColor = Colors.red;
  } else {
    icon = Icons.info_outline;
    iconColor = Colors.grey;
  }

  return Stack(
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
            Text(
              entry["time"] ??
                  "${entry["timestamp"]?.hour.toString().padLeft(2, '0')}:${entry["timestamp"]?.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(event, style: const TextStyle(fontSize: 16)),
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
  );
}