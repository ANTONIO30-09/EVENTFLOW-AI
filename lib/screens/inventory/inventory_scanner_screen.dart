import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_item_model.dart';
import '../../data/services/database_service.dart';
import '../../widgets/neon_bottom_nav.dart';

class InventoryScannerScreen extends StatefulWidget {
  const InventoryScannerScreen({super.key});

  @override
  State<InventoryScannerScreen> createState() => _InventoryScannerScreenState();
}

class _InventoryScannerScreenState extends State<InventoryScannerScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _manualIdController = TextEditingController();
  late final MobileScannerController _scannerController;
  late final AnimationController _scanLineController;

  List<ScanItem> recentScans = [];
  bool _isProcessing = false;
  bool _showManualEntry = false;
  double _currentZoom = 0.0;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _manualIdController.dispose();
    _scannerController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  Future<void> _handleScanResult(String? rawValue) async {
    if (rawValue == null || rawValue.trim().isEmpty) return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final scanItem = await _databaseService.fetchScanItemById(
        rawValue.trim(),
      );
      if (scanItem == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No existe un ítem con ese ID.',
              style: GoogleFonts.inter(color: AppColors.superficiePorcelana),
            ),
            backgroundColor: AppColors.alertaLadrillo,
          ),
        );
        return;
      }

      await _databaseService.registerScan(rawValue.trim());

      if (!mounted) return;
      setState(() {
        recentScans.insert(0, scanItem);
        if (recentScans.length > 5) recentScans.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ítem escaneado: ${scanItem.name}',
            style: GoogleFonts.inter(color: AppColors.superficiePorcelana),
          ),
          backgroundColor: AppColors.exitoVerdeSalvia,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al procesar el QR',
            style: GoogleFonts.inter(color: AppColors.superficiePorcelana),
          ),
          backgroundColor: AppColors.alertaLadrillo,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleManualId() async {
    final id = _manualIdController.text.trim();
    if (id.isEmpty) return;
    await _handleScanResult(id);
    _manualIdController.clear();
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (_) {}
  }

  Future<void> _setZoom(double value) async {
    setState(() => _currentZoom = value);
    try {
      await _scannerController.setZoomScale(value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Escáner de Inventario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.superficiePorcelana,
      ),
      body: _showManualEntry ? _buildManualEntryView() : _buildScannerView(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ============================================================
  // Vista del scanner: cámara full-screen + overlay + controles
  // ============================================================
  Widget _buildScannerView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            if (capture.barcodes.isEmpty) return;
            final String? rawValue = capture.barcodes.first.rawValue;
            _handleScanResult(rawValue);
          },
        ),
        AnimatedBuilder(
          animation: _scanLineController,
          builder: (context, _) {
            return CustomPaint(
              painter: _ScannerOverlayPainter(
                scanLinePosition: _scanLineController.value,
                bronce: AppColors.acentoBronce,
                overlay: AppColors.fondoAzulNoche,
              ),
              size: Size.infinite,
            );
          },
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
          right: 16,
          child: Column(
            children: [
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: _scannerController,
                builder: (context, state, _) {
                  final isTorchOn = state.torchState == TorchState.on;
                  return _buildRoundIconButton(
                    icon: isTorchOn ? Icons.flash_on : Icons.flash_off,
                    onTap: _toggleTorch,
                    highlight: isTorchOn,
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildRoundIconButton(
                icon: Icons.cameraswitch,
                onTap: _switchCamera,
                highlight: false,
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildZoomSlider(),
                const SizedBox(height: 12),
                _buildRecentScansPanel(),
                const SizedBox(height: 8),
                _buildManualToggle(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool highlight,
  }) {
    return Material(
      color: highlight
          ? AppColors.acentoBronce
          : AppColors.fondoAzulNoche.withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: highlight
                ? AppColors.fondoAzulNoche
                : AppColors.superficiePorcelana,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Icon(
            Icons.zoom_out,
            color: AppColors.superficiePorcelana.withValues(alpha: 0.6),
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.acentoBronce,
                inactiveTrackColor: AppColors.superficiePorcelana.withValues(
                  alpha: 0.3,
                ),
                thumbColor: AppColors.acentoBronce,
                overlayColor: AppColors.acentoBronce.withValues(alpha: 0.2),
                trackHeight: 2,
              ),
              child: Slider(value: _currentZoom, onChanged: _setZoom),
            ),
          ),
          Icon(
            Icons.zoom_in,
            color: AppColors.superficiePorcelana.withValues(alpha: 0.6),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScansPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.fondoAzulNoche.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.acentoBronce.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ÚLTIMOS ESCANEOS',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.acentoBronce,
              ),
            ),
            const SizedBox(height: 6),
            if (recentScans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aún no hay escaneos.',
                  style: GoogleFonts.inter(
                    color: AppColors.textoSecundarioGris,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...recentScans.take(3).map(_buildScanItemRow),
          ],
        ),
      ),
    );
  }

  Widget _buildScanItemRow(ScanItem scan) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.acentoBronce,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.superficiePorcelana,
                  ),
                ),
                Text(
                  '${scan.location} · ${scan.timeAgo}',
                  style: GoogleFonts.inter(
                    color: AppColors.textoSecundarioGris,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualToggle() {
    return TextButton.icon(
      onPressed: () => setState(() => _showManualEntry = !_showManualEntry),
      icon: const Icon(Icons.edit, color: AppColors.acentoBronce, size: 18),
      label: Text(
        'QR manualmente',
        style: GoogleFonts.inter(
          color: AppColors.acentoBronce,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  // ============================================================
  // Vista de entrada manual (ID por texto)
  // ============================================================
  Widget _buildManualEntryView() {
    return Container(
      color: AppColors.fondoAzulNoche,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.superficiePorcelana,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _manualIdController,
                style: GoogleFonts.inter(
                  color: AppColors.fondoAzulNoche,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Ingresar ID del QR',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.textoSecundarioGris,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleManualId(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleManualId,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acentoBronce,
                foregroundColor: AppColors.fondoAzulNoche,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'VALIDAR ID',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => setState(() => _showManualEntry = false),
              icon: const Icon(
                Icons.qr_code_scanner,
                color: AppColors.acentoBronce,
                size: 18,
              ),
              label: Text(
                'Usar cámara',
                style: GoogleFonts.inter(
                  color: AppColors.acentoBronce,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return const NeonBottomNav(currentIndex: 1);
  }
}

// ============================================================
// Painter del overlay del scanner (hueco + marco + cruz + línea)
// ============================================================
class _ScannerOverlayPainter extends CustomPainter {
  final double scanLinePosition;
  final Color bronce;
  final Color overlay;

  _ScannerOverlayPainter({
    required this.scanLinePosition,
    required this.bronce,
    required this.overlay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutSize = size.width * 0.58;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = size.height * 0.22;
    final cutoutRect = Rect.fromLTWH(
      cutoutLeft,
      cutoutTop,
      cutoutSize,
      cutoutSize,
    );
    final cutoutRight = cutoutLeft + cutoutSize;

    final cutoutBottom = cutoutTop + cutoutSize;

    final cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      const Radius.circular(16),
    );

    // Overlay oscuro con hueco (even-odd fill)
    final overlayPath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(cutoutRRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(
      overlayPath,
      Paint()..color = overlay.withValues(alpha: 0.7),
    );

    // Marcos de esquina (bronce)
    final framePaint = Paint()
      ..color = bronce
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLen = 32.0;
    const r = 18.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutLeft, cutoutTop + cornerLen)
        ..lineTo(cutoutLeft, cutoutTop + r)
        ..arcToPoint(
          Offset(cutoutLeft + r, cutoutTop),
          radius: Radius.circular(r),
          clockwise: true,
        )
        ..lineTo(cutoutLeft + cornerLen, cutoutTop),
      framePaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRight - cornerLen, cutoutTop)
        ..lineTo(cutoutRight - r, cutoutTop)
        ..arcToPoint(
          Offset(cutoutRight, cutoutTop + r),
          radius: Radius.circular(r),
          clockwise: true,
        )
        ..lineTo(cutoutRight, cutoutTop + cornerLen),
      framePaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRight, cutoutBottom - cornerLen)
        ..lineTo(cutoutRight, cutoutBottom - r)
        ..arcToPoint(
          Offset(cutoutRight - r, cutoutBottom),
          radius: Radius.circular(r),
          clockwise: true,
        )
        ..lineTo(cutoutRight - cornerLen, cutoutBottom),
      framePaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutLeft + cornerLen, cutoutBottom)
        ..lineTo(cutoutLeft + r, cutoutBottom)
        ..arcToPoint(
          Offset(cutoutLeft, cutoutBottom - r),
          radius: Radius.circular(r),
          clockwise: true,
        )
        ..lineTo(cutoutLeft, cutoutBottom - cornerLen),
      framePaint,
    );

    // Cruz central tenue
    final crossPaint = Paint()
      ..color = bronce.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    final centerX = cutoutLeft + cutoutSize / 2;
    final centerY = cutoutTop + cutoutSize / 2;
    canvas.drawLine(
      Offset(cutoutLeft + 20, centerY),
      Offset(cutoutLeft + cutoutSize - 20, centerY),
      crossPaint,
    );
    canvas.drawLine(
      Offset(centerX, cutoutTop + 20),
      Offset(centerX, cutoutTop + cutoutSize - 20),
      crossPaint,
    );

    // Línea de escaneo animada (con glow)
    final lineY = cutoutTop + 12 + (cutoutSize - 24) * scanLinePosition;

    final glowPaint = Paint()
      ..color = bronce.withValues(alpha: 0.35)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(
      Offset(cutoutLeft + 16, lineY),
      Offset(cutoutLeft + cutoutSize - 16, lineY),
      glowPaint,
    );

    final linePaint = Paint()
      ..color = bronce
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cutoutLeft + 16, lineY),
      Offset(cutoutLeft + cutoutSize - 16, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanLinePosition != scanLinePosition;
}
