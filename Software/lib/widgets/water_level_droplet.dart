import 'package:flutter/material.dart';

class WaterLevelDroplet extends StatelessWidget {
  final int waterPercent;

  const WaterLevelDroplet({super.key, required this.waterPercent});

  @override
  Widget build(BuildContext context) {
    final double level = waterPercent.clamp(0, 100) / 100;
    final Color levelColor = waterPercent >= 70
        ? Colors.lightBlueAccent
        : waterPercent >= 30
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 36,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.2,
                    colors: [
                      levelColor.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 16,
                height: 60 * level,
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Wasserstand",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  waterPercent >= 70
                      ? "In Ordnung"
                      : waterPercent >= 30
                          ? "Mittel"
                          : "Niedrig",
                  style: TextStyle(
                      color: levelColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text(
            "$waterPercent%",
            style: TextStyle(
              fontSize: 16,
              color: levelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
