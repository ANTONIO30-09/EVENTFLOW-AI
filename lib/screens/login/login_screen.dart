import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';

class _Palette {
  static const Color fondo = Color(0xFF1B2A3D);
  static const Color porcelana = Color(0xFFFBF9F4);
  static const Color bronce = Color(0xFFB8863E);
  static const Color ladrillo = Color(0xFFA63D40);
  static const Color grisCalido = Color(0xFF6B6459);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showError('Ingresá usuario y contraseña');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(_emailController.text.trim(), _passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(_mensajeError(e.code));
    } catch (e) {
      if (mounted) _showError('Ocurrió un error inesperado');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Correo inválido';
      default:
        return 'No se pudo iniciar sesión';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _Palette.ladrillo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 140,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.blur_on, size: 120, color: _Palette.bronce);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'EventFlow AI',
                    style: GoogleFonts.fraunces(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: _Palette.bronce,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema de Logística de Eventos',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _Palette.grisCalido,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildInputField(
                    controller: _emailController,
                    label: 'Usuario',
                    hint: 'tu.usuario@correo.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  _buildInputField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    hint: '••••••••',
                    isObscure: true,
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        backgroundColor: _Palette.bronce,
                        foregroundColor: _Palette.fondo,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1B2A3D),
                              ),
                            )
                          : Text(
                              'Iniciar sesión',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isObscure = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _Palette.porcelana,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: _Palette.fondo,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: _Palette.bronce,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: _Palette.grisCalido.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            filled: true,
            fillColor: _Palette.porcelana,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _Palette.bronce, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
