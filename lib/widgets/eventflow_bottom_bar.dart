// lib/widgets/eventflow_bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:eventflow_ai/core/constants/app_colors.dart';

class EventFlowBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const EventFlowBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Altura personalizada para acomodar las barras y el texto
      decoration: const BoxDecoration(
        color: AppColors.background, // Mismo fondo crema de la pantalla
        // Línea divisoria negra arriba
        border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Espaciado equitativo
          children: [
            _buildNavItem(context, 0, 'Eventos'),
            _buildNavItem(context, 1, 'Inventario'),
            _buildNavItem(context, 2, 'Perfil'),
          ],
        ),
      ),
    );
  }

  // Componente de botón de navegación individual
  Widget _buildNavItem(BuildContext context, int index, String label) {
    final bool isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap?.call(index),
      behavior: HitTestBehavior.opaque, // Hace que toda el área sea clicleable
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // La píldora indicadora superior (Negra si seleccionado, Gris si no)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80, // Ancho de la píldora
            height: isSelected ? 8 : 4, // Más gruesa si seleccionada
            decoration: BoxDecoration(
              color: isSelected ? AppColors.bottomBarIndicatorSelected : AppColors.bottomBarIndicatorUnselected,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8), // Separación
          // Texto de la opción
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black, // Siempre negro bold en tu mockup
            ),
          ),
        ],
      ),
    );
  }
}