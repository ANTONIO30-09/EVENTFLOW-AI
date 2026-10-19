import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../widgets/animated_check.dart';
import '../../widgets/glass_card.dart';

class CheckInSuccessScreen extends StatefulWidget {
  final GuestModel guest;
  const CheckInSuccessScreen({super.key, required this.guest});

  @override
  State<CheckInSuccessScreen> createState() => _CheckInSuccessScreenState();
}

class _CheckInSuccessScreenState extends State<CheckInSuccessScreen> {
  bool _showContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedCheck(
                        size: 140,
                        color: AppColors.acentoBronce,
                        onComplete: () {
                          if (mounted) setState(() => _showContent = true);
                        },
                      ),
                      const SizedBox(height: 24),
                      AnimatedOpacity(
                        opacity: _showContent ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            Text(
                              'CHECK - IN',
                              style: GoogleFonts.fraunces(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.acentoBronce,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ingreso confirmado',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.superficiePorcelana,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'El invitado fue registrado exitosamente',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.superficiePorcelana
                                    .withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedOpacity(
                        opacity: _showContent ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GlassCard(
                          child: Column(
                            children: [
                              _infoRow('Nombre', widget.guest.name),
                              Divider(
                                color: AppColors.superficiePorcelana
                                    .withValues(alpha: 0.15),
                              ),
                              _infoRow('Ubicación', widget.guest.tableNumber),
                              Divider(
                                color: AppColors.superficiePorcelana
                                    .withValues(alpha: 0.15),
                              ),
                              _infoRow('Grupo', widget.guest.familyGroup),
                              Divider(
                                color: AppColors.superficiePorcelana
                                    .withValues(alpha: 0.15),
                              ),
                              _infoRow(
                                'Acompañante',
                                '+${widget.guest.companions}',
                              ),
                              Divider(
                                color: AppColors.superficiePorcelana
                                    .withValues(alpha: 0.15),
                              ),
                              _infoRow(
                                'Ingreso',
                                widget.guest.checkInTime != null
                                    ? widget.guest.checkInTime!
                                        .toString()
                                        .substring(11, 19)
                                    : '--:--:--',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedOpacity(
                        opacity: _showContent ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.acentoBronce,
                              foregroundColor: AppColors.fondoAzulNoche,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'SIGUIENTE INVITADO',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.superficiePorcelana,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.superficiePorcelana.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
