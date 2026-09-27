import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/guest_model.dart';
import '../../data/models/seating_table_model.dart';
import '../../data/models/compatibility_rule_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/seating_service.dart';
import '../../data/services/ai_explanation_service.dart';
import '../../data/services/ai_seating_service.dart';

class SuggestedDistributionScreen extends StatefulWidget {
  final String eventId;
  const SuggestedDistributionScreen({super.key, required this.eventId});

  @override
  State<SuggestedDistributionScreen> createState() => _SuggestedDistributionScreenState();
}

class _SuggestedDistributionScreenState extends State<SuggestedDistributionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final SeatingService _seatingService = SeatingService();
  final AiExplanationService _aiService = AiExplanationService();
  final AiSeatingService _aiSeatingService = AiSeatingService();

  bool _loading = true;
  bool _aiGenerating = false;
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
      final eventSource = event?.distributionSource ?? '';

      DistributionResult result;
      if (approved) {
        final base = _seatingService.fromCurrentAssignments(guests: guests, tables: tables);
        final src = eventSource == 'ai'
            ? DistributionSource.ai
            : (eventSource == 'manual'
                ? DistributionSource.manual
                : DistributionSource.algorithm);
        result = DistributionResult(
          assignments: base.assignments,
          unassignedGuests: base.unassignedGuests,
          warning: base.warning,
          source: src,
        );
      } else {
        result = _seatingService.generateDistribution(
            guests: guests, tables: tables, rules: rules);
      }
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
      setState(() { _error = 'Error al cargar'; _loading = false; });
    }
  }

  Future<void> _generateWithAI() async {
    if (_approved) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.superficiePorcelana,
          title: Text('Generar con IA',
              style: GoogleFonts.fraunces(color: AppColors.fondoAzulNoche, fontWeight: FontWeight.w700)),
          content: Text('Esto descarta la aprobación actual. ¿Continuar?',
              style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textoSecundarioGris)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acentoBronce,
                foregroundColor: AppColors.fondoAzulNoche,
              ),
              child: Text('Generar', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await _databaseService.unapproveDistribution(widget.eventId);
    }

    setState(() {
      _aiGenerating = true;
      _explanation = null;
      _error = null;
    });

    try {
      final guests = await _databaseService.fetchGuestsForEvent(widget.eventId);
      final tables = await _databaseService.fetchTablesForEvent(widget.eventId);
      final rules = await _databaseService.fetchCompatibilityRulesForEvent(widget.eventId);
      final event = await _databaseService.fetchEventById(widget.eventId);
      final eventName = event?.name ?? 'Evento';

      final result = await _aiSeatingService.generateWithAI(
        eventName: eventName,
        guests: guests,
        tables: tables,
        rules: rules,
      );

      if (!mounted) return;
      setState(() {
        _distribution = result;
        _tables = tables;
        _rules = rules;
        _approved = false;
        _aiGenerating = false;
      });

      if (result.source == DistributionSource.algorithm) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La IA no pudo generar una distribución válida, se usó el algoritmo estándar.',
                style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
            backgroundColor: AppColors.alertaLadrillo,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiGenerating = false;
        _error = 'Error al generar con IA';
      });
    }
  }

  Future<void> _regenerate() async {
    if (_approved) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.superficiePorcelana,
          title: Text('Regenerar distribución',
              style: GoogleFonts.fraunces(color: AppColors.fondoAzulNoche, fontWeight: FontWeight.w700)),
          content: Text('Esto descarta los cambios manuales y la aprobación. ¿Continuar?',
              style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textoSecundarioGris)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acentoBronce,
                foregroundColor: AppColors.fondoAzulNoche,
              ),
              child: Text('Regenerar', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
      await _databaseService.unapproveDistribution(widget.eventId);
    }
    await _loadDistribution();
  }

  Future<void> _reloadFromCurrent() async {
    try {
      final guests = await _databaseService.fetchGuestsForEvent(widget.eventId);
      final current = _seatingService.fromCurrentAssignments(guests: guests, tables: _tables);
      if (!mounted) return;
      setState(() { _distribution = current; _explanation = null; });
    } catch (_) {}
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

    final sourceStr = dist.source == DistributionSource.ai ? 'ai' : 'algorithm';
    await _databaseService.approveDistribution(widget.eventId, source: sourceStr);
    if (!mounted) return;
    setState(() { _approved = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Distribución aprobada',
            style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
        backgroundColor: AppColors.exitoVerdeSalvia,
      ),
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
    final familyMembers = guests.where((g) =>
        g.familyGroup.isNotEmpty &&
        g.familyGroup == guest.familyGroup &&
        g.tableNumber == originTable &&
        g.name != guest.name).toList();
    final hasFamily = familyMembers.isNotEmpty;

    if (!mounted) return;
    await showDialog(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setDlg) {
        return AlertDialog(
          backgroundColor: AppColors.superficiePorcelana,
          title: Text('Mover a $guestName',
              style: GoogleFonts.fraunces(color: AppColors.fondoAzulNoche, fontWeight: FontWeight.w700)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: dest,
              dropdownColor: AppColors.superficiePorcelana,
              style: GoogleFonts.inter(color: AppColors.fondoAzulNoche),
              items: destTables.map((t) {
                final assigned = dist.assignments.firstWhere((a) => a.tableName == t.name, orElse: () => TableAssignment(tableName: t.name, guests: const [])).guests.length;
                return DropdownMenuItem(value: t.name, child: Text('${t.name} ($assigned/${t.capacity})',
                    style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)));
              }).toList(),
              onChanged: (v) => setDlg(() => dest = v),
              decoration: InputDecoration(
                labelText: 'Mesa destino',
                labelStyle: GoogleFonts.inter(color: AppColors.acentoBronce),
                border: const OutlineInputBorder(),
              ),
            ),
            if (hasFamily)
              SwitchListTile(
                value: moveFamily,
                activeThumbColor: AppColors.acentoBronce,
                onChanged: (v) => setDlg(() => moveFamily = v),
                title: Text('Mover también a ${familyMembers.length} de ${guest.familyGroup}',
                    style: GoogleFonts.inter(color: AppColors.fondoAzulNoche, fontSize: 13)),
              ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: GoogleFonts.inter(color: AppColors.textoSecundarioGris)),
            ),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx, {'dest': dest, 'family': moveFamily, 'members': familyMembers}); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acentoBronce,
                foregroundColor: AppColors.fondoAzulNoche,
              ),
              child: Text('Mover', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error, style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
        backgroundColor: AppColors.alertaLadrillo,
      ));
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
    final motivos = <String>[];
    if (ocupadas + toMove.length > destTable.capacity) {
      final libres = destTable.capacity - ocupadas;
      final faltan = toMove.length - libres;
      if (libres <= 0) {
        motivos.add('la mesa $dest ya está llena ($ocupadas/${destTable.capacity}), hacen falta $faltan sillas');
      } else {
        motivos.add('la mesa $dest tiene $libres sillas libres pero se intentan mover ${toMove.length} personas');
      }
    }

    final conflictos = <String>[];
    for (final moving in toMove) {
      for (final rule in _rules) {
        if (rule.ruleType != 'forbid') continue;
        String? other;
        if (rule.guestA == moving.name) other = rule.guestB;
        if (rule.guestB == moving.name) other = rule.guestA;
        if (other == null) continue;
        if (destAssignment.guests.contains(other) && !toMove.any((g) => g.name == other)) {
          final msg = '${moving.name} tiene regla "no sentar juntos" con $other, quien ya está en $dest';
          if (!conflictos.contains(msg)) conflictos.add(msg);
        }
      }
    }
    if (conflictos.isNotEmpty) {
      motivos.add(conflictos.join('; '));
    }

    if (motivos.isEmpty) return null;
    return 'No se puede mover: ${motivos.join(". Además, ")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      appBar: AppBar(
        title: const Text('Distribución Sugerida'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.acentoBronce));
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: GoogleFonts.inter(color: AppColors.alertaLadrillo)),
      );
    }
    final dist = _distribution!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusBanner(),
        if (dist.warning != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              dist.warning!,
              style: GoogleFonts.inter(
                color: AppColors.alertaLadrillo,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        const SizedBox(height: 16),
        ...dist.assignments.map((a) {
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.superficiePorcelana,
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: AppColors.acentoBronce, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.tableName,
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fondoAzulNoche,
                  ),
                ),
                const SizedBox(height: 10),
                if (a.guests.isEmpty)
                  Text('Sin invitados asignados',
                      style: GoogleFonts.inter(color: AppColors.textoSecundarioGris, fontSize: 13))
                else
                  ...a.guests.map((g) => InkWell(
                        onTap: () => _openMoveDialog(g, a.tableName),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(children: [
                            const Icon(Icons.person, size: 18, color: AppColors.fondoAzulNoche),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                g,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.fondoAzulNoche,
                                ),
                              ),
                            ),
                            Icon(Icons.edit, size: 16, color: AppColors.acentoBronce),
                          ]),
                        ),
                      )),
              ],
            ),
          );
        }),
        if (dist.unassignedGuests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Sin asignar: ${dist.unassignedGuests.join(", ")}',
              style: GoogleFonts.inter(
                color: AppColors.alertaLadrillo,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        const SizedBox(height: 20),
        if (_explanationLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.acentoBronce))
        else if (_explanation != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.acentoBronce, width: 1),
            ),
            child: Text(
              _explanation!,
              style: GoogleFonts.inter(
                color: AppColors.superficiePorcelana,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (_aiGenerating) ...[
          const Center(child: CircularProgressIndicator(color: AppColors.acentoBronce)),
          const SizedBox(height: 12),
          Text('Consultando a la IA...',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textoSecundarioGris, fontSize: 13)),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: _aiGenerating ? null : _generateWithAI,
          icon: const Icon(Icons.auto_awesome),
          label: Text('Generar con IA',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.acentoBronce,
            foregroundColor: AppColors.fondoAzulNoche,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _aiGenerating ? null : _regenerate,
          icon: const Icon(Icons.settings),
          label: Text('Usar algoritmo estándar',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.acentoBronce,
            side: const BorderSide(color: AppColors.acentoBronce),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _generateExplanation,
          icon: const Icon(Icons.description_outlined),
          label: Text('Explicar distribución',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.acentoBronce,
            side: const BorderSide(color: AppColors.acentoBronce),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        if (!_approved) ...[
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _approve,
            icon: const Icon(Icons.check),
            label: Text('Aprobar distribución',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.exitoVerdeSalvia,
              foregroundColor: AppColors.superficiePorcelana,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatusBanner() {
    final color = _approved ? AppColors.exitoVerdeSalvia : AppColors.acentoBronce;
    final icon = _approved ? Icons.check_circle : Icons.pending;
    final text = _approved ? 'Distribución aprobada' : 'Pendiente de aprobación';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              text,
              style: GoogleFonts.inter(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _buildSourceChip(),
        ],
      ),
    );
  }

  Widget _buildSourceChip() {
    final dist = _distribution;
    if (dist == null) return const SizedBox.shrink();

    final IconData icon;
    final String label;
    final Color color;

    switch (dist.source) {
      case DistributionSource.ai:
        icon = Icons.auto_awesome;
        label = 'Generada por IA';
        color = AppColors.acentoBronce;
        break;
      case DistributionSource.algorithm:
        icon = Icons.settings;
        label = 'Generada por algoritmo';
        color = AppColors.textoSecundarioGris;
        break;
      case DistributionSource.manual:
        icon = Icons.edit;
        label = 'Ajustada manualmente';
        color = AppColors.textoSecundarioGris;
        break;
      case DistributionSource.none:
        icon = Icons.help_outline;
        label = 'Sin fuente conocida';
        color = AppColors.textoSecundarioGris;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
