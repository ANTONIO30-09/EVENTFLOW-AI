/// Modelo de datos para un ítem de inventario (colección `scan_items` en Firebase).
///
/// El QR contiene únicamente el ID del documento. El contenido real
/// (nombre, ubicación) se valida contra Firestore para evitar falsificaciones.
class ScanItem {
  final String id;
  final String name;
  final String location;
  DateTime? scannedAt;

  ScanItem({
    required this.id,
    required this.name,
    required this.location,
    this.scannedAt,
  });

  String get timeAgo {
    if (scannedAt == null) return 'Sin escanear';
    final diff = DateTime.now().difference(scannedAt!);
    if (diff.inMinutes < 1) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    return 'Hace ${diff.inHours} h';
  }

  factory ScanItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return ScanItem(
      id: id,
      name: map['name'] as String? ?? '',
      location: map['location'] as String? ?? '',
      scannedAt: map['scannedAt'] != null
          ? DateTime.tryParse(map['scannedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      if (scannedAt != null) 'scannedAt': scannedAt!.toIso8601String(),
    };
  }
}
