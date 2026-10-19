import 'lib/data/models/guest_model.dart';
import 'lib/data/models/seating_table_model.dart';
import 'lib/data/models/compatibility_rule_model.dart';
import 'lib/data/services/ai_seating_service.dart';

void main() async {
  final guests = [
    GuestModel(id: 'g1', eventId: 'test', name: 'Juan Pérez', tableNumber: '', familyGroup: 'Familia Pérez'),
    GuestModel(id: 'g2', eventId: 'test', name: 'María López', tableNumber: '', familyGroup: 'Familia López'),
    GuestModel(id: 'g3', eventId: 'test', name: 'Carlos Ruiz', tableNumber: '', familyGroup: 'Familia Ruiz'),
    GuestModel(id: 'g4', eventId: 'test', name: 'Valeria Torres', tableNumber: '', familyGroup: 'Familia Torres'),
    // Familia Ramírez con 4 integrantes — prueba exigente de agrupación
    GuestModel(id: 'g5', eventId: 'test', name: 'Pedro Ramírez', tableNumber: '', familyGroup: 'Familia Ramírez'),
    GuestModel(id: 'g5b', eventId: 'test', name: 'Rosa Ramírez', tableNumber: '', familyGroup: 'Familia Ramírez'),
    GuestModel(id: 'g5c', eventId: 'test', name: 'Luis Ramírez', tableNumber: '', familyGroup: 'Familia Ramírez'),
    GuestModel(id: 'g5d', eventId: 'test', name: 'Ana Ramírez', tableNumber: '', familyGroup: 'Familia Ramírez'),
    GuestModel(id: 'g6', eventId: 'test', name: 'Lucía Fernández', tableNumber: '', familyGroup: 'Familia Fernández'),
    GuestModel(id: 'g7', eventId: 'test', name: 'Diego Mamani', tableNumber: '', familyGroup: 'Familia Mamani'),
    GuestModel(id: 'g8', eventId: 'test', name: 'Camila Rojas', tableNumber: '', familyGroup: 'Familia Rojas'),
    GuestModel(id: 'g9', eventId: 'test', name: 'Sergio Vargas', tableNumber: '', familyGroup: 'Familia Vargas'),
    GuestModel(id: 'g10', eventId: 'test', name: 'Paola Quispe', tableNumber: '', familyGroup: 'Familia Quispe'),
    GuestModel(id: 'g11', eventId: 'test', name: 'Benjamin Flores', tableNumber: '', familyGroup: 'Familia Flores'),
    GuestModel(id: 'g12', eventId: 'test', name: 'Fabiola Garcia', tableNumber: '', familyGroup: 'Familia Garcia'),
    GuestModel(id: 'g13', eventId: 'test', name: 'Fernando Salazar', tableNumber: '', familyGroup: 'Familia Salazar'),
  ];

  // Mesas MÁS AJUSTADAS (capacidad 8, no 10) para forzar decisiones difíciles
  final tables = [
    SeatingTable(id: 't1', eventId: 'test', name: 'Mesa 1', capacity: 8),
    SeatingTable(id: 't2', eventId: 'test', name: 'Mesa 2', capacity: 8),
  ];

  final rules = [
    CompatibilityRule(id: 'r1', eventId: 'test', guestA: 'Juan Pérez', guestB: 'María López', ruleType: 'forbid'),
  ];

  final service = AiSeatingService();
  final result = await service.generateWithAI(
    eventName: 'Prueba diagnóstico exigente',
    guests: guests,
    tables: tables,
    rules: rules,
  );

  print('=== ORIGEN: ${result.source} ===\n');
  for (final a in result.assignments) {
    print('${a.tableName}: ${a.guests.join(", ")}');
  }
  print('\nSin asignar: ${result.unassignedGuests.join(", ")}');

  print('\n=== VERIFICACIÓN: Familia Ramírez (4 integrantes) ===');
  final ramirezNames = ['Pedro Ramírez', 'Rosa Ramírez', 'Luis Ramírez', 'Ana Ramírez'];
  for (final a in result.assignments) {
    final enEstaMesa = ramirezNames.where((n) => a.guests.contains(n)).toList();
    if (enEstaMesa.isNotEmpty) {
      print('${a.tableName}: ${enEstaMesa.length}/4 Ramírez → $enEstaMesa');
    }
  }
  final mesasConRamirez = result.assignments.where((a) => ramirezNames.any((n) => a.guests.contains(n))).length;
  print(mesasConRamirez == 1 ? '✅ Los 4 quedaron en la MISMA mesa' : '❌ La familia quedó REPARTIDA en $mesasConRamirez mesas distintas');
}
