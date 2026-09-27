import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Pantalla de splash con logo animado.
///
/// Secuencia:
/// 1. (0-400ms) el logo aparece con escala 0.6 → 1.0 + fade.
/// 2. (400-1000ms) brotan 12 chispas doradas desde el centro.
/// 3. (1000-1500ms) pausa breve.
/// 4. Llama a onFinished().
class LogoSplash extends StatefulWidget {
  final VoidCallback onFinished;
  const LogoSplash({super.key, required this.onFinished});

  @override
  State<LogoSplash> createState() => _LogoSplashState();
}

class _LogoSplashState extends State<LogoSplash> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _sparkController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  final List<_Spark> _sparks = [];

  @override
  void initState() {
    super.initState();

    final rng = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final distance = 60 + rng.nextDouble() * 50;
      final size = 2.5 + rng.nextDouble() * 3.5;
      _sparks.add(_Spark(angle: angle, distance: distance, size: size));
    }

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _logoController.forward();
    await _sparkController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _sparkController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(300, 300),
                  painter: _SparkPainter(
                    sparks: _sparks,
                    progress: _sparkController.value,
                    color: AppColors.acentoBronce,
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, _) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 160,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.blur_on,
                            size: 120, color: AppColors.acentoBronce);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Spark {
  final double angle;
  final double distance;
  final double size;
  const _Spark({
    required this.angle,
    required this.distance,
    required this.size,
  });
}

class _SparkPainter extends CustomPainter {
  final List<_Spark> sparks;
  final double progress;
  final Color color;

  _SparkPainter({
    required this.sparks,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final spark in sparks) {
      final currentDistance = spark.distance * progress;
      final dx = math.cos(spark.angle) * currentDistance;
      final dy = math.sin(spark.angle) * currentDistance;
      final pos = Offset(center.dx + dx, center.dy + dy);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, spark.size * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
