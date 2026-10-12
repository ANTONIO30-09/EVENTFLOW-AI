// AdminShell — layout raíz del Panel de Administración (solo web).
//
// - Pantalla ancha (>= 900 px): sidebar fija a la izquierda (vidrio oscuro,
//   blur 22) + área de contenido a la derecha, centrada con maxWidth 1200.
// - Pantalla angosta (< 900 px): la sidebar pasa a un Drawer con botón
//   hamburguesa en el AppBar.
//
// El Scaffold es transparente para dejar ver el bokeh global que la app
// dibuja detrás de todas las rutas (MaterialApp.builder).
//
// Este archivo NO importa Firebase ni servicios. Las listas de eventos y
// usuarios viven en memoria (copias mutables de los mock) y se pasan a las
// páginas de cada módulo cuando se implementen en las etapas siguientes.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import 'admin_mock_data.dart';
import 'admin_events_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  /// Índice del módulo activo: 0=Eventos, 1=Reportes, 2=Usuarios.
  int _index = 0;

  /// Copias mutables de los mock. Los módulos hijos las reciben por
  /// constructor y las mutan con setState (a partir de la etapa b).
  // ignore: unused_field (se usa en etapa b)
  late List<AdminEvent> _events;
  // ignore: unused_field (se usa en etapa b)
  late List<AdminUser> _users;

  @override
  void initState() {
    super.initState();
    _events = crearEventosMock();
    _users = crearUsuariosMock();
  }

  // -------------------------------------------------------------------------
  // Metadata de los módulos
  // -------------------------------------------------------------------------

  static const _modulos = <_ModuloInfo>[
    _ModuloInfo(
      titulo: 'Gestión de eventos',
      subtitulo: 'Crea, edita y organiza los eventos de la plataforma.',
      icono: Icons.event_note_outlined,
    ),
    _ModuloInfo(
      titulo: 'Reportes y métricas',
      subtitulo: 'KPIs, invitados por evento y progreso de check-in.',
      icono: Icons.insights_outlined,
    ),
    _ModuloInfo(
      titulo: 'Usuarios y staff',
      subtitulo: 'Administra roles y accesos del equipo.',
      icono: Icons.groups_outlined,
    ),
  ];

  // -------------------------------------------------------------------------
  // Navegación
  // -------------------------------------------------------------------------

  void _seleccionarModulo(int i) {
    setState(() => _index = i);
  }

  void _volverALaApp() {
    // La app abre el panel con Navigator.pushNamed(context, '/admin'), así
    // que pop regresa al usuario a la pantalla anterior sin reproducir el
    // splash de '/' (que es un SplashGate).
    Navigator.pop(context);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: LayoutBuilder(
        builder: (context, constraints) {
          // Drawer solo se usa en modo angosto; en ancho no se abre.
          if (constraints.maxWidth >= 900) return const SizedBox.shrink();
          return Drawer(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: _Sidebar(
              indexActivo: _index,
              modulos: _modulos,
              onSeleccionar: (i) {
                Navigator.pop(context); // cierra el drawer
                _seleccionarModulo(i);
              },
              onVolver: _volverALaApp,
            ),
          );
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;
          if (ancho >= 900) {
            return Row(
              children: [
                SizedBox(
                  width: 260,
                  child: _Sidebar(
                    indexActivo: _index,
                    modulos: _modulos,
                    onSeleccionar: _seleccionarModulo,
                    onVolver: _volverALaApp,
                  ),
                ),
                Expanded(child: _contenido()),
              ],
            );
          }
          // Modo angosto: AppBar transparente + Drawer.
          return Column(
            children: [
              _appBarAngosta(),
              Expanded(child: _contenido()),
            ],
          );
        },
      ),
    );
  }

  Widget _appBarAngosta() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 8,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.superficiePorcelana),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        'EventFlow AI · Panel',
        style: GoogleFonts.fraunces(
          color: AppColors.superficiePorcelana,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _contenido() {
    final modulo = _modulos[_index];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _encabezado(modulo),
                const SizedBox(height: 24),
                _moduloContenido(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(_ModuloInfo modulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          modulo.titulo,
          style: GoogleFonts.fraunces(
            color: AppColors.superficiePorcelana,
            fontSize: 34,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          modulo.subtitulo,
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.75),
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Placeholder temporal del módulo activo. En las etapas (b), (c) y (d)
  /// se reemplaza por las páginas reales (AdminEventsPage, AdminReportsPage,
  /// AdminUsersPage) recibiendo _events y _users por constructor.
  Widget _moduloContenido() {
    switch (_index) {
      case 0:
        return AdminEventsPage(
          events: _events,
          onChanged: () => setState(() {}),
        );
      default:
        return _placeholderModulo(_modulos[_index]);
    }
  }

  Widget _placeholderModulo(_ModuloInfo modulo) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(modulo.icono, color: AppColors.acentoBronce, size: 22),
              const SizedBox(width: 10),
              Text(
                modulo.titulo,
                style: GoogleFonts.fraunces(
                  color: AppColors.superficiePorcelana,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Módulo en construcción. Se implementa en la siguiente etapa.',
            style: GoogleFonts.inter(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sidebar / Drawer
// ---------------------------------------------------------------------------

class _ModuloInfo {
  const _ModuloInfo({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.indexActivo,
    required this.modulos,
    required this.onSeleccionar,
    required this.onVolver,
  });

  final int indexActivo;
  final List<_ModuloInfo> modulos;
  final ValueChanged<int> onSeleccionar;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    // Fondo de vidrio oscuro: blur 22 y azul-noche alpha 0.72.
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.fondoAzulNoche.withValues(alpha: 0.72),
            border: Border(
              right: BorderSide(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.16),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logo(),
                  const SizedBox(height: 36),
                  ...List.generate(modulos.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _NavItem(
                        info: modulos[i],
                        activo: i == indexActivo,
                        onTap: () => onSeleccionar(i),
                      ),
                    );
                  }),
                  const Spacer(),
                  _botonVolver(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EventFlow AI',
          style: GoogleFonts.fraunces(
            color: AppColors.superficiePorcelana,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Panel de administración',
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.65),
            fontSize: 12,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _botonVolver() {
    return TextButton.icon(
      onPressed: onVolver,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.superficiePorcelana.withValues(alpha: 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.22),
          ),
        ),
      ),
      icon: const Icon(Icons.arrow_back_ios_new, size: 14),
      label: Text(
        'Volver a la app',
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.info,
    required this.activo,
    required this.onTap,
  });

  final _ModuloInfo info;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorTexto = activo
        ? AppColors.superficiePorcelana
        : AppColors.superficiePorcelana.withValues(alpha: 0.72);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: activo
                ? AppColors.superficiePorcelana.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: activo ? AppColors.acentoBronce : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(info.icono, size: 20, color: colorTexto),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: colorTexto,
                    fontSize: 14,
                    fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
