import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bienvenido.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textDark),
              ),
              const Text(
                'Antonio Garcia.',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.1),
              ),
              const Text(
                'Personal de Campo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar Evento',
                    hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Expanded(
                child: StreamBuilder<List<EventModel>>(
                  stream: databaseService.streamEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error al cargar eventos: ${snapshot.error}'));
                    }
                    final events = snapshot.data ?? [];
                    if (events.isEmpty) {
                      return const Center(
                        child: Text(
                          'Todavía no hay eventos registrados.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
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
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFC4BDB0), Color(0xFF9E988F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Stack(
          children: [
            Positioned(left: 0, top: 15, bottom: 15, child: Container(width: 4, color: Colors.black)),
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(statusLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '${event.location} • ${event.guestCount} invitados',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12, width: 1.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(label: 'Eventos', isSelected: true, onTap: () {}),
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
          Container(
            width: 75, height: 12,
            decoration: BoxDecoration(color: isSelected ? Colors.black : const Color(0xFFB0B0B0), borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : const Color(0xFFB0B0B0))),
        ],
      ),
    );
  }
}
