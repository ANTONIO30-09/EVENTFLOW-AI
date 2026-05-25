import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boda Señor Alberto Gonzales',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Boda Salon Principal',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Fecha y Ubicación
              const Text(
                'Hoy - Viernes 24 Abril - 19:00 Cochabamba',
                style: TextStyle(
                  color: Colors.black26,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 15),
              
              // Título central duplicado del mockup
              const Center(
                child: Text(
                  'Boda Señor\nAlberto Gonzales',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Bloque de Bloques Informativos Blancos (Invitados, Llegaron, Items)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('100', 'Invitados'),
                  _buildStatCard('70', 'Llegaron'),
                  _buildStatCard('200', 'Items'),
                ],
              ),
              const SizedBox(height: 40),

              // Sección: Progreso del Evento
              const Text(
                'PROGRESO DEL EVENTO',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 25),

              // Barra 1: Check-In (Azul)
              _buildProgressBar(
                label: 'Check-In', 
                percentage: 0.70, 
                percentText: '70%', 
                color: const Color(0xFF0081C9)
              ),
              const SizedBox(height: 20),

              // Barra 2: Inventario (Verde)
              _buildProgressBar(
                label: 'Inventario', 
                percentage: 0.90, 
                percentText: '90%', 
                color: const Color(0xFF00C897)
              ),
              const SizedBox(height: 20),

              // Barra 3: Montaje (Rojo)
              _buildProgressBar(
                label: 'Montaje', 
                percentage: 1.0, 
                percentText: '100%', 
                color: Colors.red
              ),
            ],
          ),
        ),
      ),
      
      // Menú de navegación inferior consistente
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Tarjetas informativas superiores (Invitados, Llegaron, etc.)
  Widget _buildStatCard(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Creador de Barras de Progreso Dinámicas
  Widget _buildProgressBar({
    required String label, 
    required double percentage, 
    required String percentText, 
    required Color color
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 14,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 15),
        SizedBox(
          width: 45,
          child: Text(
            percentText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12, width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(label: 'Eventos', isSelected: true),
          _buildNavItem(label: 'Inventario', isSelected: false),
          _buildNavItem(label: 'Perfil', isSelected: false),
        ],
      ),
    );
  }

  Widget _buildNavItem({required String label, required bool isSelected}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 75,
          height: 12,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : const Color(0xFFB0B0B0),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}