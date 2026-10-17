// AdminUsersPage — módulo "Usuarios y staff" del Panel de Administración.
//
// DATOS SIMULADOS: la lista de usuarios vive en AdminShell y se pasa por
// constructor. La página la muta directamente (cambio de rol) y avisa al
// shell con onChanged() para que re-renderice. No toca Firebase.
//
// RENDIMIENTO: todo el contenido va dentro de UN solo GlassCard. Las filas
// de la tabla/lista NO son GlassCard, son containers planos.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import 'admin_mock_data.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({
    super.key,
    required this.users,
    required this.onChanged,
  });

  /// Lista mutable de usuarios (vive en AdminShell; la página la muta).
  final List<AdminUser> users;

  /// Callback para avisar al shell que hubo cambios y forzar su setState.
  final VoidCallback onChanged;

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _colorRol(UserRole rol) {
    switch (rol) {
      case UserRole.organizador:
        return AppColors.acentoBronce;
      case UserRole.staff:
        return AppColors.textoSecundarioGris;
    }
  }

  /// Iniciales para el avatar: 2 letras máximo.
  String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '?';
    final primera = partes.first.isNotEmpty ? partes.first[0] : '';
    final segunda = partes.length > 1 && partes.last.isNotEmpty
        ? partes.last[0]
        : '';
    final s = (primera + segunda).toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  Future<void> _abrirDetalle(AdminUser user) async {
    final accion = await showDialog<_AccionRol>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _UserDetailDialog(user: user),
    );
    if (accion == null) return;
    if (!mounted) return;

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ConfirmRoleChangeDialog(
        nombre: user.nombre,
        accion: accion,
      ),
    );
    if (confirmado != true) return;

    setState(() {
      user.rol = accion == _AccionRol.ascender
          ? UserRole.organizador
          : UserRole.staff;
    });
    widget.onChanged();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _barraAcciones(),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: widget.users.isEmpty ? _estadoVacio() : _contenidoLista(),
        ),
      ],
    );
  }

  Widget _barraAcciones() {
    final total = widget.users.length;
    final organizadores =
        widget.users.where((u) => u.rol == UserRole.organizador).length;
    final staff = total - organizadores;

    return LayoutBuilder(
      builder: (context, constraints) {
        final resumen = Text(
          '$total ${total == 1 ? "usuario" : "usuarios"} · '
          '$organizadores ${organizadores == 1 ? "organizador" : "organizadores"} · '
          '$staff staff',
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(
            color: AppColors.textoSecundarioGris,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        );
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: resumen,
            ),
          ),
        );
      },
    );
  }

  Widget _estadoVacio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No hay usuarios todavía.',
            style: GoogleFonts.fraunces(
              color: AppColors.superficiePorcelana,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando existan usuarios en el sistema aparecerán acá.',
            style: GoogleFonts.inter(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenidoLista() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return _tablaAncha();
        }
        return _listaAngosta();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tabla (ancho)
  // ---------------------------------------------------------------------------

  Widget _tablaAncha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cabeceraTabla(),
        const SizedBox(height: 6),
        Divider(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.12),
            height: 1),
        ...widget.users.map(_filaTabla),
      ],
    );
  }

  Widget _cabeceraTabla() {
    final celda = GoogleFonts.inter(
      color: AppColors.textoSecundarioGris,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('NOMBRE', style: celda)),
          Expanded(flex: 5, child: Text('CORREO', style: celda)),
          Expanded(flex: 3, child: Text('ROL', style: celda)),
          SizedBox(
            width: 120,
            child: Text('ACCIONES', style: celda, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _filaTabla(AdminUser u) {
    final colorTexto = AppColors.superficiePorcelana;
    final colorSec = AppColors.superficiePorcelana.withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _avatar(u),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    u.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        color: colorTexto, fontSize: 13.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              u.correo,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: colorSec, fontSize: 13),
            ),
          ),
          Expanded(flex: 3, child: _chipRol(u.rol)),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerRight,
              child: _botonDetalle(u),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lista (angosto)
  // ---------------------------------------------------------------------------

  Widget _listaAngosta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final u in widget.users) _filaAngosta(u),
      ],
    );
  }

  Widget _filaAngosta(AdminUser u) {
    final colorTexto = AppColors.superficiePorcelana;
    final colorSec = AppColors.superficiePorcelana.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _avatar(u),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.nombre,
                      style: GoogleFonts.fraunces(
                        color: colorTexto,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u.correo,
                      style: GoogleFonts.inter(color: colorSec, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _chipRol(u.rol),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _botonDetalle(u),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Comunes
  // ---------------------------------------------------------------------------

  Widget _avatar(AdminUser u) {
    final color = _colorRol(u.rol);
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _iniciales(u.nombre),
        style: GoogleFonts.fraunces(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _chipRol(UserRole rol) {
    final color = _colorRol(rol);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          etiquetaRol(rol).toUpperCase(),
          style: GoogleFonts.inter(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _botonDetalle(AdminUser u) {
    return TextButton.icon(
      onPressed: () => _abrirDetalle(u),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.acentoBronce,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.visibility_outlined, size: 16),
      label: Text(
        'Ver detalle',
        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Enums de acción
// ---------------------------------------------------------------------------

enum _AccionRol { ascender, degradar }

// ---------------------------------------------------------------------------
// Diálogo: detalle del usuario
// ---------------------------------------------------------------------------

class _UserDetailDialog extends StatelessWidget {
  const _UserDetailDialog({required this.user});
  final AdminUser user;

  Color _colorRol(UserRole rol) {
    switch (rol) {
      case UserRole.organizador:
        return AppColors.acentoBronce;
      case UserRole.staff:
        return AppColors.textoSecundarioGris;
    }
  }

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '?';
    final primera = partes.first.isNotEmpty ? partes.first[0] : '';
    final segunda = partes.length > 1 && partes.last.isNotEmpty
        ? partes.last[0]
        : '';
    final s = (primera + segunda).toUpperCase();
    return s.isEmpty ? '?' : s;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorRol(user.rol);
    final esOrganizador = user.rol == UserRole.organizador;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + nombre
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _iniciales(user.nombre),
                      style: GoogleFonts.fraunces(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nombre,
                          style: GoogleFonts.fraunces(
                            color: AppColors.superficiePorcelana,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.correo,
                          style: GoogleFonts.inter(
                            color: AppColors.superficiePorcelana
                                .withValues(alpha: 0.75),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Chip rol
              Row(
                children: [
                  _chipRol(user.rol),
                  const SizedBox(width: 10),
                  Text(
                    'ID local: ${user.id}',
                    style: GoogleFonts.inter(
                      color: AppColors.superficiePorcelana.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(
                  color: AppColors.superficiePorcelana.withValues(alpha: 0.12),
                  height: 1),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          AppColors.superficiePorcelana.withValues(alpha: 0.75),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    child: Text(
                      'Cerrar',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (esOrganizador)
                    _botonOutline(
                      context,
                      label: 'Pasar a staff',
                      color: AppColors.alertaLadrillo,
                      onTap: () => Navigator.of(context)
                          .pop(_AccionRol.degradar),
                    )
                  else
                    _botonRelleno(
                      context,
                      label: 'Ascender a organizador',
                      color: AppColors.acentoBronce,
                      colorTexto: AppColors.fondoAzulNoche,
                      onTap: () => Navigator.of(context)
                          .pop(_AccionRol.ascender),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipRol(UserRole rol) {
    final color = _colorRol(rol);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        etiquetaRol(rol).toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _botonRelleno(
    BuildContext context, {
    required String label,
    required Color color,
    required Color colorTexto,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: colorTexto,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonOutline(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diálogo: confirmación de cambio de rol
// ---------------------------------------------------------------------------

class _ConfirmRoleChangeDialog extends StatelessWidget {
  const _ConfirmRoleChangeDialog({
    required this.nombre,
    required this.accion,
  });

  final String nombre;
  final _AccionRol accion;

  @override
  Widget build(BuildContext context) {
    final esAscender = accion == _AccionRol.ascender;
    final titulo = esAscender
        ? 'Cambiar rol de "$nombre"'
        : 'Quitar permisos de organizador';
    final cuerpo = esAscender
        ? 'Estás por dar permisos de organizador a esta persona. Podrá crear, editar y eliminar eventos, además de administrar a otros usuarios. Esta acción es sensible.'
        : 'Estás por quitarle los permisos de organizador a "$nombre". Pasará a staff y perderá acceso a la gestión de eventos y usuarios. Esta acción es sensible.';
    final labelConfirmar = esAscender ? 'Ascender' : 'Pasar a staff';
    final colorConfirmar =
        esAscender ? AppColors.acentoBronce : AppColors.alertaLadrillo;
    final colorTextoConfirmar = esAscender
        ? AppColors.fondoAzulNoche
        : AppColors.superficiePorcelana;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    esAscender
                        ? Icons.arrow_upward
                        : Icons.warning_amber_rounded,
                    color: colorConfirmar,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      titulo,
                      style: GoogleFonts.fraunces(
                        color: AppColors.superficiePorcelana,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cuerpo,
                style: GoogleFonts.inter(
                  color: AppColors.superficiePorcelana.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          AppColors.superficiePorcelana.withValues(alpha: 0.75),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: colorConfirmar,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Text(
                          labelConfirmar,
                          style: GoogleFonts.inter(
                            color: colorTextoConfirmar,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
