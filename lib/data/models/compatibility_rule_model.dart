/// Modelo de regla de compatibilidad entre invitados.
///
/// Representa si un invitado NO puede sentarse con otro (`forbid`)
/// o si sería preferible que se sienten juntos (`prefer`).
class CompatibilityRule {
  final String id;
  final String eventId;
  final String guestA;
  final String guestB;
  final String ruleType; // 'forbid' | 'prefer'
  final bool active;

  const CompatibilityRule({
    required this.id,
    required this.eventId,
    required this.guestA,
    required this.guestB,
    required this.ruleType,
    this.active = true,
  });

  factory CompatibilityRule.fromMap(String id, Map<dynamic, dynamic> map) {
    return CompatibilityRule(
      id: id,
      eventId: map['eventId'] as String? ?? '',
      guestA: map['guestA'] as String? ?? '',
      guestB: map['guestB'] as String? ?? '',
      ruleType: map['ruleType'] as String? ?? 'forbid',
      active: map['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'guestA': guestA,
      'guestB': guestB,
      'ruleType': ruleType,
      'active': active,
    };
  }
}
