import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';
import '../check_in/check_in_success_screen.dart';

class GuestControlScreen extends StatefulWidget {
  final String eventId;
  const GuestControlScreen({super.key, required this.eventId});

  @override
  State<GuestControlScreen> createState() => _GuestControlScreenState();
}

class _GuestControlScreenState extends State<GuestControlScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  String _filter = 'todos';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
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
      body: StreamBuilder<List<GuestModel>>(
        stream: _databaseService.streamGuestsForEvent(widget.eventId),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _filterButton('Todos ($total)', 'todos'),
                        const SizedBox(width: 8),
                        _filterButton('Ingresados ($ingresados)', 'ingresados'),
                        const SizedBox(width: 8),
                        _filterButton('Pendientes ($pendientes)', 'pendientes'),
                      ],
                    ),
                  ],
                ),
              ),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildNavItem('Eventos', false, () => Navigator.pop(context)),
        _buildNavItem('Inventario', false, () => Navigator.pushReplacementNamed(context, '/inventory')),
        _buildNavItem('Perfil', true, () => Navigator.pushReplacementNamed(context, '/profile')),
      ]),
    );
  }

  Widget _buildNavItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 75, height: 12, decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey.shade300, borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey.shade400)),
      ]),
    );
  }
}
