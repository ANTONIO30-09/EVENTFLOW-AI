import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _flightController;
  final GlobalKey _logoPlaceholderKey = GlobalKey();
  Rect? _logoFinalRect;
  bool _flightDone = false;

  @override
  void initState() {
    super.initState();
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlight());
  }

  void _startFlight() {
    final ctx = _logoPlaceholderKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final topLeft = box.localToGlobal(Offset.zero);
    setState(() {
      _logoFinalRect = Rect.fromLTWH(
        topLeft.dx,
        topLeft.dy,
        box.size.width,
        box.size.height,
      );
    });
    _flightController.forward().whenComplete(() {
      if (mounted) setState(() => _flightDone = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _flightController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showError('Ingresá usuario y contraseña');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
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
        backgroundColor: AppColors.alertaLadrillo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildLoginLayout(),
          if (!_flightDone && _logoFinalRect != null) _buildFlyingLogo(),
        ],
      ),
    );
  }

  // ============================================================
  // Layout del login (con placeholder donde va el logo)
  // ============================================================
  Widget _buildLoginLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.superficiePorcelana.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.superficiePorcelana.withValues(
                        alpha: 0.18,
                      ),
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Placeholder del logo: reserva el espacio y se mide.
                      SizedBox(
                        key: _logoPlaceholderKey,
                        width: 120,
                        height: 120,
                        child: _flightDone
                            ? Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.blur_on,
                                      color: AppColors.acentoBronce,
                                    ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'EventFlow AI',
                        style: GoogleFonts.fraunces(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: AppColors.acentoBronce,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sistema de Logística de Eventos',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.superficiePorcelana.withValues(
                            alpha: 0.75,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Usuario',
                        hint: 'tu.usuario@correo.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Contraseña',
                        hint: '••••••••',
                        isObscure: true,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.acentoBronce,
                            foregroundColor: AppColors.fondoAzulNoche,
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
                                    color: AppColors.fondoAzulNoche,
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
        ),
      ),
    );
  }

  // ============================================================
  // Logo volador: interpola posición + escala + rotación + bump
  // ============================================================
  Widget _buildFlyingLogo() {
    final screenSize = MediaQuery.of(context).size;
    final startLeft = screenSize.width / 2 - 80;
    final startTop = screenSize.height / 2 - 80;
    const startSize = 160.0;
    final endRect = _logoFinalRect!;

    return AnimatedBuilder(
      animation: _flightController,
      builder: (context, child) {
        final raw = _flightController.value;
        final t = Curves.easeInOutCubic.transform(raw);
        final left = lerpDouble(startLeft, endRect.left, t)!;
        final top = lerpDouble(startTop, endRect.top, t)!;
        final size = lerpDouble(startSize, endRect.width, t)!;
        final angle = -3 * math.pi / 2 * (1 - t);
        // Bump sutil al final (último 15% del vuelo).
        final bump = raw < 0.85
            ? 1.0
            : 1.0 + 0.05 * math.sin((raw - 0.85) / 0.15 * math.pi);

        return Positioned(
          left: left,
          top: top,
          width: size,
          height: size,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: bump, child: child),
          ),
        );
      },
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.blur_on, color: AppColors.acentoBronce),
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
              color: AppColors.superficiePorcelana,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.acentoBronce,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.superficiePorcelana.withValues(alpha: 0.10),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.acentoBronce,
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
