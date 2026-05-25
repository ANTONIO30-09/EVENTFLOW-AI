import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.textDark,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
