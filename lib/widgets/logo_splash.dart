import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Splash de entrada con logo y confeti dorado elegante.
///
/// Secuencia:
/// 1. (0-600ms) el logo aparece con escala 0.7 → 1.0 + fade + glow bronce.
/// 2. (300-2300ms) ~60 partículas de confeti dorado caen desde arriba,
///    con sway lateral, rotación y fade in/out orgánico.
/// 3. (2300-2700ms) pausa breve y onFinished().
class LogoSplash extends StatefulWidget {
  final VoidCallback onFinished;
  const LogoSplash({super.key, required this.onFinished});

  @override
  State<LogoSplash> createState() => _LogoSplashState();
}

class _LogoSplashState extends State<LogoSplash> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _confettiController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    final rng = math.Random(7);
    for (int i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        xFactor: rng.nextDouble(),
        startDelay: rng.nextDouble() * 0.4,
        speed: 0.7 + rng.nextDouble() * 0.6,
        size: 2.5 + rng.nextDouble() * 4.0,
        swayAmp: 10 + rng.nextDouble() * 30,
        swayFreq: 1.0 + rng.nextDouble() * 2.0,
        rotation: rng.nextDouble() * math.pi * 2,
        rotationSpeed: (rng.nextDouble() - 0.5) * 6,
        isCircle: rng.nextBool(),
        opacityBase: 0.5 + rng.nextDouble() * 0.5,
      ));
    }

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _confettiController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                    color: AppColors.acentoBronce,
                  ),
                );
              },
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, _) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Capa de glow: misma imagen, difuminada y coloreada en bronce.
                        ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              AppColors.acentoBronce.withValues(alpha: 0.65),
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 160,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.blur_on,
                                    size: 120, color: AppColors.acentoBronce);
                              },
                            ),
                          ),
                        ),
                        // Logo original encima.
                        Image.asset(
                          'assets/images/logo.png',
                          height: 160,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.blur_on,
                                size: 120, color: AppColors.acentoBronce);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final double xFactor;
  final double startDelay;
  final double speed;
  final double size;
  final double swayAmp;
  final double swayFreq;
  final double rotation;
  final double rotationSpeed;
  final bool isCircle;
  final double opacityBase;

  const _ConfettiParticle({
    required this.xFactor,
    required this.startDelay,
    required this.speed,
    required this.size,
    required this.swayAmp,
    required this.swayFreq,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
    required this.opacityBase,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final Color color;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final localProgress = ((progress - p.startDelay) / (1.0 - p.startDelay))
          .clamp(0.0, 1.0);
      if (localProgress <= 0) continue;

      final y = -30 + localProgress * p.speed * (size.height + 60);
      if (y > size.height + 30) continue;

      final baseX = p.xFactor * size.width;
      final sway = math.sin(localProgress * p.swayFreq * math.pi * 2) * p.swayAmp;
      final x = baseX + sway;

      double opacity;
      if (localProgress < 0.15) {
        opacity = localProgress / 0.15;
      } else if (localProgress > 0.75) {
        opacity = (1.0 - localProgress) / 0.25;
      } else {
        opacity = 1.0;
      }
      opacity = (opacity * p.opacityBase).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      if (p.isCircle) {
        canvas.drawCircle(Offset(x, y), p.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(p.rotation + localProgress * p.rotationSpeed);
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size * 0.6, height: p.size * 1.6),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
