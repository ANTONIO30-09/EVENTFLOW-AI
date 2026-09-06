/// Modelo de mesa para distribución de invitados.
class SeatingTable {
  final String id;
  final String eventId;
  final String name;
  final int capacity;

  const SeatingTable({
    required this.id,
    required this.eventId,
    required this.name,
    required this.capacity,
  });

  factory SeatingTable.fromMap(String id, Map<dynamic, dynamic> map) {
    return SeatingTable(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'name': name,
      'capacity': capacity,
    };
  }
}
