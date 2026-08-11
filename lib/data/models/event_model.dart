/// Modelo de datos para un evento (colección `events` en Firebase).
class EventModel {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String status; // 'planificacion' | 'en_curso' | 'finalizado'
  final int guestCount;

  const EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.status,
    this.guestCount = 0,
  });

  factory EventModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return EventModel(
      id: id,
      name: map['name'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? 'planificacion',
      guestCount: map['guestCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'status': status,
      'guestCount': guestCount,
    };
  }
}