import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'data/services/auth_service.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/inventory/inventory_scanner_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/logo_splash.dart';
import 'widgets/animated_bokeh_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventFlow AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Bokeh detrás de TODAS las rutas: nunca se reinicia entre pantallas.
      builder: (context, child) {
        return Stack(
          children: [
            const Positioned.fill(child: AnimatedBokehBackground()),
            if (child != null) Positioned.fill(child: child),
          ],
        );
      },
      home: const SplashGate(),
      routes: {
        '/inventory': (_) => const InventoryScannerScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}

/// Muestra el splash animado y, al terminar, reemplaza la ruta por AuthGate
/// con una transición suave (fade + Hero del logo).
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  void _handleSplashFinished() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthGate(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LogoSplash(onFinished: _handleSplashFinished);
  }
}

/// Decide qué pantalla mostrar según si hay sesión activa o no.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
