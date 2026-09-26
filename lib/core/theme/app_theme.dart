import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Tema global de la aplicación.
///
/// Aplica el sistema de diseño v2 (ver docs/design-system.md):
/// - Fondo azul-noche, superficies porcelana, acento bronce.
/// - Tipografía: Fraunces (serif) para títulos, Inter (sans) para UI.
///
/// Durante la migración (S10), los valores anteriores (crema) coexisten
/// con los nuevos. Al terminar la migración, se elimina lo viejo.
class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.fondoAzulNoche,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.acentoBronce,
        primary: AppColors.acentoBronce,
        surface: AppColors.superficiePorcelana,
        error: AppColors.alertaLadrillo,
        brightness: Brightness.dark,
      ),
    );

    // Tipografía: Fraunces para títulos, Inter para cuerpo y UI.
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.fraunces(
        fontSize: 44, fontWeight: FontWeight.w700, color: AppColors.acentoBronce),
      displayMedium: GoogleFonts.fraunces(
        fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.acentoBronce),
      headlineLarge: GoogleFonts.fraunces(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.acentoBronce),
      headlineMedium: GoogleFonts.fraunces(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.acentoBronce),
      titleLarge: GoogleFonts.fraunces(
        fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.fondoAzulNoche),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, color: AppColors.fondoAzulNoche),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, color: AppColors.textoSecundarioGris),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.acentoBronce,
          foregroundColor: AppColors.fondoAzulNoche,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.acentoBronce,
          foregroundColor: AppColors.fondoAzulNoche,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
