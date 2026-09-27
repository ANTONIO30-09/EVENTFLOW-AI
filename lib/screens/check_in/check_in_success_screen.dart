import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';

class CheckInSuccessScreen extends StatelessWidget {
  final GuestModel guest;
  const CheckInSuccessScreen({super.key, required this.guest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.exitoVerdeSalvia, size: 80),
              const SizedBox(height: 20),
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
                  fontSize: 16,
                  color: AppColors.textoSecundarioGris,
                ),
              ),
              Text(
                'El invitado fue registrado exitosamente',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textoSecundarioGris,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.superficiePorcelana,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _infoRow('Nombre', guest.name),
                    const Divider(),
                    _infoRow('Ubicación', guest.tableNumber),
                    const Divider(),
                    _infoRow('Grupo', guest.familyGroup),
                    const Divider(),
                    _infoRow('Acompañante', '+${guest.companions}'),
                    const Divider(),
                    _infoRow('Ingreso', guest.checkInTime != null
                        ? guest.checkInTime!.toString().substring(11, 19)
                        : '--:--:--'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.acentoBronce,
                    foregroundColor: AppColors.fondoAzulNoche,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
            ],
          ),
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
              color: AppColors.fondoAzulNoche,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.textoSecundarioGris,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
