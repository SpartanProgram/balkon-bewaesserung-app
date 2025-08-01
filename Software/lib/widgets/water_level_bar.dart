import 'package:flutter/material.dart';

class WaterLevelBar extends StatelessWidget {
  final int waterPercent;

  const WaterLevelBar({super.key, required this.waterPercent});

  @override
  Widget build(BuildContext context) {
    final percent = (waterPercent.clamp(0, 100)) / 100;

    Color levelColor;
    if (waterPercent < 20) {
      levelColor = Colors.red;
    } else if (waterPercent < 60) {
      levelColor = Colors.orange;
    } else {
      levelColor = Colors.blue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Wasserstand",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 24,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  decoration: BoxDecoration(
                    color: levelColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "$waterPercent%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
