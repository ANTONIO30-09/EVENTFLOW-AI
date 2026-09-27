import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Widget animado de check-in.
///
/// Fases:
/// 1. (0-600ms) el check se dibuja de abajo hacia arriba.
/// 2. (600-1200ms) el círculo se dibuja alrededor.
/// 3. (1200-1500ms) el resto del contenido aparece con fade (lo maneja el padre).
class AnimatedCheck extends StatefulWidget {
  final double size;
  final Color color;
  final VoidCallback? onComplete;

  const AnimatedCheck({
    super.key,
    this.size = 120,
    this.color = AppColors.acentoBronce,
    this.onComplete,
  });

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkProgress;
  late final Animation<double> _circleProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );
    _circleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward().then((_) {
      if (widget.onComplete != null) widget.onComplete!();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _CheckPainter(
              checkProgress: _checkProgress.value,
              circleProgress: _circleProgress.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double checkProgress;
  final double circleProgress;
  final Color color;

  _CheckPainter({
    required this.checkProgress,
    required this.circleProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = size.width * 0.07;

    // Círculo (fase 2)
    if (circleProgress > 0) {
      final circlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * circleProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        circlePaint,
      );
    }

    // Check (fase 1)
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Puntos del check (en proporciones al tamaño)
      final p1 = Offset(size.width * 0.30, size.height * 0.52);
      final p2 = Offset(size.width * 0.45, size.height * 0.67);
      final p3 = Offset(size.width * 0.72, size.height * 0.38);

      // Longitudes totales del path
      final len1 = (p2 - p1).distance;
      final len2 = (p3 - p2).distance;
      final totalLen = len1 + len2;

      // Punto actual según progreso
      final drawnLen = totalLen * checkProgress;

      final path = Path()..moveTo(p1.dx, p1.dy);
      if (drawnLen <= len1) {
        final t = drawnLen / len1;
        path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
      } else {
        path.lineTo(p2.dx, p2.dy);
        final t = (drawnLen - len1) / len2;
        path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.checkProgress != checkProgress ||
        oldDelegate.circleProgress != circleProgress ||
        oldDelegate.color != color;
  }
}
