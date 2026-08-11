/// Modelo de datos para un invitado (colección `guests` en Firebase).
///
/// Vinculado a un evento específico mediante [eventId]. El campo
/// [checkedIn] refleja si ya se validó su ingreso (HU-04).
class GuestModel {
  final String id;
  final String eventId;
  final String name;
  final String tableNumber;
  final String familyGroup;
  final int companions;
  final bool checkedIn;
  final DateTime? checkInTime;

  const GuestModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.tableNumber,
    this.familyGroup = '',
    this.companions = 0,
    this.checkedIn = false,
    this.checkInTime,
  });

  factory GuestModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return GuestModel(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      tableNumber: map['tableNumber'] as String? ?? '',
      familyGroup: map['familyGroup'] as String? ?? '',
      companions: map['companions'] as int? ?? 0,
      checkedIn: map['checkedIn'] as bool? ?? false,
      checkInTime: map['checkInTime'] != null
          ? DateTime.tryParse(map['checkInTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'name': name,
      'tableNumber': tableNumber,
      'familyGroup': familyGroup,
      'companions': companions,
      'checkedIn': checkedIn,
      'checkInTime': checkInTime?.toIso8601String(),
    };
  }

  /// Devuelve una copia del invitado marcado como ingresado.
  GuestModel markCheckedIn() {
    return GuestModel(
      id: id,
      eventId: eventId,
      name: name,
      tableNumber: tableNumber,
      familyGroup: familyGroup,
      companions: companions,
      checkedIn: true,
      checkInTime: DateTime.now(),
    );
  }
}