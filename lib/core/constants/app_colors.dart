import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFAF5E6);  // Fondo crema/beige suave
  static const Color surfaceCard = Color(0xFFF5EAD2); // Fondo de inputs y tarjetas de invitados
  static const Color textDark = Color(0xFF111111);     // Negro para títulos principales
  static const Color textMuted = Color(0xFF6E6A61);    // Gris/marrón para subtítulos
  static const Color bottomBarIndicatorSelected = Color(0xFF111111);
  static const Color bottomBarIndicatorUnselected = Color(0xFFD9D9D9);
  // Colores extraídos de las barras de progreso del Dashboard
  static const Color progressCheckIn = Color(0xFF0081C9);   // Azul
  static const Color progressInventario = Color(0xFF00CD74); // Verde
  static const Color progressMontaje = Color(0xFFFF0000);    // Rojo

  // ============================================================
  // NUEVO SISTEMA DE DISEÑO (v2)
  // Paleta basada en azul-noche, bronce y porcelana.
  // Ver: docs/design-system.md
  //
  // IMPORTANTE: estos colores conviven con los anteriores durante
  // la migración. Al terminar la migración completa (S10), los
  // colores viejos se eliminan.
  // ============================================================

  /// Fondo principal de la app. Azul-noche profundo (#1B2A3D).
  /// Evoca la elegancia de un evento nocturno.
  static const Color fondoAzulNoche = Color(0xFF1B2A3D);

  /// Superficies: tarjetas, inputs, modales. Papel porcelana cálido (#FBF9F4).
  /// Como una tarjeta de mesa física.
  static const Color superficiePorcelana = Color(0xFFFBF9F4);

  /// Acento principal: botones, títulos, filos de tarjeta. Bronce/dorado (#B8863E).
  /// El color de la tipografía en una invitación elegante.
  static const Color acentoBronce = Color(0xFFB8863E);

  /// Estado confirmado: check-in exitoso, distribución aprobada. Verde salvia (#3E7A5C).
  static const Color exitoVerdeSalvia = Color(0xFF3E7A5C);

  /// Estado de alerta: reglas 'forbid', capacidad insuficiente. Ladrillo apagado (#A63D40).
  /// Rojo suavizado, nunca rojo genérico de error.
  static const Color alertaLadrillo = Color(0xFFA63D40);

  /// Texto secundario: metadata, subtítulos. Gris cálido (#6B6459).
  /// Nunca gris frío de plantilla.
  static const Color textoSecundarioGris = Color(0xFF6B6459);
}
