import 'package:flutter/material.dart';
import '../../data/models/guest_model.dart';
import '../../data/models/seating_table_model.dart';
import '../../data/models/compatibility_rule_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/seating_service.dart';
import '../../data/services/ai_explanation_service.dart';

class SuggestedDistributionScreen extends StatefulWidget {
  final String eventId;
  const SuggestedDistributionScreen({super.key, required this.eventId});
  @override
  State<SuggestedDistributionScreen> createState() => _State();
}

class _State extends State<SuggestedDistributionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final SeatingService _seatingService = SeatingService();
  final AiExplanationService _aiService = AiExplanationService();

  bool _loading = true;
  String? _error;
  DistributionResult? _distribution;
  bool _approved = false;
  bool _explanationLoading = false;
  String? _explanation;
  List<SeatingTable> _tables = [];
  List<CompatibilityRule> _rules = [];

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
      final event = await _databaseService.fetchEventById(widget.eventId);
      final approved = event?.distributionApproved ?? false;
      final result = approved
          ? _seatingService.fromCurrentAssignments(guests: guests, tables: tables)
          : _seatingService.generateDistribution(guests: guests, tables: tables, rules: rules);
      if (!mounted) return;
      setState(() {
        _distribution = result;
        _tables = tables;
        _rules = rules;
        _approved = approved;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  Future<void> _reloadFromCurrent() async {
    try {
      final guests = await _databaseService.fetchGuestsForEvent(widget.eventId);
      final current = _seatingService.fromCurrentAssignments(guests: guests, tables: _tables);
      if (!mounted) return;
      setState(() { _distribution = current; _explanation = null; });
    } catch (_) {}
  }

  Future<void> _regenerate() async {
    if (_approved) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Regenerar distribución'),
          content: const Text('Esto descarta los cambios manuales y la aprobación. ¿Continuar?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Regenerar')),
          ],
        ),
      );
      if (confirm != true) return;
      await _databaseService.unapproveDistribution(widget.eventId);
    }
    await _loadDistribution();
  }

  Future<void> _generateExplanation() async {
    final dist = _distribution;
    if (dist == null) return;
    setState(() { _explanationLoading = true; _explanation = null; });
    final text = await _aiService.generateExplanation(dist);
    if (!mounted) return;
    setState(() { _explanation = text; _explanationLoading = false; });
  }

  Future<void> _approve() async {
    final dist = _distribution;
    if (dist == null) return;
    final guests = await _databaseService.fetchGuestsForEvent(widget.eventId);
    final byName = {for (final g in guests) g.name: g};

    for (final a in dist.assignments) {
      for (final name in a.guests) {
        final guest = byName[name];
        if (guest != null) {
          await _databaseService.updateGuestTable(guest.id, a.tableName);
        }
      }
    }

    for (final name in dist.unassignedGuests) {
      final guest = byName[name];
      if (guest != null) {
        await _databaseService.updateGuestTable(guest.id, '');
      }
    }

    await _databaseService.approveDistribution(widget.eventId);
    if (!mounted) return;
    setState(() { _approved = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Distribución aprobada')),
    );
  }

  Future<void> _openMoveDialog(String guestName, String originTable) async {
    final guests = await _databaseService.fetchGuestsForEvent(widget.eventId);
    final guest = guests.firstWhere((g) => g.name == guestName, orElse: () => guests.first);
    final destTables = _tables.where((t) => t.name != originTable).toList();
    if (destTables.isEmpty) return;
    final dist = _distribution!;
    String? dest = destTables.first.name;
    bool moveFamily = false;
    final familyMembers = guests.where((g) => g.familyGroup.isNotEmpty && g.familyGroup == guest.familyGroup && g.tableNumber == originTable && g.name != guest.name).toList();
    final hasFamily = familyMembers.isNotEmpty;

    if (!mounted) return;
    await showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setDlg) {
        return AlertDialog(
          title: Text('Mover a $guestName'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: dest,
              items: destTables.map((t) {
                final assigned = dist.assignments.firstWhere((a) => a.tableName == t.name, orElse: () => TableAssignment(tableName: t.name, guests: const [])).guests.length;
                return DropdownMenuItem(value: t.name, child: Text('${t.name} ($assigned/${t.capacity})'));
              }).toList(),
              onChanged: (v) => setDlg(() => dest = v),
              decoration: const InputDecoration(labelText: 'Mesa destino'),
            ),
            if (hasFamily) SwitchListTile(
              value: moveFamily,
              onChanged: (v) => setDlg(() => moveFamily = v),
              title: Text('Mover también a ${familyMembers.length} de ${guest.familyGroup}'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () { Navigator.pop(ctx, {'dest': dest, 'family': moveFamily, 'members': familyMembers}); }, child: const Text('Mover')),
          ],
        );
      });
    }).then((result) async {
      if (result == null) return;
      await _applyMove(guest, result['dest'] as String, result['family'] as bool, result['members'] as List<GuestModel>);
    });
  }

  Future<void> _applyMove(GuestModel guest, String dest, bool moveFamily, List<GuestModel> familyMembers) async {
    final toMove = <GuestModel>[guest];
    if (moveFamily) toMove.addAll(familyMembers);
    final error = _validateMove(toMove: toMove, dest: dest);
    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      return;
    }
    for (final g in toMove) {
      await _databaseService.updateGuestTable(g.id, dest);
    }
    await _databaseService.unapproveDistribution(widget.eventId);
    await _reloadFromCurrent();
    if (!mounted) return;
    setState(() { _approved = false; });
  }

  String? _validateMove({required List<GuestModel> toMove, required String dest}) {
    final dist = _distribution;
    if (dist == null) return null;
    final destTable = _tables.firstWhere((t) => t.name == dest);
    final destAssignment = dist.assignments.firstWhere((a) => a.tableName == dest, orElse: () => const TableAssignment(tableName: '', guests: []));
    final ocupadas = destAssignment.guests.length;
    if (ocupadas + toMove.length > destTable.capacity) {
      final libres = destTable.capacity - ocupadas;
      final faltan = toMove.length - libres;
      if (libres <= 0) {
        return 'La mesa $dest ya está llena ($ocupadas/${destTable.capacity}). Hacen falta $faltan sillas más.';
      }
      return 'La mesa $dest tiene $libres sillas libres, pero se intentan mover ${toMove.length} personas (faltan $faltan sillas).';
    }

    for (final moving in toMove) {
      for (final rule in _rules) {
        if (rule.ruleType != 'forbid') continue;
        String? other;
        if (rule.guestA == moving.name) other = rule.guestB;
        if (rule.guestB == moving.name) other = rule.guestA;
        if (other == null) continue;
        if (destAssignment.guests.contains(other) && !toMove.any((g) => g.name == other)) {
          return 'No se puede mover a ${moving.name}: tiene regla "no sentar juntos" con $other, quien ya está en $dest';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!)));
    final dist = _distribution!;
    return Scaffold(
      appBar: AppBar(title: const Text('Distribución Sugerida')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusBanner(),
          if (dist.warning != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(dist.warning!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),

          ...dist.assignments.map((a) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.tableName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (a.guests.isEmpty) const Text('Sin invitados asignados', style: TextStyle(color: Colors.grey))
                    else ...a.guests.map((g) => InkWell(
                      onTap: () => _openMoveDialog(g, a.tableName),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(children: [
                          const Icon(Icons.person, size: 18, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(child: Text(g)),
                          const Icon(Icons.edit, size: 16, color: Colors.black38),
                        ]),
                      ),
                    )),
                  ],
                ),
              ),
            );
          }),

          if (dist.unassignedGuests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Sin asignar: ${dist.unassignedGuests.join(", ")}',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 16),
          if (_explanationLoading) const Center(child: CircularProgressIndicator())
          else if (_explanation != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_explanation!)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _generateExplanation, icon: const Icon(Icons.auto_awesome), label: const Text('Explicar distribución'), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white)),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: _regenerate, icon: const Icon(Icons.refresh), label: const Text('Regenerar distribución'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey)),
          const SizedBox(height: 8),
          if (!_approved) ElevatedButton.icon(onPressed: _approve, icon: const Icon(Icons.check), label: const Text('Aprobar distribución'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final color = _approved ? Colors.green : Colors.orange;
    final text = _approved ? 'Distribución aprobada' : 'Pendiente de aprobación';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Icon(_approved ? Icons.check_circle : Icons.pending, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
