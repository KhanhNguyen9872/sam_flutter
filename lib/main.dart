// main.dart
import 'package:flutter/material.dart';
import 'init.dart'; // Splash
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  tz.initializeTimeZones(); // Initialize timezone data
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash to Login Demo',
      debugShowCheckedModeBanner: false,
      home: const SplashPage(), // vào splash trước
    );
  }
}
