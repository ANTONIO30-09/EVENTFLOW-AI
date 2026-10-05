import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../screens/inventory/inventory_scanner_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Bottom navigation flotante con efecto glass + glow dorado + onda blanca.
///
/// El estado de selección se deriva SIEMPRE de [currentIndex], sin estado
/// local de selección — así al volver a una pantalla el glow refleja el tab
/// correcto sin quedar pegado en la selección anterior.
class NeonBottomNav extends StatefulWidget {
  final int currentIndex;
  const NeonBottomNav({super.key, required this.currentIndex});

  @override
  State<NeonBottomNav> createState() => _NeonBottomNavState();
}

class _NeonBottomNavState extends State<NeonBottomNav>
    with SingleTickerProviderStateMixin {
  int? _waveIndex;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _waveController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _waveIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;

    setState(() => _waveIndex = index);
    _waveController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      if (index == 0) {
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
        final target = index == 1
            ? const InventoryScannerScreen()
            : const ProfileScreen();
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, animation, secondaryAnimation) => target,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fondoAzulNoche.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppColors.superficiePorcelana.withValues(alpha: 0.16),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _buildItem(index: 0, icon: Icons.event, label: 'Eventos'),
                  _buildItem(
                    index: 1,
                    icon: Icons.qr_code_scanner,
                    label: 'Inventario',
                  ),
                  _buildItem(index: 2, icon: Icons.person, label: 'Perfil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = widget.currentIndex == index;
    final showWave = _waveIndex == index;
    const glowOn = Color(0xCCB8863E);
    const glowSoft = Color(0x40B8863E);

    final iconColor = selected
        ? AppColors.acentoBronce
        : AppColors.superficiePorcelana.withValues(alpha: 0.7);
    final labelColor = selected
        ? AppColors.acentoBronce
        : AppColors.superficiePorcelana.withValues(alpha: 0.65);

    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(index),
        borderRadius: BorderRadius.circular(28),
        splashColor: AppColors.acentoBronce.withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.acentoBronce.withValues(alpha: 0.12)
                            : Colors.transparent,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: glowOn,
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: glowSoft,
                                  blurRadius: 26,
                                  spreadRadius: 3,
                                ),
                              ]
                            : const [],
                      ),
                    ),
                    if (showWave)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(44, 44),
                            painter: _WavePainter(_waveController.value),
                          );
                        },
                      ),
                    Icon(icon, size: 22, color: iconColor),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onda blanca que se expande desde el centro y se desvanece.
class _WavePainter extends CustomPainter {
  final double progress;
  _WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final radius = 8 + (maxRadius - 8) * progress;
    final opacity = ((1 - progress).clamp(0.0, 1.0)) * 0.55;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.progress != progress;
}
