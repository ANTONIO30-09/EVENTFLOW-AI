import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_item_model.dart';
import '../../data/services/database_service.dart';
import '../profile/profile_screen.dart';

class InventoryScannerScreen extends StatefulWidget {
  const InventoryScannerScreen({super.key});

  @override
  State<InventoryScannerScreen> createState() => _InventoryScannerScreenState();
}

class _InventoryScannerScreenState extends State<InventoryScannerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _manualIdController = TextEditingController();

  List<ScanItem> recentScans = [];
  bool _isProcessing = false;
  bool _showManualEntry = false;

  @override
  void dispose() {
    _manualIdController.dispose();
    super.dispose();
  }

  Future<void> _handleScanResult(String? rawValue) async {
    if (rawValue == null || rawValue.trim().isEmpty) return;
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final scanItem = await _databaseService.fetchScanItemById(rawValue.trim());
      if (scanItem == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No existe un ítem con ese ID.',
                style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
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
          content: Text('Ítem escaneado: ${scanItem.name}',
              style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
          backgroundColor: AppColors.exitoVerdeSalvia,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el QR',
              style: GoogleFonts.inter(color: AppColors.superficiePorcelana)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoAzulNoche,
      appBar: AppBar(
        title: const Text('Escáner de Inventario'),
      ),
      body: Column(
        children: [
          if (!_showManualEntry)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: MobileScanner(
                    controller: MobileScannerController(
                      formats: const [BarcodeFormat.qrCode],
                      detectionSpeed: DetectionSpeed.noDuplicates,
                    ),
                    onDetect: (capture) {
                      final String? rawValue = capture.barcodes.first.rawValue;
                      _handleScanResult(rawValue);
                    },
                  ),
                ),
              ),
            )
          else
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                        style: GoogleFonts.inter(color: AppColors.fondoAzulNoche, fontSize: 15),
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
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'VALIDAR ID',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => setState(() => _showManualEntry = !_showManualEntry),
            icon: Icon(_showManualEntry ? Icons.qr_code_scanner : Icons.edit, color: AppColors.acentoBronce),
            label: Text(
              _showManualEntry ? 'Usar cámara' : 'QR manualmente',
              style: GoogleFonts.inter(color: AppColors.acentoBronce, fontWeight: FontWeight.w600),
            ),
          ),
          if (!_showManualEntry)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Apunta la cámara al código QR del mobiliario\nMantén el celular estable',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textoSecundarioGris,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'ÚLTIMOS ESCANEOS',
                  style: GoogleFonts.fraunces(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.acentoBronce,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: recentScans.isEmpty
                ? Center(
                    child: Text(
                      'Aún no hay escaneos.',
                      style: GoogleFonts.inter(color: AppColors.textoSecundarioGris),
                    ),
                  )
                : ListView.builder(
                    itemCount: recentScans.length,
                    itemBuilder: (context, index) {
                      final scan = recentScans[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.superficiePorcelana,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(color: AppColors.acentoBronce, width: 4),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.fondoAzulNoche,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scan.location,
                              style: GoogleFonts.inter(
                                color: AppColors.textoSecundarioGris,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scan.timeAgo,
                              style: GoogleFonts.inter(
                                color: AppColors.textoSecundarioGris,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Eventos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
