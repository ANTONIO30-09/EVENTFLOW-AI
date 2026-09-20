import '../models/guest_model.dart';
import '../models/seating_table_model.dart';
import '../models/compatibility_rule_model.dart';

class TableAssignment {
  final String tableName;
  final List<String> guests;
  const TableAssignment({required this.tableName, required this.guests});
}

class DistributionResult {
  final List<TableAssignment> assignments;
  final List<String> unassignedGuests;
  final String? warning;
  const DistributionResult({
    required this.assignments,
    required this.unassignedGuests,
    this.warning,
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
    final assignmentsMap = <String, List<String>>{};
    for (final table in tables) {
      assignmentsMap[table.name] = [];
    }
    final unassigned = <String>[];
    for (final guest in guests) {
      final tableName = guest.tableNumber;
      if (tableName.isEmpty || !assignmentsMap.containsKey(tableName)) {
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
}
