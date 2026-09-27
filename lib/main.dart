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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const SplashGate(),
      routes: {
        '/inventory': (_) => const InventoryScannerScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}

/// Muestra el splash animado y, al terminar, pasa al AuthGate.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return LogoSplash(
        onFinished: () {
          if (mounted) setState(() => _splashDone = true);
        },
      );
    }
    return const AuthGate();
  }
}

/// Decide qué pantalla mostrar según si hay sesión activa o no.
/// Escucha authStateChanges: cuando el login tiene éxito, cambia
/// solo a HomeScreen, sin necesidad de navegación manual.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
