import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // SISTEMA DE DISEÑO EventFlow AI
  // Paleta basada en azul-noche, bronce y porcelana.
  // Ver: docs/design-system.md
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
