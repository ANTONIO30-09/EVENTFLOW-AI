import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';
import '../check_in/check_in_success_screen.dart';
import '../inventory/inventory_scanner_screen.dart';
import '../profile/profile_screen.dart';

class GuestControlScreen extends StatefulWidget {
  final String eventId;
  const GuestControlScreen({super.key, required this.eventId});

  @override
  State<GuestControlScreen> createState() => _GuestControlScreenState();
}

class _GuestControlScreenState extends State<GuestControlScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<GuestModel>> _guestsStream;

  String _filter = 'todos';

  @override
  void initState() {
    super.initState();
    _guestsStream = _databaseService.streamGuestsForEvent(widget.eventId);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _updateFilter(String filter) {
    setState(() => _filter = filter);
  }

  Future<void> _checkInGuest(GuestModel guest) async {
    final updatedGuest = guest.markCheckedIn();
    await _databaseService.checkInGuest(guest);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckInSuccessScreen(guest: updatedGuest)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Control de Invitados', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<GuestModel>>(
              stream: _guestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar invitados: ${snapshot.error}'),
                  );
                }

                final guests = snapshot.data ?? [];
                final query = _searchController.text.toLowerCase();
                final filteredGuests = guests.where((guest) {
                  final matchesSearch = guest.name.toLowerCase().contains(query);
                  final matchesFilter = _filter == 'todos' ||
                      (_filter == 'ingresados' && guest.checkedIn) ||
                      (_filter == 'pendientes' && !guest.checkedIn);
                  return matchesSearch && matchesFilter;
                }).toList();

                final total = guests.length;
                final ingresados = guests.where((g) => g.checkedIn).length;
                final pendientes = total - ingresados;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _filterButton('Todos ($total)', 'todos'),
                          const SizedBox(width: 8),
                          _filterButton('Ingresados ($ingresados)', 'ingresados'),
                          const SizedBox(width: 8),
                          _filterButton('Pendientes ($pendientes)', 'pendientes'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredGuests.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay invitados para los filtros seleccionados.',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredGuests.length,
                              itemBuilder: (context, index) {
                                final guest = filteredGuests[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    title: Text(guest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${guest.tableNumber} • ${guest.familyGroup} • +${guest.companions} acompañante${guest.companions != 1 ? 's' : ''}'),
                                    trailing: guest.checkedIn
                                        ? const Icon(Icons.check_circle, color: Colors.green)
                                        : TextButton(
                                            onPressed: () => _checkInGuest(guest),
                                            style: TextButton.styleFrom(foregroundColor: Colors.black),
                                            child: const Text('Check-in'),
                                          ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _filterButton(String label, String filterValue) {
    final isSelected = _filter == filterValue;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _updateFilter(filterValue),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.black : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.surfaceCard,
      currentIndex: 0,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
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
