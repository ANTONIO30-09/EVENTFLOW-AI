import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Servicio de autenticación — encapsula toda la comunicación con
/// Firebase Auth y la colección `profiles` de Firestore.
///
/// Ninguna pantalla debe llamar a FirebaseAuth directamente:
/// todo pasa por aquí (principio MVVM del documento, Cap. 5).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Usuario actualmente autenticado (null si no hay sesión activa).
  User? get currentUser => _auth.currentUser;

  /// Stream que emite cada vez que cambia el estado de sesión.
  /// Útil para redirigir automáticamente entre login y home.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Inicia sesión con correo y contraseña.
  /// Lanza [FirebaseAuthException] si las credenciales son inválidas.
  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchProfile(credential.user!.uid);
  }

  /// Registra un nuevo usuario y crea su perfil en Firestore.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'staff',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
    );
    await _db.collection('profiles').doc(profile.uid).set(profile.toMap());
    return profile;
  }

  /// Cierra la sesión actual.
  Future<void> signOut() => _auth.signOut();

  /// Obtiene el perfil completo (nombre, rol) desde Firestore.
  Future<UserModel> _fetchProfile(String uid) async {
    final doc = await _db.collection('profiles').doc(uid).get();
    if (!doc.exists) {
      throw Exception('Perfil no encontrado para el usuario $uid');
    }
    return UserModel.fromMap(uid, doc.data()!);
  }
}