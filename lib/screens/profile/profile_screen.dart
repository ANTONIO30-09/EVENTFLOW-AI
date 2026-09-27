import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

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
          content: Text('Error al cerrar sesión',
              style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
          backgroundColor: AppColors.alertaLadrillo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: FutureBuilder<UserModel?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.acentoBronce),
            );
          }
          final profile = snapshot.data;
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar el perfil del usuario.',
                  style: GoogleFonts.inter(color: AppColors.textoSecundarioGris),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _buildProfileBody(profile);
        },
      ),
    );
  }

  Widget _buildProfileBody(UserModel profile) {
    final roleLabel = profile.isOrganizador ? 'Organizador' : 'Personal de Campo';
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.black,
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  color: AppColors.superficiePorcelana,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              profile.name,
              style: GoogleFonts.fraunces(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.acentoBronce,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              profile.email,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textoSecundarioGris,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.acentoBronce, width: 1),
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
            const SizedBox(height: 48),
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
      ),
    );
  }
}
