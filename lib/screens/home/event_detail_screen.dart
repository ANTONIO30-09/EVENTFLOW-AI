import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';
import '../guests/guest_control_screen.dart';
import '../compatibility/compatibility_rules_screen.dart';
import '../distribution/suggested_distribution_screen.dart';

import '../../widgets/neon_bottom_nav.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: GoogleFonts.inter(
                color: AppColors.acentoBronce,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              event.location,
              style: GoogleFonts.inter(
                color: AppColors.textoSecundarioGris,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
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
              final totalInvitados = event.guestCount > 0
                  ? event.guestCount
                  : guests.length;
              final checkInProgress = totalInvitados > 0
                  ? llegaron / totalInvitados
                  : 0.0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _formatDate(event.date),
                      style: GoogleFonts.inter(
                        color: AppColors.textoSecundarioGris,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        event.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.acentoBronce,
                          height: 1.1,
                        ),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GuestControlScreen(eventId: event.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_search),
                        label: const Text('Control de invitados'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.acentoBronce,
                          foregroundColor: AppColors.fondoAzulNoche,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CompatibilityRulesScreen(
                                    eventId: event.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.rule, size: 18),
                            label: const Text('Reglas'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.acentoBronce,
                              side: const BorderSide(
                                color: AppColors.acentoBronce,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SuggestedDistributionScreen(
                                    eventId: event.id,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.table_restaurant, size: 18),
                            label: const Text('Distribución'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.acentoBronce,
                              side: const BorderSide(
                                color: AppColors.acentoBronce,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'PROGRESO DEL EVENTO',
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.acentoBronce,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProgressBar(
                      label: 'Check-In',
                      percentage: checkInProgress,
                      percentText: '${(checkInProgress * 100).round()}%',
                      color: AppColors.exitoVerdeSalvia,
                    ),
                    const SizedBox(height: 20),
                    _buildProgressBar(
                      label: 'Inventario',
                      percentage: 0,
                      percentText: 'Pendiente',
                      color: AppColors.textoSecundarioGris,
                    ),
                    const SizedBox(height: 20),
                    _buildProgressBar(
                      label: 'Montaje',
                      percentage: 0,
                      percentText: 'Pendiente',
                      color: AppColors.textoSecundarioGris,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  String _formatDate(DateTime date) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    final dia = dias[date.weekday - 1];
    final mes = meses[date.month - 1];
    final hora =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$dia ${date.day} $mes - $hora';
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.superficiePorcelana,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.fondoAzulNoche,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textoSecundarioGris,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double percentage,
    required String percentText,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.superficiePorcelana,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: AppColors.superficiePorcelana.withValues(
                alpha: 0.15,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 70,
          child: Text(
            percentText,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.superficiePorcelana,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return const NeonBottomNav(currentIndex: 0);
  }
}
