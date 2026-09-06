import 'package:flutter/material.dart';
import '../../data/services/database_service.dart';
import '../../data/services/seating_service.dart';
import '../../data/services/ai_explanation_service.dart';

class SuggestedDistributionScreen extends StatefulWidget {
  final String eventId;
  const SuggestedDistributionScreen({super.key, required this.eventId});

  @override
  State<SuggestedDistributionScreen> createState() =>
      _SuggestedDistributionScreenState();
}

class _SuggestedDistributionScreenState
    extends State<SuggestedDistributionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final SeatingService _seatingService = SeatingService();
  final AiExplanationService _aiExplanationService = AiExplanationService();

  bool _loading = true;
  DistributionResult? _distribution;
  String? _error;
  bool _explanationLoading = false;
  String? _explanation;

  @override
  void initState() {
    super.initState();
    _loadDistribution();
  }

  Future<void> _loadDistribution() async {
    setState(() {
      _loading = true;
      _error = null;
      _explanation = null;
    });

    try {
      final guests = await _databaseService.fetchGuestsForEvent(widget.eventId);
      final tables = await _databaseService.fetchTablesForEvent(widget.eventId);
      final rules = await _databaseService.fetchCompatibilityRulesForEvent(widget.eventId);

      final result = _seatingService.generateDistribution(
        guests: guests,
        tables: tables,
        rules: rules,
      );

      if (!mounted) return;
      setState(() {
        _distribution = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al generar la distribución: $e';
        _loading = false;
      });
    }
  }

  Future<void> _generateExplanation() async {
    final distribution = _distribution;
    if (distribution == null) return;

    setState(() => _explanationLoading = true);
    final text = await _aiExplanationService.generateExplanation(distribution);
    if (!mounted) return;
    setState(() {
      _explanation = text;
      _explanationLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribución Sugerida')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final distribution = _distribution!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (distribution.warning != null)
          Text(
            distribution.warning!,
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        ...distribution.assignments.map((assignment) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.tableName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (assignment.guests.isEmpty)
                    const Text('Sin invitados asignados',
                        style: TextStyle(color: Colors.grey))
                  else
                    ...assignment.guests.map((guest) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 8),
                              Text(guest),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          );
        }),
        if (distribution.unassignedGuests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sin asignar: ${distribution.unassignedGuests.join(', ')}',
              style: const TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 16),
        if (_explanationLoading)
          const Center(child: CircularProgressIndicator())
        else if (_explanation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_explanation!),
          )
        else
          ElevatedButton.icon(
            onPressed: _generateExplanation,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Explicar distribución'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}
