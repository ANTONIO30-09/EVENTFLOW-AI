// DATOS SIMULADOS - sin conexión a Firestore.
//
// Este archivo define clases y listas LOCALES al Panel de Administración.
// No reutiliza modelos de lib/data/models/ ni toca ningún servicio de
// Firebase/Firestore. Todo vive en memoria mientras la sesión esté abierta.
//
// Las pantallas del panel reciben estas listas por constructor y las
// mutan con setState. Al cerrar sesión / recargar, todo vuelve a su
// estado inicial (los cambios NO persisten).

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ---------------------------------------------------------------------------
// Enums locales
// ---------------------------------------------------------------------------

/// Estado del evento dentro del ciclo logístico.
enum EventStatus { planificacion, enCurso, finalizado }

/// Rol del usuario dentro de la plataforma.
enum UserRole { organizador, staff }

// ---------------------------------------------------------------------------
// Helpers de presentación (etiqueta + color)
// ---------------------------------------------------------------------------

/// Etiqueta legible para mostrar el estado del evento.
String etiquetaEstado(EventStatus e) {
  switch (e) {
    case EventStatus.planificacion:
      return 'Planificación';
    case EventStatus.enCurso:
      return 'En curso';
    case EventStatus.finalizado:
      return 'Finalizado';
  }
}

/// Color asociado al estado, dentro de la paleta aprobada.
/// - Planificación: bronce (en preparación).
/// - En curso: bronce claro / secundario (activo pero no cerrado).
/// - Finalizado: verde salvia (éxito).
Color colorEstado(EventStatus e) {
  switch (e) {
    case EventStatus.planificacion:
      return AppColors.acentoBronce;
    case EventStatus.enCurso:
      return AppColors.textoSecundarioGris;
    case EventStatus.finalizado:
      return AppColors.exitoVerdeSalvia;
  }
}

/// Etiqueta legible para el rol del usuario.
String etiquetaRol(UserRole r) {
  switch (r) {
    case UserRole.organizador:
      return 'Organizador';
    case UserRole.staff:
      return 'Staff';
  }
}

// ---------------------------------------------------------------------------
// Clases locales
// ---------------------------------------------------------------------------

/// Evento simulado del panel. Los campos `checkIn` e `itemsEscaneados` se
/// usan en el módulo de Reportes para calcular KPIs y gráficas.
class AdminEvent {
  AdminEvent({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.estado,
    required this.invitados,
    this.checkIn = 0,
    this.itemsEscaneados = 0,
  });

  final String id;
  String nombre;
  DateTime fecha;
  String lugar;
  EventStatus estado;
  int invitados;

  /// Invitados que ya hicieron check-in. Solo lectura para el panel de
  /// reportes; se inicializa con datos mock.
  int checkIn;

  /// Ítems de inventario escaneados. Solo lectura para reportes.
  int itemsEscaneados;

  /// Copia con nuevos valores (útil para editar sin mutar la lista original
  /// si en algún momento se decide hacerlo inmutable).
  AdminEvent copyWith({
    String? nombre,
    DateTime? fecha,
    String? lugar,
    EventStatus? estado,
    int? invitados,
    int? checkIn,
    int? itemsEscaneados,
  }) {
    return AdminEvent(
      id: id,
      nombre: nombre ?? this.nombre,
      fecha: fecha ?? this.fecha,
      lugar: lugar ?? this.lugar,
      estado: estado ?? this.estado,
      invitados: invitados ?? this.invitados,
      checkIn: checkIn ?? this.checkIn,
      itemsEscaneados: itemsEscaneados ?? this.itemsEscaneados,
    );
  }
}

/// Usuario simulado del panel.
class AdminUser {
  AdminUser({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  final String id;
  String nombre;
  String correo;
  UserRole rol;

  AdminUser copyWith({
    String? nombre,
    String? correo,
    UserRole? rol,
  }) {
    return AdminUser(
      id: id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
    );
  }
}

// ---------------------------------------------------------------------------
// Datos mock (Cochabamba, Bolivia)
// ---------------------------------------------------------------------------

/// Función que genera una lista fresca de eventos mock. Se usa una función
/// (no una constante) para que cada vez que se entra al panel desde cero,
/// la lista arranque limpia y las mutaciones de sesiones previas no queden.
List<AdminEvent> crearEventosMock() => [
      AdminEvent(
        id: 'ev-001',
        nombre: 'Boda Valeria & Andrés',
        fecha: DateTime(2026, 3, 14),
        lugar: 'Hacienda San Isidro, Quillacollo',
        estado: EventStatus.planificacion,
        invitados: 180,
        checkIn: 0,
        itemsEscaneados: 12,
      ),
      AdminEvent(
        id: 'ev-002',
        nombre: 'Quince años Camila',
        fecha: DateTime(2026, 2, 22),
        lugar: 'Salón Los Álamos, Cochabamba',
        estado: EventStatus.enCurso,
        invitados: 120,
        checkIn: 87,
        itemsEscaneados: 64,
      ),
      AdminEvent(
        id: 'ev-003',
        nombre: 'Aniversario Club Tunari',
        fecha: DateTime(2026, 1, 18),
        lugar: 'Club Tunari, Tiquipaya',
        estado: EventStatus.finalizado,
        invitados: 240,
        checkIn: 233,
        itemsEscaneados: 198,
      ),
      AdminEvent(
        id: 'ev-004',
        nombre: 'Graduación Promo 2026',
        fecha: DateTime(2026, 4, 5),
        lugar: 'Centro de Convenciones El Portal, Cochabamba',
        estado: EventStatus.planificacion,
        invitados: 320,
        checkIn: 0,
        itemsEscaneados: 8,
      ),
      AdminEvent(
        id: 'ev-005',
        nombre: 'Corporativo Andes Tech',
        fecha: DateTime(2026, 2, 8),
        lugar: 'Hotel Cochabamba, Cochabamba',
        estado: EventStatus.enCurso,
        invitados: 95,
        checkIn: 41,
        itemsEscaneados: 30,
      ),
    ];

/// Función que genera una lista fresca de usuarios mock.
List<AdminUser> crearUsuariosMock() => [
      AdminUser(
        id: 'us-001',
        nombre: 'Antonio Quiroga',
        correo: 'antonio.quiroga@eventflow.ai',
        rol: UserRole.organizador,
      ),
      AdminUser(
        id: 'us-002',
        nombre: 'María Fernández',
        correo: 'maria.fernandez@eventflow.ai',
        rol: UserRole.organizador,
      ),
      AdminUser(
        id: 'us-003',
        nombre: 'Luis Choque',
        correo: 'luis.choque@eventflow.ai',
        rol: UserRole.staff,
      ),
      AdminUser(
        id: 'us-004',
        nombre: 'Andrea Villarroel',
        correo: 'andrea.villarroel@eventflow.ai',
        rol: UserRole.staff,
      ),
      AdminUser(
        id: 'us-005',
        nombre: 'Rodrigo Méndez',
        correo: 'rodrigo.mendez@eventflow.ai',
        rol: UserRole.staff,
      ),
      AdminUser(
        id: 'us-006',
        nombre: 'Carla Gutiérrez',
        correo: 'carla.gutierrez@eventflow.ai',
        rol: UserRole.organizador,
      ),
    ];
