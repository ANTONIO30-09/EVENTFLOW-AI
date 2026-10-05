import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';
import '../check_in/check_in_success_screen.dart';

import '../../widgets/neon_bottom_nav.dart';

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
      MaterialPageRoute(
        builder: (_) => CheckInSuccessScreen(guest: updatedGuest),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      appBar: AppBar(title: const Text('Control de Invitados')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.superficiePorcelana,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  color: AppColors.fondoAzulNoche,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textoSecundarioGris,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.fondoAzulNoche,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<GuestModel>>(
              stream: _guestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.acentoBronce,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar invitados',
                      style: GoogleFonts.inter(color: AppColors.alertaLadrillo),
                    ),
                  );
                }

                final guests = snapshot.data ?? [];
                final query = _searchController.text.toLowerCase();
                final filteredGuests = guests.where((guest) {
                  final matchesSearch = guest.name.toLowerCase().contains(
                    query,
                  );
                  final matchesFilter =
                      _filter == 'todos' ||
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
                          _filterButton(
                            'Ingresados ($ingresados)',
                            'ingresados',
                          ),
                          const SizedBox(width: 8),
                          _filterButton(
                            'Pendientes ($pendientes)',
                            'pendientes',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredGuests.isEmpty
                          ? Center(
                              child: Text(
                                'No hay invitados para los filtros seleccionados.',
                                style: GoogleFonts.inter(
                                  color: AppColors.textoSecundarioGris,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: filteredGuests.length,
                              itemBuilder: (context, index) {
                                final guest = filteredGuests[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.superficiePorcelana,
                                    borderRadius: BorderRadius.circular(8),
                                    border: const Border(
                                      left: BorderSide(
                                        color: AppColors.acentoBronce,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              guest.name,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.fondoAzulNoche,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${guest.tableNumber} • ${guest.familyGroup} • +${guest.companions} acompañante${guest.companions != 1 ? 's' : ''}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors
                                                    .textoSecundarioGris,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      guest.checkedIn
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: AppColors.exitoVerdeSalvia,
                                              size: 26,
                                            )
                                          : TextButton(
                                              onPressed: () =>
                                                  _checkInGuest(guest),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.fondoAzulNoche,
                                                backgroundColor:
                                                    AppColors.acentoBronce,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 6,
                                                    ),
                                              ),
                                              child: Text(
                                                'Check-in',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                    ],
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
          backgroundColor: isSelected
              ? AppColors.acentoBronce
              : Colors.transparent,
          foregroundColor: isSelected
              ? AppColors.fondoAzulNoche
              : AppColors.acentoBronce,
          side: const BorderSide(color: AppColors.acentoBronce),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return const NeonBottomNav(currentIndex: 0);
  }
}
