import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';

class CheckInSuccessScreen extends StatelessWidget {
  final GuestModel guest;
  const CheckInSuccessScreen({super.key, required this.guest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text('CHECK - IN', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Ingreso confirmado', style: TextStyle(fontSize: 18, color: Colors.black54)),
              const Text('El invitado fue registrado exitosamente', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
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
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('SIGUIENTE INVITADO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}