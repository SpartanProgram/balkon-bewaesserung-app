import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoistureChart extends StatelessWidget {
  final List<int> data;

  const MoistureChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Keine Verlaufsdaten'),
      );
    }

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i].toDouble()),
              ),
              isCurved: true,
              color: Colors.lightGreen,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
