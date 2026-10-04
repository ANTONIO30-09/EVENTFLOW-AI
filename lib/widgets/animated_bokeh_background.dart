import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Fondo animado de destellos tipo bokeh dorado sobre azul-noche.
///
/// Diseñado para vivir detrás de todas las rutas (vía MaterialApp.builder).
/// Mezcla 22 halos grandes difuminados + 8 chispas brillantes pequeñas.
class AnimatedBokehBackground extends StatefulWidget {
  const AnimatedBokehBackground({super.key});

  @override
  State<AnimatedBokehBackground> createState() =>
      _AnimatedBokehBackgroundState();
}

class _AnimatedBokehBackgroundState extends State<AnimatedBokehBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BokehParticle> _halos;
  late final List<_BokehParticle> _sparks;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    final rng = math.Random(42);

    _halos = List.generate(22, (_) {
      return _BokehParticle(
        xFactor: rng.nextDouble(),
        yFactor: rng.nextDouble(),
        radius: 25 + rng.nextDouble() * 70,
        opacity: 0.14 + rng.nextDouble() * 0.24,
        driftX: 0.06 + rng.nextDouble() * 0.10,
        driftY: 0.04 + rng.nextDouble() * 0.08,
        phase: rng.nextDouble() * math.pi * 2,
        pulseSpeed: 0.7 + rng.nextDouble() * 1.4,
        blur: 14,
        warm: rng.nextDouble() < 0.35,
      );
    });

    _sparks = List.generate(8, (_) {
      return _BokehParticle(
        xFactor: rng.nextDouble(),
        yFactor: rng.nextDouble(),
        radius: 6 + rng.nextDouble() * 8,
        opacity: 0.55 + rng.nextDouble() * 0.35,
        driftX: 0.10 + rng.nextDouble() * 0.16,
        driftY: 0.06 + rng.nextDouble() * 0.12,
        phase: rng.nextDouble() * math.pi * 2,
        pulseSpeed: 1.2 + rng.nextDouble() * 1.8,
        blur: 4,
        warm: rng.nextDouble() < 0.5,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: AppColors.fondoAzulNoche,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _BokehPainter(
                halos: _halos,
                sparks: _sparks,
                progress: _controller.value,
                gold: AppColors.acentoBronce,
                warm: const Color(0xFFE8C98A),
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _BokehParticle {
  final double xFactor;
  final double yFactor;
  final double radius;
  final double opacity;
  final double driftX;
  final double driftY;
  final double phase;
  final double pulseSpeed;
  final double blur;
  final bool warm;

  const _BokehParticle({
    required this.xFactor,
    required this.yFactor,
    required this.radius,
    required this.opacity,
    required this.driftX,
    required this.driftY,
    required this.phase,
    required this.pulseSpeed,
    required this.blur,
    required this.warm,
  });
}

class _BokehPainter extends CustomPainter {
  final List<_BokehParticle> halos;
  final List<_BokehParticle> sparks;
  final double progress;
  final Color gold;
  final Color warm;

  _BokehPainter({
    required this.halos,
    required this.sparks,
    required this.progress,
    required this.gold,
    required this.warm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * math.pi * 2;
    _paintLayer(canvas, size, halos, t);
    _paintLayer(canvas, size, sparks, t);
  }

  void _paintLayer(
    Canvas canvas,
    Size size,
    List<_BokehParticle> particles,
    double t,
  ) {
    for (final p in particles) {
      // Deriva principal + oscilación secundaria en diagonal
      final x =
          (p.xFactor +
              math.sin(t + p.phase) * p.driftX +
              math.sin(t * 1.7 + p.phase * 0.5) * p.driftX * 0.4) *
          size.width;
      final y =
          (p.yFactor +
              math.cos(t * 0.7 + p.phase) * p.driftY +
              math.cos(t * 1.3 + p.phase * 0.5) * p.driftY * 0.4) *
          size.height;

      final pulse = 0.6 + 0.4 * math.sin(t * p.pulseSpeed + p.phase);
      final alpha = (p.opacity * pulse).clamp(0.0, 1.0);

      final color = (p.warm ? warm : gold).withValues(alpha: alpha);

      final paint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.blur);

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BokehPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
