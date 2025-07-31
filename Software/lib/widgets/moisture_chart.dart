import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoistureChart extends StatelessWidget {
  final List<Map<String, dynamic>> rawData;

  const MoistureChart({required this.rawData, super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.Hm(); // Format to "HH:mm"

    // Map rawData to spots and keep index-to-time map
    final List<FlSpot> spots = [];
    final Map<double, String> timeLabels = {};

    for (int i = 0; i < rawData.length; i++) {
      final entry = rawData[i];
      final time = DateTime.tryParse(entry['timestamp'] ?? '') ?? DateTime.now();
      final value = entry['value'] is int
          ? entry['value'].toDouble()
          : double.tryParse(entry['value'].toString()) ?? 0;

      spots.add(FlSpot(i.toDouble(), value));
      timeLabels[i.toDouble()] = formatter.format(time);
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (spots.length / 4).clamp(1, 5).toDouble(),
                getTitlesWidget: (value, meta) {
                  final label = timeLabels[value];
                  return Text(label ?? '', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x;
                  final time = timeLabels[index] ?? '';
                  return LineTooltipItem(
                    '$time\n${spot.y.toStringAsFixed(0)}%',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
