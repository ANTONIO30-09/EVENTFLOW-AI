import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/guest_model.dart';
import '../models/scan_item_model.dart';
import '../models/compatibility_rule_model.dart';

/// Servicio de datos — encapsula toda la comunicación con Firestore
/// para eventos, invitados e inventario. Ninguna pantalla debe llamar
/// a FirebaseFirestore directamente (principio MVVM, Cap. 5 del documento).
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- EVENTOS ----------

  /// Stream en tiempo real de todos los eventos, ordenados por fecha.
  Stream<List<EventModel>> streamEvents() {
    return _db
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Crea un nuevo evento y devuelve su ID generado.
  Future<String> createEvent(EventModel event) async {
    final ref = await _db.collection('events').add(event.toMap());
    return ref.id;
  }

  /// Actualiza un evento existente.
  Future<void> updateEvent(EventModel event) {
    return _db.collection('events').doc(event.id).update(event.toMap());
  }

  // ---------- INVITADOS ----------

  /// Stream en tiempo real de los invitados de un evento específico.
  Stream<List<GuestModel>> streamGuestsForEvent(String eventId) {
    return _db
        .collection('guests')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GuestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Agrega un invitado nuevo a un evento.
  Future<void> addGuest(GuestModel guest) {
    return _db.collection('guests').add(guest.toMap());
  }

  /// Marca a un invitado como ingresado (HU-04) y guarda el cambio.
  Future<void> checkInGuest(GuestModel guest) {
    final updated = guest.markCheckedIn();
    return _db.collection('guests').doc(guest.id).update(updated.toMap());
  }

  // ---------- INVENTARIO ----------

  /// Busca un ítem de inventario por su ID (el ID viene del QR).
  Future<ScanItem?> fetchScanItemById(String id) async {
    final doc = await _db.collection('scan_items').doc(id).get();
    if (!doc.exists) return null;
    return ScanItem.fromMap(doc.id, doc.data() as Map<dynamic, dynamic>);
  }

  /// Registra el escaneo del ítem actualizando `scannedAt` en Firestore.
  Future<void> registerScan(String id) async {
    final docRef = _db.collection('scan_items').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('No existe un ítem con el ID escaneado.');
    }
    await docRef.update({'scannedAt': DateTime.now().toIso8601String()});
  }

  // ---------- REGLAS DE COMPATIBILIDAD ----------

  /// Stream en tiempo real de las reglas de compatibilidad de un evento.
  Stream<List<CompatibilityRule>> streamCompatibilityRulesForEvent(String eventId) {
    return _db
        .collection('compatibility_rules')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompatibilityRule.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Crea una regla de compatibilidad y devuelve su ID.
  Future<String> addCompatibilityRule(CompatibilityRule rule) async {
    final ref = await _db.collection('compatibility_rules').add(rule.toMap());
    return ref.id;
  }
}
