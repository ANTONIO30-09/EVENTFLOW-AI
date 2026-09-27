import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';
import '../inventory/inventory_scanner_screen.dart';
import '../profile/profile_screen.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textoSecundarioGris,
                ),
              ),
              Text(
                'Antonio Garcia.',
                style: GoogleFonts.fraunces(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.acentoBronce,
                  height: 1.1,
                ),
              ),
              Text(
                'Personal de Campo',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textoSecundarioGris,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.superficiePorcelana,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  style: GoogleFonts.inter(color: AppColors.fondoAzulNoche, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Buscar evento',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textoSecundarioGris,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    suffixIcon: const Icon(Icons.search, color: AppColors.fondoAzulNoche),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: StreamBuilder<List<EventModel>>(
                  stream: databaseService.streamEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.acentoBronce));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar eventos',
                          style: GoogleFonts.inter(color: AppColors.alertaLadrillo),
                        ),
                      );
                    }
                    final events = snapshot.data ?? [];
                    if (events.isEmpty) {
                      return Center(
                        child: Text(
                          'Todavía no hay eventos registrados.',
                          style: GoogleFonts.inter(
                            color: AppColors.textoSecundarioGris,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _buildEventCard(event: event, context: context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildEventCard({required EventModel event, required BuildContext context}) {
    final statusLabel = switch (event.status) {
      'en_curso' => 'En curso',
      'finalizado' => 'Finalizado',
      _ => 'Próximo',
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.superficiePorcelana,
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(color: AppColors.acentoBronce, width: 4),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fondoAzulNoche,
                      height: 1.1,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: event.status == 'en_curso'
                            ? AppColors.exitoVerdeSalvia
                            : AppColors.textoSecundarioGris,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: event.status == 'en_curso'
                            ? AppColors.exitoVerdeSalvia
                            : AppColors.textoSecundarioGris,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<GuestModel>>(
              stream: DatabaseService().streamGuestsForEvent(event.id),
              builder: (context, snapshot) {
                final count = snapshot.hasData
                    ? snapshot.data!.length
                    : event.guestCount;
                return Text(
                  '${event.location} • $count invitados',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textoSecundarioGris,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryScannerScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
