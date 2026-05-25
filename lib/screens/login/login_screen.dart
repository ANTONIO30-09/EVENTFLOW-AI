import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Oficial
                  Image.asset(
                    'assets/images/logo.png',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.blur_on, size: 120, color: AppColors.textDark);
                    },
                  ),
                  const SizedBox(height: 25),
                  
                  // Título principal (Itálico y Negrita)
                  const Text(
                    'EventFlow AI',
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.w900, 
                      fontStyle: FontStyle.italic, 
                      color: AppColors.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  
                  // Subtítulo
                  const Text(
                    'Sistema de Logística de Eventos',
                    style: TextStyle(
                      fontSize: 18, 
                       color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 45),

                  // Input de Usuario
                  _buildInputField(hintText: 'USUARIO'),
                  const SizedBox(height: 20),

                  // Input de Contraseña
                  _buildInputField(hintText: 'CONTRASEÑA', isObscure: true),
                  const SizedBox(height: 45),

                  // Botón Iniciar Sesión (Ovalado, crema claro con sombra tenue)
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí conectarás la lógica o navegación posterior
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBF7EE), // Botón blanquecino/crema
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                        side: BorderSide(color: Colors.black.withValues(alpha: 0.1), width: 1),
                      ),
                      child: const Text(
                        'Iniciar Sesion', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Enlace de recuperación (Respetando el texto exacto de tu diseño)
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿Olvidadte tu Contraseña ?', 
                      style: TextStyle(
                        color: AppColors.textDark, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  // Generador de campos de texto idénticos a tus campos ovalados
  Widget _buildInputField({required String hintText, bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        obscureText: isObscure,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        cursorColor: AppColors.textDark,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          filled: true,
          fillColor: AppColors.surfaceCard, // Color crema intermedio de los inputs
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35),
            borderSide: const BorderSide(color: AppColors.textDark, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35),
            borderSide: const BorderSide(color: AppColors.textDark, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(35),
            borderSide: const BorderSide(color: AppColors.textDark, width: 1.8),
          ),
        ),
      ),
    );
  }
}
