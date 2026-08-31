import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';
import '../guests/guest_control_screen.dart';
import '../inventory/inventory_scanner_screen.dart';
import '../profile/profile_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              event.location,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: StreamBuilder<List<GuestModel>>(
            stream: databaseService.streamGuestsForEvent(event.id),
            builder: (context, snapshot) {
              final guests = snapshot.data ?? [];
              final llegaron = guests.where((g) => g.checkedIn).length;
              final totalInvitados = event.guestCount > 0 ? event.guestCount : guests.length;
              final checkInProgress = totalInvitados > 0 ? llegaron / totalInvitados : 0.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    '${_formatDate(event.date)} - ${event.location}',
                    style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 15),

                  Center(
                    child: Text(
                      event.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('$totalInvitados', 'Invitados'),
                      _buildStatCard('$llegaron', 'Llegaron'),
                      _buildStatCard('—', 'Items'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GuestControlScreen(eventId: event.id)),
                        );
                      },
                      icon: const Icon(Icons.person_search),
                      label: const Text('Control de invitados'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'PROGRESO DEL EVENTO',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 25),

                  _buildProgressBar(
                    label: 'Check-In',
                    percentage: checkInProgress,
                    percentText: '${(checkInProgress * 100).round()}%',
                    color: const Color(0xFF0081C9),
                  ),
                  const SizedBox(height: 20),

                  _buildProgressBar(label: 'Inventario', percentage: 0, percentText: 'Pendiente', color: const Color(0xFF00C897)),
                  const SizedBox(height: 20),
                  _buildProgressBar(label: 'Montaje', percentage: 0, percentText: 'Pendiente', color: Colors.red),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  String _formatDate(DateTime date) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    final dia = dias[date.weekday - 1];
    final mes = meses[date.month - 1];
    final hora = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$dia ${date.day} $mes - $hora';
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildProgressBar({required String label, required double percentage, required String percentText, required Color color}) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: percentage, minHeight: 14, backgroundColor: Colors.black12, valueColor: AlwaysStoppedAnimation<Color>(color)),
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(width: 70, child: Text(percentText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 1.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(label: 'Eventos', isSelected: true, onTap: () => Navigator.pop(context)),
          _buildNavItem(
            label: 'Inventario',
            isSelected: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryScannerScreen()),
            ),
          ),
          _buildNavItem(
            label: 'Perfil',
            isSelected: false,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 75, height: 12, decoration: BoxDecoration(color: isSelected ? Colors.black : const Color(0xFFB0B0B0), borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : const Color(0xFFB0B0B0))),
        ],
      ),
    );
  }
}
