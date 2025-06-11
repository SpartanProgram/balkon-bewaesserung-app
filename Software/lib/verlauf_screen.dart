import 'package:flutter/material.dart';

class VerlaufScreen extends StatelessWidget {
  const VerlaufScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFD7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Verlauf',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
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
      ),
    );
  }

  Widget _dayButton(BuildContext context, String label, Color color) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _buildBottomSheet(context, label, color),
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}

Widget _buildBottomSheet(BuildContext context, String day, Color borderColor) {
  final List<Map<String, String>> entries = [
    {"time": "06:00", "event": "20% Boden-Feuchtigkeit"},
    {"time": "10:00", "event": "10% Wasserstand"},
    {"time": "12:30", "event": "Automatisch bewässert (100 ml)"},
    {"time": "20:00", "event": "Manuell bewässert (150 ml)"},
    {"time": "22:00", "event": "Sensorfehler erkannt"},
  ];

  return DraggableScrollableSheet(
    initialChildSize: 0.5,
    minChildSize: 0.4,
    maxChildSize: 0.9,
    builder: (context, scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7FDEB),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: borderColor, width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            Text(
              "$day – 25. April",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Scrollable content
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry["time"]!, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(entry["event"]!, style: const TextStyle(fontSize: 16)),
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



 Widget _buildDetailPopup(BuildContext context, String day, Color borderColor) {
  final List<Map<String, String>> entries = [
    {"time": "06:00", "event": "20% Boden-Feuchtigkeit"},
    {"time": "10:00", "event": "10% Wasserstand"},
    {"time": "12:30", "event": "Automatisch bewässert (100 ml)"},
    {"time": "20:00", "event": "Manuell bewässert (150 ml)"},
    {"time": "22:00", "event": "Sensorfehler erkannt"},
  ];

  return Dialog(
    backgroundColor: const Color(0xFFF7FDEB),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: borderColor, width: 2),
    ),
    insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            "$day – 25. April",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ...entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: const BoxDecoration(
              color: Color(0xFFF7FDEB),
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry["time"]!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry["event"]!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    ),
  );
}
}

