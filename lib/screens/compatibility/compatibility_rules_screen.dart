import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/compatibility_rule_model.dart';
import '../../data/models/guest_model.dart';
import '../../data/services/database_service.dart';

class CompatibilityRulesScreen extends StatefulWidget {
  final String eventId;
  const CompatibilityRulesScreen({super.key, required this.eventId});

  @override
  State<CompatibilityRulesScreen> createState() => _CompatibilityRulesScreenState();
}

class _CompatibilityRulesScreenState extends State<CompatibilityRulesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String? _guestA;
  String? _guestB;
  String _ruleType = 'forbid';

  Future<void> _addRule() async {
    if (_guestA == null || _guestB == null) return;
    if (_guestA == _guestB) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elegí dos invitados distintos')),
      );
      return;
    }
    final rule = CompatibilityRule(
      id: '',
      eventId: widget.eventId,
      guestA: _guestA!,
      guestB: _guestB!,
      ruleType: _ruleType,
    );
    await _databaseService.addCompatibilityRule(rule);
    if (!mounted) return;
    setState(() {
      _guestA = null;
      _guestB = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Regla agregada')),
    );
  }

  Future<void> _deleteRule(String ruleId) async {
    await _databaseService.deleteCompatibilityRule(ruleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reglas de Compatibilidad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<GuestModel>>(
        stream: _databaseService.streamGuestsForEvent(widget.eventId),
        builder: (context, guestSnap) {
          final guests = guestSnap.data ?? [];
          String labelFor(GuestModel g) {
            final mesa = g.tableNumber.isEmpty ? 'sin mesa' : g.tableNumber;
            return '${g.name} — $mesa';
          }
          final labelToName = <String, String>{
            for (final g in guests) labelFor(g): g.name
          };
          final labels = labelToName.keys.toList();
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nueva regla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _guestA == null ? null : labels.firstWhere((l) => labelToName[l] == _guestA, orElse: () => labels.first),
                  isExpanded: true,
                  items: labels.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _guestA = v == null ? null : labelToName[v]),
                  decoration: const InputDecoration(labelText: 'Invitado A', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _guestB == null ? null : labels.firstWhere((l) => labelToName[l] == _guestB, orElse: () => labels.first),
                  isExpanded: true,
                  items: labels.map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setState(() => _guestB = v == null ? null : labelToName[v]),
                  decoration: const InputDecoration(labelText: 'Invitado B', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _ruleType,
                  items: const [
                    DropdownMenuItem(value: 'forbid', child: Text('No sentar juntos')),
                    DropdownMenuItem(value: 'prefer', child: Text('Sentar juntos')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _ruleType = v); },
                  decoration: const InputDecoration(labelText: 'Tipo de regla', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addRule,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text('AGREGAR REGLA'),
                ),
                const SizedBox(height: 24),
                const Text('Reglas del evento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<CompatibilityRule>>(
                    stream: _databaseService.streamCompatibilityRulesForEvent(widget.eventId),
                    builder: (context, ruleSnap) {
                      final rules = ruleSnap.data ?? [];
                      if (rules.isEmpty) return const Center(child: Text('No hay reglas cargadas.'));
                      return ListView.builder(
                        itemCount: rules.length,
                        itemBuilder: (context, i) {
                          final rule = rules[i];
                          return Card(
                            child: ListTile(
                              title: Text('${rule.guestA} - ${rule.guestB}'),
                              subtitle: Text(rule.ruleType == 'forbid' ? 'No sentar juntos' : 'Sentar juntos'),
                              leading: Icon(
                                rule.ruleType == 'forbid' ? Icons.block : Icons.favorite,
                                color: rule.ruleType == 'forbid' ? Colors.red : Colors.green,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRule(rule.id),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
