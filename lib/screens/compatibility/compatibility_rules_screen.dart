import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/compatibility_rule_model.dart';
import '../../data/services/database_service.dart';

class CompatibilityRulesScreen extends StatefulWidget {
  final String eventId;
  const CompatibilityRulesScreen({super.key, required this.eventId});

  @override
  State<CompatibilityRulesScreen> createState() => _CompatibilityRulesScreenState();
}

class _CompatibilityRulesScreenState extends State<CompatibilityRulesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _guestAController = TextEditingController();
  final TextEditingController _guestBController = TextEditingController();
  String _ruleType = 'forbid';

  Future<void> _addRule() async {
    final nameA = _guestAController.text.trim();
    final nameB = _guestBController.text.trim();
    if (nameA.isEmpty || nameB.isEmpty) return;

    final rule = CompatibilityRule(
      id: '',
      eventId: widget.eventId,
      guestA: nameA,
      guestB: nameB,
      ruleType: _ruleType,
    );

    await _databaseService.addCompatibilityRule(rule);
    if (!mounted) return;
    _guestAController.clear();
    _guestBController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Regla agregada correctamente')),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva regla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _guestAController,
              decoration: const InputDecoration(
                labelText: 'Invitado A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _guestBController,
              decoration: const InputDecoration(
                labelText: 'Invitado B',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _ruleType,
              items: const [
                DropdownMenuItem(value: 'forbid', child: Text('No sentar juntos')),
                DropdownMenuItem(value: 'prefer', child: Text('Sentar juntos')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _ruleType = value);
              },
              decoration: const InputDecoration(
                labelText: 'Tipo de regla',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addRule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('AGREGAR REGLA'),
            ),
            const SizedBox(height: 24),
            const Text('Reglas del evento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<CompatibilityRule>>(
                stream: _databaseService.streamCompatibilityRulesForEvent(widget.eventId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rules = snapshot.data ?? [];
                  if (rules.isEmpty) {
                    return const Center(child: Text('No hay reglas cargadas.'));
                  }
                  return ListView.builder(
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      return Card(
                        child: ListTile(
                          title: Text('${rule.guestA} - ${rule.guestB}'),
                          subtitle: Text(rule.ruleType == 'forbid' ? 'No sentar juntos' : 'Sentar juntos'),
                          leading: Icon(
                            rule.ruleType == 'forbid' ? Icons.block : Icons.favorite,
                            color: rule.ruleType == 'forbid' ? Colors.red : Colors.green,
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
      ),
    );
  }
}
