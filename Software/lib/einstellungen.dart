import 'package:flutter/material.dart';
import 'widgets/custom_scaffold.dart';

class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  @override
  State<EinstellungenScreen> createState() => _EinstellungenScreenState();
}

class _EinstellungenScreenState extends State<EinstellungenScreen> {
  bool _benachrichtigungenAktiv = true;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Einstellungen",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FDEB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    "Benach-\nrichtigungen",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Switch(
                  value: _benachrichtigungenAktiv,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _benachrichtigungenAktiv = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
