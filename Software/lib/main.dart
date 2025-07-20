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
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: provider.themeMode, // ← dynamic theme mode
      home: const HomeScreen(),
    );
  }
}
