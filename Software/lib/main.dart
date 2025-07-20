import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'widgets/sensor_data_provider.dart';
import 'services/notification_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final provider = SensorDataProvider();
  await provider.loadHistoryFromPrefs();
  await provider.loadScheduleFromPrefs(); 
  await provider.loadAndConnectFromPrefs(); 

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SensorDataProvider>(context);

    return MaterialApp(
      title: 'Balkon Bewässerung',
      themeMode: provider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFDFFFD7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.greenAccent,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
