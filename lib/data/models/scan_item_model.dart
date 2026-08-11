class ScanItem {
  final String id;
  final String name;
  final String location;
  final DateTime scannedAt;

  ScanItem({
    required this.id,
    required this.name,
    required this.location,
    required this.scannedAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(scannedAt);
    if (diff.inMinutes < 1) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    return 'Hace ${diff.inHours} h';
  }
}