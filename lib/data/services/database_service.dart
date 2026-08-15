import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/guest_model.dart';

/// Servicio de datos — encapsula toda la comunicación con Firestore
/// para eventos e invitados. Ninguna pantalla debe llamar a
/// FirebaseFirestore directamente (principio MVVM, Cap. 5 del documento).
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
}