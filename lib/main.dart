import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:logic_grid/screens/main_menu_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flame
  await Flame.device.fullScreen();
  await Flame.device.setPortrait();

  runApp(const LogicGridApp());
}

/// The main app widget for LogicGrid: AI Archives
class LogicGridApp extends StatelessWidget {
  const LogicGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogicGrid: AI Archives',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4ECCA3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}
