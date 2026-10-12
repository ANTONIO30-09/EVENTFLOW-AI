// AdminReportsPage — módulo "Reportes y métricas" del Panel de Administración.
//
// DATOS SIMULADOS: recibe la lista de eventos del shell. Es una página
// StatelessWidget: no muta nada, solo LEE y deriva KPIs en el build. Por eso,
// si el usuario crea/edita/elimina eventos en la etapa (b), al volver acá los
// números se recalculan solos (el shell re-renderiza con setState).
//
// RENDIMIENTO: 3 GlassCard en total (KPIs / barras / anillo). Las celdas de
// KPI y las barras NO son GlassCard; son containers planos.
//
// Gráficas dibujadas a mano: barras con Containers y anillo con CustomPainter.
// No se agregan paquetes.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import 'admin_mock_data.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key, required this.events});

  /// Lista de eventos (vive en AdminShell). Solo lectura.
  final List<AdminEvent> events;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final apilado = c.maxWidth < 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kpis(),
            const SizedBox(height: 16),
            if (apilado) ...[
              _barras(),
              const SizedBox(height: 16),
              _anillo(),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _barras()),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: _anillo()),
                ],
              ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------------------

  Widget _kpis() {
    final enCurso = events.where((e) => e.estado == EventStatus.enCurso).length;
    final totalInvitados = events.fold<int>(0, (s, e) => s + e.invitados);
    final totalCheckIn = events.fold<int>(0, (s, e) => s + e.checkIn);
    final totalEscaneados = events.fold<int>(0, (s, e) => s + e.itemsEscaneados);
    final pct = totalInvitados == 0
        ? 0
        : ((totalCheckIn / totalInvitados) * 100).round();

    final items = <_KpiData>[
      _KpiData(
        label: 'EVENTOS ACTIVOS',
        valor: '$enCurso',
        sub: 'de ${events.length} en total',
      ),
      _KpiData(
        label: 'INVITADOS TOTALES',
        valor: '$totalInvitados',
        sub: '${events.length} ${events.length == 1 ? "evento" : "eventos"}',
      ),
      _KpiData(
        label: '% CHECK-IN',
        valor: '$pct%',
        sub: '$totalCheckIn de $totalInvitados',
      ),
      _KpiData(
        label: 'ÍTEMS ESCANEADOS',
        valor: '$totalEscaneados',
        sub: null,
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth >= 700) {
            // Una sola fila con divisores verticales.
            return IntrinsicHeight(
              child: Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0) _divisorVertical(),
                    Expanded(child: _kpiCelda(items[i])),
                  ],
                ],
              ),
            );
          }
          // Dos filas de 2 celdas.
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _kpiCelda(items[0])),
                  _divisorVertical(),
                  Expanded(child: _kpiCelda(items[1])),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _kpiCelda(items[2])),
                  _divisorVertical(),
                  Expanded(child: _kpiCelda(items[3])),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _divisorVertical() {
    return VerticalDivider(
      width: 24,
      thickness: 1,
      color: AppColors.superficiePorcelana.withValues(alpha: 0.12),
    );
  }

  Widget _kpiCelda(_KpiData k) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          k.label,
          style: GoogleFonts.inter(
            color: AppColors.textoSecundarioGris,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          k.valor,
          style: GoogleFonts.fraunces(
            color: AppColors.superficiePorcelana,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            height: 1.05,
          ),
        ),
        if (k.sub != null) ...[
          const SizedBox(height: 4),
          Text(
            k.sub!,
            style: GoogleFonts.inter(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Gráfica de barras
  // ---------------------------------------------------------------------------

  Widget _barras() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitados por evento',
            style: GoogleFonts.fraunces(
              color: AppColors.superficiePorcelana,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${events.length} ${events.length == 1 ? "evento" : "eventos"}',
            style: GoogleFonts.inter(
              color: AppColors.superficiePorcelana.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          if (events.isEmpty)
            Text(
              'Sin datos para graficar.',
              style: GoogleFonts.inter(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            )
          else
            SizedBox(
              height: 240,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _barrasContenido(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _barrasContenido() {
    final maxInv = events
        .map((e) => e.invitados)
        .fold<int>(0, (a, b) => a > b ? a : b);
    const alturaMaxBarra = 160.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: events.map((e) {
        final factor = maxInv == 0 ? 0.0 : e.invitados / maxInv;
        final altura = alturaMaxBarra * factor;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${e.invitados}',
                style: GoogleFonts.inter(
                  color: AppColors.superficiePorcelana,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 42,
                height: altura < 2 ? 2 : altura,
                decoration: BoxDecoration(
                  color: colorEstado(e.estado),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 84,
                child: Text(
                  e.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.superficiePorcelana.withValues(alpha: 0.65),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Anillo de progreso
  // ---------------------------------------------------------------------------

  Widget _anillo() {
    final totalInv = events.fold<int>(0, (s, e) => s + e.invitados);
    final totalCheck = events.fold<int>(0, (s, e) => s + e.checkIn);
    final pct = totalInv == 0 ? 0.0 : (totalCheck / totalInv).clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso de check-in',
            style: GoogleFonts.fraunces(
              color: AppColors.superficiePorcelana,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(180, 180),
                    painter: _AnilloPainter(progreso: pct),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(pct * 100).round()}%',
                        style: GoogleFonts.fraunces(
                          color: AppColors.superficiePorcelana,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'check-in',
                        style: GoogleFonts.inter(
                          color: AppColors.superficiePorcelana
                              .withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '$totalCheck de $totalInv invitados',
              style: GoogleFonts.inter(
                color: AppColors.superficiePorcelana.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Datos auxiliares
// ---------------------------------------------------------------------------

class _KpiData {
  const _KpiData({required this.label, required this.valor, this.sub});
  final String label;
  final String valor;
  final String? sub;
}

// ---------------------------------------------------------------------------
// Painter del anillo
// ---------------------------------------------------------------------------

class _AnilloPainter extends CustomPainter {
  _AnilloPainter({required this.progreso});
  final double progreso;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = (size.shortestSide - 14) / 2;

    final fondo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = AppColors.superficiePorcelana.withValues(alpha: 0.15);
    canvas.drawCircle(centro, radio, fondo);

    if (progreso <= 0) return;

    final arco = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = AppColors.exitoVerdeSalvia;

    final rect = Rect.fromCircle(center: centro, radius: radio);
    const inicio = -math.pi / 2;
    final barrido = 2 * math.pi * progreso;
    canvas.drawArc(rect, inicio, barrido, false, arco);
  }

  @override
  bool shouldRepaint(covariant _AnilloPainter old) => old.progreso != progreso;
}
