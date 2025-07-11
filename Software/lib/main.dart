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