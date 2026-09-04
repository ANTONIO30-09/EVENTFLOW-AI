import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SuggestedDistributionScreen extends StatefulWidget {
  final String eventId;
  const SuggestedDistributionScreen({super.key, required this.eventId});

  @override
  State<SuggestedDistributionScreen> createState() => _SuggestedDistributionScreenState();
}

class _SuggestedDistributionScreenState extends State<SuggestedDistributionScreen> {
  static const List<Map<String, String>> demoGuests = [
    {'name': 'Juan Pérez', 'table': 'Mesa 1'},
    {'name': 'María López', 'table': 'Mesa 1'},
    {'name': 'Carlos García', 'table': 'Mesa 2'},
    {'name': 'Lucía Fernández', 'table': 'Mesa 2'},
    {'name': 'Pedro Ramírez', 'table': 'Mesa 3'},
    {'name': 'Ana Martínez', 'table': 'Mesa 3'},
  ];

  @override
  Widget build(BuildContext context) {
    final tables = <String, List<String>>{};
    for (final guest in demoGuests) {
      final table = guest['table']!;
      tables.putIfAbsent(table, () => []).add(guest['name']!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Distribución Sugerida'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Propuesta de mesas (datos de prueba)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: tables.entries.map((entry) {
                  final tableName = entry.key;
                  final guests = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tableName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...guests.map((guest) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 18, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Text(guest, style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
