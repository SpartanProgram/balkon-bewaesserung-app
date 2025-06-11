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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Info for $label"),
            content: const Text("Your details go here."),
          ),
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
          child: Text(label,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ),
      ),
    );
  }
}
