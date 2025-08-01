import 'package:flutter/material.dart';

class AnimatedWaterLevel extends StatelessWidget {
  final double levelPercent; // 0.0 to 1.0

  const AnimatedWaterLevel({super.key, required this.levelPercent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60),
      painter: _WaterLevelPainter(levelPercent),
    );
  }
}

class _WaterLevelPainter extends CustomPainter {
  final double levelPercent;

  _WaterLevelPainter(this.levelPercent);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw outer circle
    paint.color = Colors.grey.shade300;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint);

    // Draw water level (bottom-up)
    final waterHeight = size.height * levelPercent.clamp(0.0, 1.0);
    final waterRect = Rect.fromLTWH(
      0,
      size.height - waterHeight,
      size.width,
      waterHeight,
    );

    paint.color = levelPercent < 0.3
        ? Colors.redAccent
        : levelPercent < 0.6
            ? Colors.orange
            : Colors.blue;

    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2)));
    canvas.drawRect(waterRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
