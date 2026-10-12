// AdminEventsPage — módulo "Gestión de eventos" del Panel de Administración.
//
// DATOS SIMULADOS: la lista de eventos vive en AdminShell y se pasa por
// constructor. La página la muta directamente (agregar/quitar/editar) y
// avisa al shell con onChanged() para que re-renderice. No toca Firebase.
//
// RENDIMIENTO: todo el contenido va dentro de UN solo GlassCard. Las filas
// de la tabla/lista NO son GlassCard, son containers planos.
//
// El encabezado (título + subtítulo) lo dibuja AdminShell; esta página solo
// aporta la barra de acciones y el contenido.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import 'admin_mock_data.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({
    super.key,
    required this.events,
    required this.onChanged,
  });

  /// Lista mutable de eventos (vive en AdminShell; la página la muta).
  final List<AdminEvent> events;

  /// Callback para avisar al shell que hubo cambios y forzar su setState.
  final VoidCallback onChanged;

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Formatea una fecha como dd/mm/aaaa sin depender de intl.
  String _formatFecha(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  /// Genera un id local único para eventos nuevos (no persiste).
  String _nuevoId() => 'ev-${DateTime.now().microsecondsSinceEpoch}';

  // ---------------------------------------------------------------------------
  // Acciones
  // ---------------------------------------------------------------------------

  Future<void> _abrirFormulario({AdminEvent? existente}) async {
    final resultado = await showDialog<_EventoFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EventoFormDialog(existente: existente),
    );
    if (resultado == null) return;

    setState(() {
      if (existente == null) {
        // Crear
        widget.events.add(
          AdminEvent(
            id: _nuevoId(),
            nombre: resultado.nombre,
            fecha: resultado.fecha,
            lugar: resultado.lugar,
            estado: resultado.estado,
            invitados: resultado.invitados,
          ),
        );
      } else {
        // Editar in-place
        existente.nombre = resultado.nombre;
        existente.fecha = resultado.fecha;
        existente.lugar = resultado.lugar;
        existente.estado = resultado.estado;
        existente.invitados = resultado.invitados;
      }
    });
    widget.onChanged();
  }

  Future<void> _confirmarEliminar(AdminEvent evento) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ConfirmDeleteDialog(nombre: evento.nombre),
    );
    if (ok != true) return;
    setState(() {
      widget.events.remove(evento);
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
          child: widget.events.isEmpty ? _estadoVacio() : _contenidoTabla(),
        ),
      ],
    );
  }

  Widget _barraAcciones() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contador = Text(
          '${widget.events.length} ${widget.events.length == 1 ? "evento" : "eventos"}',
          style: GoogleFonts.inter(
            color: AppColors.textoSecundarioGris,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        );
        final boton = _botonPrimario(
          label: 'Nuevo evento',
          icon: Icons.add,
          onTap: () => _abrirFormulario(),
        );
        // En ancho: botón a la izquierda, contador a la derecha.
        // En angosto: botón arriba, contador abajo (wrap).
        if (constraints.maxWidth >= 480) {
          return Row(
            children: [boton, const Spacer(), contador],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [boton, const SizedBox(height: 8), contador],
        );
      },
    );
  }

  Widget _botonPrimario({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.acentoBronce,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.fondoAzulNoche, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.fondoAzulNoche,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _estadoVacio() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No hay eventos todavía.',
            style: GoogleFonts.fraunces(
              color: AppColors.superficiePorcelana,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea el primero con el botón "Nuevo evento" de arriba.',
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

  Widget _contenidoTabla() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        if (ancho >= 760) {
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
        Divider(color: AppColors.superficiePorcelana.withValues(alpha: 0.12), height: 1),
        ...widget.events.map(_filaTabla),
      ],
    );
  }

  Widget _cabeceraTabla() {
    const estilo = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );
    final celda = GoogleFonts.inter(
      color: AppColors.textoSecundarioGris,
      fontSize: estilo.fontSize,
      fontWeight: estilo.fontWeight,
      letterSpacing: estilo.letterSpacing,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('NOMBRE', style: celda)),
          Expanded(flex: 2, child: Text('FECHA', style: celda)),
          Expanded(flex: 4, child: Text('LUGAR', style: celda)),
          Expanded(flex: 2, child: Text('ESTADO', style: celda)),
          Expanded(flex: 2, child: Text('INVITADOS', style: celda, textAlign: TextAlign.right)),
          SizedBox(width: 88, child: Text('ACCIONES', style: celda, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _filaTabla(AdminEvent e) {
    final colorTexto = AppColors.superficiePorcelana;
    final colorSec = AppColors.superficiePorcelana.withValues(alpha: 0.75);
    final estilo = GoogleFonts.inter(color: colorTexto, fontSize: 13);
    final estiloSec = GoogleFonts.inter(color: colorSec, fontSize: 13);

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
            flex: 3,
            child: Text(e.nombre, style: estilo, overflow: TextOverflow.ellipsis),
          ),
          Expanded(flex: 2, child: Text(_formatFecha(e.fecha), style: estiloSec)),
          Expanded(
            flex: 4,
            child: Text(e.lugar, style: estiloSec, overflow: TextOverflow.ellipsis),
          ),
          Expanded(flex: 2, child: _estadoPunto(e.estado)),
          Expanded(
            flex: 2,
            child: Text('${e.invitados}', style: estilo, textAlign: TextAlign.right),
          ),
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _iconoAccion(
                  icon: Icons.edit_outlined,
                  color: AppColors.acentoBronce,
                  onTap: () => _abrirFormulario(existente: e),
                ),
                _iconoAccion(
                  icon: Icons.delete_outline,
                  color: AppColors.alertaLadrillo,
                  onTap: () => _confirmarEliminar(e),
                ),
              ],
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
        for (final e in widget.events) _filaAngosta(e),
      ],
    );
  }

  Widget _filaAngosta(AdminEvent e) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  e.nombre,
                  style: GoogleFonts.fraunces(
                    color: colorTexto,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _iconoAccion(
                icon: Icons.edit_outlined,
                color: AppColors.acentoBronce,
                onTap: () => _abrirFormulario(existente: e),
              ),
              _iconoAccion(
                icon: Icons.delete_outline,
                color: AppColors.alertaLadrillo,
                onTap: () => _confirmarEliminar(e),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 13, color: colorSec),
              const SizedBox(width: 6),
              Text(_formatFecha(e.fecha),
                  style: GoogleFonts.inter(color: colorSec, fontSize: 12)),
              const SizedBox(width: 14),
              _estadoPunto(e.estado),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 13, color: colorSec),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  e.lugar,
                  style: GoogleFonts.inter(color: colorSec, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people_outline, size: 13, color: colorSec),
              const SizedBox(width: 6),
              Text('${e.invitados} invitados',
                  style: GoogleFonts.inter(color: colorSec, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Comunes
  // ---------------------------------------------------------------------------

  Widget _estadoPunto(EventStatus estado) {
    final color = colorEstado(estado);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          etiquetaEstado(estado),
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _iconoAccion({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 18, color: color),
      onPressed: onTap,
      splashRadius: 18,
      tooltip: null,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(6),
    );
  }
}

// ---------------------------------------------------------------------------
// Diálogo de crear/editar
// ---------------------------------------------------------------------------

class _EventoFormResult {
  _EventoFormResult({
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.estado,
    required this.invitados,
  });

  final String nombre;
  final DateTime fecha;
  final String lugar;
  final EventStatus estado;
  final int invitados;
}

class _EventoFormDialog extends StatefulWidget {
  const _EventoFormDialog({this.existente});

  final AdminEvent? existente;

  @override
  State<_EventoFormDialog> createState() => _EventoFormDialogState();
}

class _EventoFormDialogState extends State<_EventoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _lugarCtrl;
  late final TextEditingController _invitadosCtrl;
  late DateTime _fecha;
  late EventStatus _estado;

  @override
  void initState() {
    super.initState();
    final e = widget.existente;
    _nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    _lugarCtrl = TextEditingController(text: e?.lugar ?? '');
    _invitadosCtrl =
        TextEditingController(text: e == null ? '' : e.invitados.toString());
    _fecha = e?.fecha ?? DateTime.now();
    _estado = e?.estado ?? EventStatus.planificacion;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _lugarCtrl.dispose();
    _invitadosCtrl.dispose();
    super.dispose();
  }

  String _formatFecha(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(ahora.year - 2),
      lastDate: DateTime(ahora.year + 5),
      helpText: 'Seleccionar fecha del evento',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.acentoBronce,
              brightness: Brightness.dark,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (elegida != null) {
      setState(() => _fecha = elegida);
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _EventoFormResult(
        nombre: _nombreCtrl.text.trim(),
        fecha: _fecha,
        lugar: _lugarCtrl.text.trim(),
        estado: _estado,
        invitados: int.parse(_invitadosCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.existente != null;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    esEdicion ? 'Editar evento' : 'Nuevo evento',
                    style: GoogleFonts.fraunces(
                      color: AppColors.superficiePorcelana,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esEdicion
                        ? 'Modifica los datos del evento.'
                        : 'Completa los datos para crear un evento.',
                    style: GoogleFonts.inter(
                      color: AppColors.superficiePorcelana.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _campo(
                    label: 'Nombre',
                    controller: _nombreCtrl,
                    hint: 'Boda Valeria & Andrés',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el nombre del evento'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _campoFecha(),
                  const SizedBox(height: 14),
                  _campo(
                    label: 'Lugar',
                    controller: _lugarCtrl,
                    hint: 'Hacienda San Isidro, Quillacollo',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el lugar del evento'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _campoEstado(),
                  const SizedBox(height: 14),
                  _campo(
                    label: 'Cantidad de invitados',
                    controller: _invitadosCtrl,
                    hint: '180',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Ingresa la cantidad de invitados';
                      final n = int.tryParse(t);
                      if (n == null || n < 0) return 'Debe ser un entero ≥ 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _botonTexto(
                        label: 'Cancelar',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      _botonPrimario(
                        label: esEdicion ? 'Guardar' : 'Crear',
                        onTap: _guardar,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana,
            fontSize: 14,
          ),
          cursorColor: AppColors.acentoBronce,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.superficiePorcelana.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.acentoBronce),
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha',
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _elegirFecha,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.superficiePorcelana.withValues(alpha: 0.7)),
                const SizedBox(width: 10),
                Text(
                  _formatFecha(_fecha),
                  style: GoogleFonts.inter(
                    color: AppColors.superficiePorcelana,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _campoEstado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado',
          style: GoogleFonts.inter(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.superficiePorcelana.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<EventStatus>(
              value: _estado,
              isExpanded: true,
              dropdownColor: AppColors.fondoAzulNoche,
              iconEnabledColor: AppColors.superficiePorcelana.withValues(alpha: 0.7),
              style: GoogleFonts.inter(
                color: AppColors.superficiePorcelana,
                fontSize: 14,
              ),
              items: EventStatus.values.map((s) {
                return DropdownMenuItem<EventStatus>(
                  value: s,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorEstado(s),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(etiquetaEstado(s)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _estado = v);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonPrimario({required String label, required VoidCallback onTap}) {
    return Material(
      color: AppColors.acentoBronce,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.fondoAzulNoche,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonTexto({required String label, required VoidCallback onTap}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.superficiePorcelana.withValues(alpha: 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diálogo de confirmación de eliminación
// ---------------------------------------------------------------------------

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Eliminar evento',
                style: GoogleFonts.fraunces(
                  color: AppColors.superficiePorcelana,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '¿Seguro que quieres eliminar "$nombre"? Esta acción no se puede deshacer.',
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
                    color: AppColors.alertaLadrillo,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(true),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Text(
                          'Eliminar',
                          style: GoogleFonts.inter(
                            color: AppColors.superficiePorcelana,
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
