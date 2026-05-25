import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
// import 'screens/login/login_screen.dart'; // 👈 Lo guardamos para después
import 'package:eventflow_ai/screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventFlow AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(), // 👈 Apuntamos a la lista de eventos para ver cómo quedó
    );
  }
}