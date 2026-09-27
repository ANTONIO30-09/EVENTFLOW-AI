import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        SnackBar(
          content: Text('Elegí dos invitados distintos',
              style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
          backgroundColor: AppColors.alertaLadrillo,
        ),
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
      SnackBar(
        content: Text('Regla agregada',
            style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
        backgroundColor: AppColors.exitoVerdeSalvia,
      ),
    );
  }

  Future<void> _deleteRule(String ruleId) async {
    await _databaseService.deleteCompatibilityRule(ruleId);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.acentoBronce,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.superficiePorcelana,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.acentoBronce, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      appBar: AppBar(
        title: const Text('Reglas de Compatibilidad'),
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
                Text(
                  'Nueva regla',
                  style: GoogleFonts.fraunces(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.acentoBronce,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabel('Invitado A'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _guestA == null
                      ? null
                      : labels.firstWhere(
                          (l) => labelToName[l] == _guestA,
                          orElse: () => labels.first,
                        ),
                  isExpanded: true,
                  dropdownColor: AppColors.superficiePorcelana,
                  style: GoogleFonts.inter(color: AppColors.fondoAzulNoche, fontSize: 14),
                  items: labels
                      .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(l,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _guestA = v == null ? null : labelToName[v]),
                  decoration: _dropdownDecoration(),
                ),
                const SizedBox(height: 14),
                _buildLabel('Invitado B'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _guestB == null
                      ? null
                      : labels.firstWhere(
                          (l) => labelToName[l] == _guestB,
                          orElse: () => labels.first,
                        ),
                  isExpanded: true,
                  dropdownColor: AppColors.superficiePorcelana,
                  style: GoogleFonts.inter(color: AppColors.fondoAzulNoche, fontSize: 14),
                  items: labels
                      .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(l,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _guestB = v == null ? null : labelToName[v]),
                  decoration: _dropdownDecoration(),
                ),
                const SizedBox(height: 14),
                _buildLabel('Tipo de regla'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _ruleType,
                  dropdownColor: AppColors.superficiePorcelana,
                  style: GoogleFonts.inter(color: AppColors.fondoAzulNoche, fontSize: 14),
                  items: [
                    DropdownMenuItem(
                      value: 'forbid',
                      child: Text('No sentar juntos',
                          style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)),
                    ),
                    DropdownMenuItem(
                      value: 'prefer',
                      child: Text('Sentar juntos',
                          style: GoogleFonts.inter(color: AppColors.fondoAzulNoche)),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _ruleType = v);
                  },
                  decoration: _dropdownDecoration(),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _addRule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.acentoBronce,
                    foregroundColor: AppColors.fondoAzulNoche,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'AGREGAR REGLA',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reglas del evento',
                  style: GoogleFonts.fraunces(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.acentoBronce,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<List<CompatibilityRule>>(
                    stream: _databaseService.streamCompatibilityRulesForEvent(widget.eventId),
                    builder: (context, ruleSnap) {
                      final rules = ruleSnap.data ?? [];
                      if (rules.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay reglas cargadas.',
                            style: GoogleFonts.inter(color: AppColors.textoSecundarioGris),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: rules.length,
                        itemBuilder: (context, i) {
                          final rule = rules[i];
                          final isForbid = rule.ruleType == 'forbid';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppColors.superficiePorcelana,
                              borderRadius: BorderRadius.circular(8),
                              border: const Border(
                                left: BorderSide(color: AppColors.acentoBronce, width: 4),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  isForbid ? Icons.block : Icons.favorite,
                                  color: isForbid
                                      ? AppColors.alertaLadrillo
                                      : AppColors.exitoVerdeSalvia,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${rule.guestA} - ${rule.guestB}',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.fondoAzulNoche,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isForbid ? 'No sentar juntos' : 'Sentar juntos',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textoSecundarioGris,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.alertaLadrillo, size: 20),
                                  onPressed: () => _deleteRule(rule.id),
                                ),
                              ],
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
