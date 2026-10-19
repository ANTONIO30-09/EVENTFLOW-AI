import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_back_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late final Future<UserModel?> _profileFuture;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.fetchCurrentUserProfile();
  }

  Future<void> _handleSignOut() async {
    setState(() => _signingOut = true);
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _signingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cerrar sesión',
            style: GoogleFonts.inter(color: AppColors.superficiePorcelana),
          ),
          backgroundColor: AppColors.alertaLadrillo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const CustomBackButton(),
                  const SizedBox(width: 8),
                  Text(
                    'Perfil',
                    style: GoogleFonts.fraunces(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.acentoBronce,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<UserModel?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.acentoBronce,
                      ),
                    );
                  }
                  final profile = snapshot.data;
                  if (profile == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No se pudo cargar el perfil del usuario.',
                          style: GoogleFonts.inter(
                            color: AppColors.textoSecundarioGris,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return _buildProfileBody(profile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBody(UserModel profile) {
    final roleLabel = profile.isOrganizador
        ? 'Organizador'
        : 'Personal de Campo';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Placeholder para la fotografía futura
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.superficiePorcelana.withValues(alpha: 0.15),
                        AppColors.fondoAzulNoche.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 120,
                      color: AppColors.superficiePorcelana.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                ),
                // Información del usuario
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        profile.name,
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.superficiePorcelana,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.superficiePorcelana.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.acentoBronce,
                            width: 1,
                          ),
                          color: AppColors.acentoBronce.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          roleLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.acentoBronce,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _signingOut ? null : _handleSignOut,
              icon: _signingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.fondoAzulNoche,
                      ),
                    )
                  : const Icon(Icons.logout),
              label: Text(
                _signingOut ? 'Cerrando sesión...' : 'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acentoBronce,
                foregroundColor: AppColors.fondoAzulNoche,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
