// GlassCard — tarjeta de vidrio reutilizable del Panel de Administración.
//
// Estilo aprobado (no modificar):
//   ClipRRect(borderRadius: 28)
//     > BackdropFilter(ImageFilter.blur(sigmaX: 18, sigmaY: 18))
//     > Container(color: AppColors.superficiePorcelana.withValues(alpha: ~0.10),
//                 border: Border.all(color: ...withValues(alpha: ~0.16-0.22)))
//
// RENDIMIENTO: cada BackdropFilter es costoso en Flutter web. Usa UN GlassCard
// por sección / tarjeta grande. NO envuelvas cada fila de tabla ni cada ítem
// de lista en un GlassCard.
//
// El Scaffold que contiene este widget debe tener backgroundColor:
// Colors.transparent para que el bokeh global (MaterialApp.builder) se vea
// a través del vidrio.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.blur = 18,
    this.fillAlpha = 0.10,
    this.borderAlpha = 0.18,
    this.width,
    this.height,
  });

  /// Contenido interno de la tarjeta.
  final Widget child;

  /// Padding interno. Por defecto 20 en todas las direcciones.
  final EdgeInsetsGeometry padding;

  /// Radio de las esquinas. Aprobado: 28.
  final double borderRadius;

  /// Sigma del blur. Aprobado: 18.
  final double blur;

  /// Alpha del relleno porcelana. Aprobado: ~0.10.
  final double fillAlpha;

  /// Alpha del borde porcelana. Aprobado: ~0.16 - 0.22.
  final double borderAlpha;

  /// Ancho opcional. Si es null, ocupa el ancho disponible.
  final double? width;

  /// Alto opcional. Si es null, se ajusta al contenido.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(borderRadius);
    return ClipRRect(
      borderRadius: radio,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.superficiePorcelana.withValues(alpha: fillAlpha),
            borderRadius: radio,
            border: Border.all(
              color: AppColors.superficiePorcelana.withValues(alpha: borderAlpha),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
