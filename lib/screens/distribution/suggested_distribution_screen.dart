import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';

class SuggestedDistributionScreen extends StatelessWidget {
  final String eventId;
  const SuggestedDistributionScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Distribución Sugerida'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<GuestModel>>(
        stream: databaseService.streamGuestsForEvent(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final guests = snapshot.data ?? [];
          if (guests.isEmpty) {
            return const Center(child: Text('No hay invitados para distribuir.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: guests.length,
            itemBuilder: (context, index) {
              final guest = guests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(guest.name),
                  subtitle: Text('Mesa asignada: ${guest.tableNumber}'),
                  leading: const Icon(Icons.table_restaurant),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
