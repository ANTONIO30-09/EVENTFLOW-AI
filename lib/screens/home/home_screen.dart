import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'event_detail_screen.dart'; // 👈 Importación agregada para la navegación

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de Bienvenida
              const Text(
                'Bienvenido.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
              const Text(
                'Antonio Garcia.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.1,
                ),
              ),
              const Text(
                'Personal de Campo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 20),

              // Barra de Búsqueda (Cápsula Negra)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar Evento',
                    hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                    border: InputBorder.none,
                    suffixIcon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Listado de Eventos (Scrollable)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text(
                      'Hoy - Viernes 24 Abril',
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Tarjeta: Boda Señor Alberto Gonzales
                    _buildEventCard(
                      title: 'Boda Señor\nAlberto\nGonzales',
                      timeInfo: '19:00 Salon Principal 100 inivitados',
                      status: 'En curso',
                      isActive: true,
                      context: context, // 👈 Context asignado
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      'Proximos Eventos',
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tarjeta: 15 Años Joven Celeste Garcia
                    _buildEventCard(
                      title: '15 Años\nJoven Celeste\nGarcia',
                      timeInfo: 'Domigo 26 Abr 20:00 Salon Principal 45 inivitados',
                      status: 'Proximo',
                      isActive: false,
                      context: context, // 👈 Context asignado
                    ),
                    const SizedBox(height: 15),

                    // Tarjeta: Evento Empresarial ELFEC
                    _buildEventCard(
                      title: 'Evento\nEmpresarial\nELFEC',
                      timeInfo: 'Martes 28 Abr 21:00 Salon Principal 120 inivitados',
                      status: 'Proximo',
                      isActive: false,
                      context: context, // 👈 Context asignado
                    ),
                    const SizedBox(height: 15),

                    // Tarjeta: Graduacion Joven Eric Morales
                    _buildEventCard(
                      title: 'Graduacion\nJoven\nEric Morales',
                      timeInfo: 'Sabado 2 May 19:00 Salon Principal 50 inivitados',
                      status: 'Proximo',
                      isActive: false,
                      context: context, // 👈 Context asignado
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Barra de Navegación Inferior idéntica al Mockup
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Constructor de las Tarjetas de Eventos con su degradado y bordes particulares
  Widget _buildEventCard({
    required String title,
    required String timeInfo,
    required String status,
    required bool isActive,
    required BuildContext context, // 👈 Parámetro requerido agregado con éxito
  }) {
    return GestureDetector(
      onTap: () {
        // Si el título contiene 'Alberto', ejecutamos el salto de pantalla
        if (title.contains('Alberto')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventDetailScreen()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFC4BDB0), // Tono grisáceo/crema del mockup
              Color(0xFF9E988F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Línea negra vertical distintiva al lado izquierdo
            Positioned(
              left: 0,
              top: 15,
              bottom: 15,
              child: Container(
                width: 4,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.1,
                          ),
                        ),
                      ),
                      // Badge de Estado (En curso / Proximo)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    timeInfo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Barra de navegación personalizada
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