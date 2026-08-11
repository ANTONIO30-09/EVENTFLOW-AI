/// Modelo de datos para un usuario del sistema (colección `profiles` en Firebase).
///
/// Representa tanto al organizador/administrador como al personal
/// operativo (staff), diferenciados por el campo [role].
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'organizador' | 'staff'

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Construye un [UserModel] a partir de un mapa recibido de Firebase.
  factory UserModel.fromMap(String uid, Map<dynamic, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'staff',
    );
  }

  /// Convierte el modelo a un mapa listo para guardar en Firebase.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  bool get isOrganizador => role == 'organizador';
}