import 'lib/data/models/guest_model.dart';
import 'lib/data/models/seating_table_model.dart';
import 'lib/data/models/compatibility_rule_model.dart';
import 'lib/data/services/ai_seating_service.dart';

void main() async {
  // Tus 17 invitados reales, incluida la Familia Ramírez (para probar agrupación)
  final guests = [
    GuestModel(id: 'g1', eventId: 'test', name: 'Juan Pérez', tableNumber: '', familyGroup: 'Familia Pérez'),
    GuestModel(id: 'g2', eventId: 'test', name: 'María López', tableNumber: '', familyGroup: 'Familia López'),
    GuestModel(id: 'g3', eventId: 'test', name: 'Carlos Ruiz', tableNumber: '', familyGroup: 'Familia Ruiz'),
    GuestModel(id: 'g4', eventId: 'test', name: 'Valeria Torres', tableNumber: '', familyGroup: 'Familia Torres'),
    GuestModel(id: 'g5', eventId: 'test', name: 'Pedro Ramírez', tableNumber: '', familyGroup: 'Familia Ramírez'),
    GuestModel(id: 'g6', eventId: 'test', name: 'Lucía Fernández', tableNumber: '', familyGroup: 'Familia Fernández'),
    GuestModel(id: 'g7', eventId: 'test', name: 'Diego Mamani', tableNumber: '', familyGroup: 'Familia Mamani'),
    GuestModel(id: 'g8', eventId: 'test', name: 'Camila Rojas', tableNumber: '', familyGroup: 'Familia Rojas'),
    GuestModel(id: 'g9', eventId: 'test', name: 'Sergio Vargas', tableNumber: '', familyGroup: 'Familia Vargas'),
    GuestModel(id: 'g10', eventId: 'test', name: 'Paola Quispe', tableNumber: '', familyGroup: 'Familia Quispe'),
    GuestModel(id: 'g11', eventId: 'test', name: 'Benjamin Flores', tableNumber: '', familyGroup: 'Familia Flores'),
    GuestModel(id: 'g12', eventId: 'test', name: 'Fabiola Garcia', tableNumber: '', familyGroup: 'Familia Garcia'),
    GuestModel(id: 'g13', eventId: 'test', name: 'Fernando Salazar', tableNumber: '', familyGroup: 'Familia Salazar'),
    GuestModel(id: 'g14', eventId: 'test', name: 'Gabriela Montaño', tableNumber: '', familyGroup: 'Familia Montaño'),
    GuestModel(id: 'g15', eventId: 'test', name: 'Alejandro Guzmán', tableNumber: '', familyGroup: 'Familia Guzmán'),
    GuestModel(id: 'g16', eventId: 'test', name: 'Verónica Aguilar', tableNumber: '', familyGroup: 'Familia Aguilar'),
    GuestModel(id: 'g17', eventId: 'test', name: 'Alejandro Castillo', tableNumber: '', familyGroup: 'Familia Castillo'),
    // Agregamos un 2do miembro de Familia Ramírez para forzar el caso de prueba real
    GuestModel(id: 'g18', eventId: 'test', name: 'Rosa Ramírez', tableNumber: '', familyGroup: 'Familia Ramírez'),
  ];

  final tables = [
    SeatingTable(id: 't1', eventId: 'test', name: 'Mesa 1', capacity: 10),
    SeatingTable(id: 't2', eventId: 'test', name: 'Mesa 2', capacity: 10),
  ];

  final rules = [
    CompatibilityRule(id: 'r1', eventId: 'test', guestA: 'Juan Pérez', guestB: 'María López', ruleType: 'forbid'),
  ];

  final service = AiSeatingService();
  final result = await service.generateWithAI(
    eventName: 'Prueba diagnóstico',
    guests: guests,
    tables: tables,
    rules: rules,
  );

  print('=== ORIGEN: ${result.source} ===\n');
  for (final a in result.assignments) {
    print('${a.tableName}: ${a.guests.join(", ")}');
  }
  print('\nSin asignar: ${result.unassignedGuests.join(", ")}');

  print('\n=== VERIFICACIÓN MANUAL: Familia Ramírez ===');
  print('Pedro Ramírez y Rosa Ramírez deberían estar en la MISMA mesa.');
  final ramirezTable1 = result.assignments.any((a) => a.tableName == 'Mesa 1' && a.guests.contains('Pedro Ramírez'));
  final ramirezTable1b = result.assignments.any((a) => a.tableName == 'Mesa 1' && a.guests.contains('Rosa Ramírez'));
  final ramirezTable2 = result.assignments.any((a) => a.tableName == 'Mesa 2' && a.guests.contains('Pedro Ramírez'));
  final ramirezTable2b = result.assignments.any((a) => a.tableName == 'Mesa 2' && a.guests.contains('Rosa Ramírez'));
  final juntos = (ramirezTable1 && ramirezTable1b) || (ramirezTable2 && ramirezTable2b);
  print(juntos ? '✅ Quedaron JUNTOS' : '❌ Quedaron SEPARADOS — confirma el hueco del validador');
}
