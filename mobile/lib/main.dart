import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const EletrodescarteApp());
}

class EletrodescarteApp extends StatelessWidget {
  const EletrodescarteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1ECB71);

    return MaterialApp(
      title: 'Eletrodescarte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF212529),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}