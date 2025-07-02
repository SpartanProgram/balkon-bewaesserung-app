import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/sensor_data_provider.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';




void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SensorDataProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balkon Bewässerung',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
          background: const Color(0xFFDFFFD7),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
