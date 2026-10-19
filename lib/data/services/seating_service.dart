import '../models/guest_model.dart';
import '../models/seating_table_model.dart';
import '../models/compatibility_rule_model.dart';

class TableAssignment {
  final String tableName;
  final List<String> guests;
  const TableAssignment({required this.tableName, required this.guests});
}

/// Origen de la distribución actual.
///
/// - [ai]: generada por Groq y validada por el algoritmo.
/// - [algorithm]: generada por el algoritmo determinístico local (SeatingService).
///   También se usa como respaldo cuando la IA falla 2 veces.
/// - [manual]: refleja el estado actual de Firestore tras ediciones manuales
///   (fromCurrentAssignments sobre un evento ya aprobado).
/// - [none]: sin fuente conocida (casos borde).
enum DistributionSource { ai, algorithm, manual, none }

class DistributionResult {
  final List<TableAssignment> assignments;
  final List<String> unassignedGuests;
  final String? warning;
  final DistributionSource source;

  const DistributionResult({
    required this.assignments,
    required this.unassignedGuests,
    this.warning,
    this.source = DistributionSource.algorithm,
  });
}

class SeatingService {
  DistributionResult generateDistribution({
    required List<GuestModel> guests,
    required List<SeatingTable> tables,
    required List<CompatibilityRule> rules,
  }) {
    final totalGuests = guests.length;
    final totalCapacity = tables.fold<int>(0, (sum, table) => sum + table.capacity);
    final unassignedGuests = <String>[];
    final assignments = <String, List<String>>{};

    for (final table in tables) {
      assignments[table.name] = [];
    }

    String? warning;
    if (totalGuests > totalCapacity) {
      warning = 'Hay $totalGuests invitados pero solo $totalCapacity sillas disponibles.';
    }

    for (final guest in guests) {
      bool assigned = false;
      final forbidTables = <String>{};
      final preferTables = <String>{};

      for (final rule in rules) {
        if (rule.guestA == guest.name || rule.guestB == guest.name) {
          final other = rule.guestA == guest.name ? rule.guestB : rule.guestA;
          for (final entry in assignments.entries) {
            if (entry.value.contains(other)) {
              if (rule.ruleType == 'forbid') {
                forbidTables.add(entry.key);
              } else if (rule.ruleType == 'prefer') {
                preferTables.add(entry.key);
              }
            }
          }
        }
      }

      for (final tableName in preferTables) {
        final table = tables.firstWhere((t) => t.name == tableName);
        if (assignments[tableName]!.length < table.capacity) {
          assignments[tableName]!.add(guest.name);
          assigned = true;
          break;
        }
      }
      if (assigned) continue;

      for (final table in tables) {
        if (forbidTables.contains(table.name)) continue;
        if (assignments[table.name]!.length < table.capacity) {
          assignments[table.name]!.add(guest.name);
          assigned = true;
          break;
        }
      }

      if (!assigned) {
        unassignedGuests.add(guest.name);
      }
    }

    final tableAssignments = assignments.entries
        .map((e) => TableAssignment(tableName: e.key, guests: e.value))
        .toList();

    return DistributionResult(
      assignments: tableAssignments,
      unassignedGuests: unassignedGuests,
      warning: warning,
    );
  }

  /// Construye un DistributionResult a partir del estado REAL de guests
  /// (guest.tableNumber). No recalcula nada: refleja lo que hay en Firestore
  /// en este momento, incluidas ediciones manuales del organizador.
  DistributionResult fromCurrentAssignments({
    required List<GuestModel> guests,
    required List<SeatingTable> tables,
  }) {
    final capacityByName = <String, int>{};
    final assignmentsMap = <String, List<String>>{};
    for (final table in tables) {
      capacityByName[table.name] = table.capacity;
      assignmentsMap[table.name] = [];
    }
    final unassigned = <String>[];
    for (final guest in guests) {
      final tableName = guest.tableNumber;
      if (tableName.isEmpty || !assignmentsMap.containsKey(tableName)) {
        unassigned.add(guest.name);
        continue;
      }
      final capacity = capacityByName[tableName] ?? 0;
      if (assignmentsMap[tableName]!.length >= capacity) {
        unassigned.add(guest.name);
      } else {
        assignmentsMap[tableName]!.add(guest.name);
      }
    }
    final assignments = assignmentsMap.entries
        .map((e) => TableAssignment(tableName: e.key, guests: e.value))
        .toList();
    return DistributionResult(
      assignments: assignments,
      unassignedGuests: unassigned,
    );
  }

  /// Valida que una distribución generada por la IA sea aceptable.
  ///
  /// Devuelve una lista de errores. Lista vacía = válida.
  /// Si hay al menos un error, la respuesta de la IA se descarta completa
  /// (no se corrige a mano). El caller (AiSeatingService) decide si
  /// reintentar o hacer fallback al algoritmo.
  ///
  /// Verifica:
  /// - No hay invitados duplicados ni inventados.
  /// - Todas las mesas existen y no exceden capacity.
  /// - Ninguna regla forbid se viola.
  /// - Todos los invitados reales están contemplados.
  List<String> validateAiDistribution({
    required Map<String, dynamic> aiResult,
    required List<GuestModel> guests,
    required List<SeatingTable> tables,
    required List<CompatibilityRule> rules,
  }) {
    final errors = <String>[];
    final validNames = guests.map((g) => g.name).toSet();
    final validTableNames = tables.map((t) => t.name).toSet();
    final capacityByName = {for (final t in tables) t.name: t.capacity};

    final rawAssignments = aiResult['assignments'];
    final rawUnassigned = aiResult['unassigned'];

    if (rawAssignments is! List) {
      errors.add('El campo "assignments" no es una lista.');
      return errors;
    }
    if (rawUnassigned is! List) {
      errors.add('El campo "unassigned" no es una lista.');
      return errors;
    }

    final allAssigned = <String>[];
    for (final raw in rawAssignments) {
      if (raw is! Map) {
        errors.add('Cada item de "assignments" debe ser un objeto.');
        continue;
      }
      final tableName = raw['table'];
      final rawGuests = raw['guests'];
      if (tableName is! String) {
        errors.add('Falta el campo "table" en una asignación.');
        continue;
      }
      if (rawGuests is! List) {
        errors.add('Falta el campo "guests" en la mesa $tableName.');
        continue;
      }
      if (!validTableNames.contains(tableName)) {
        errors.add('Mesa inexistente: $tableName');
        continue;
      }
      final capacity = capacityByName[tableName] ?? 0;
      if (rawGuests.length > capacity) {
        errors.add('Mesa $tableName excede capacidad: ${rawGuests.length} > $capacity');
      }
      for (final g in rawGuests) {
        if (g is! String) {
          errors.add('Nombre de invitado no textual en mesa $tableName.');
          continue;
        }
        if (!validNames.contains(g)) {
          errors.add('Invitado inexistente: $g');
        }
        allAssigned.add(g);
      }
    }

    final seen = <String>{};
    for (final name in allAssigned) {
      if (!seen.add(name)) {
        errors.add('Invitado duplicado: $name');
      }
    }

    for (final raw in rawAssignments) {
      if (raw is! Map) continue;
      final rawGuests = raw['guests'];
      final tableName = raw['table'];
      if (rawGuests is! List || tableName is! String) continue;
      final namesInTable = rawGuests.whereType<String>().toSet();
      for (final rule in rules) {
        if (rule.ruleType != 'forbid') continue;
        if (namesInTable.contains(rule.guestA) && namesInTable.contains(rule.guestB)) {
          errors.add('Mesa $tableName viola FORBID: ${rule.guestA} + ${rule.guestB}');
        }
      }
    }

    final unassignedNames = rawUnassigned.whereType<String>().toSet();
    for (final g in guests) {
      if (!seen.contains(g.name) && !unassignedNames.contains(g.name)) {
        errors.add('Invitado omitido: ${g.name}');
      }
    }

    for (final name in unassignedNames) {
      if (!validNames.contains(name)) {
        errors.add('Invitado inexistente en unassigned: $name');
      }
    }

    return errors;
  }
}
