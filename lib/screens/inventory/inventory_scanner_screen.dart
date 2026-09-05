import 'package:flutter/material.dart';
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
          const SnackBar(content: Text('No existe un ítem con ese ID.')),
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
        SnackBar(content: Text('Ítem escaneado: ${scanItem.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el QR: $e')),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ESCANER DE INVENTARIO', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (!_showManualEntry)
            Expanded(
              flex: 3,
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
            )
          else
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _manualIdController,
                      decoration: InputDecoration(
                        hintText: 'Ingresar ID del QR',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onSubmitted: (_) => _handleManualId(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleManualId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('VALIDAR ID'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showManualEntry = !_showManualEntry),
                icon: const Icon(Icons.edit),
                label: Text(_showManualEntry ? 'Usar cámara' : 'QR manualmente'),
              ),
            ],
          ),
          if (!_showManualEntry)
            const Text(
              'APUNTA LA CÁMARA AL CÓDIGO QR DEL MOBILIARIO\nMANTÉN EL CELULAR ESTABLE',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ÚLTIMOS ESCANEOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: recentScans.isEmpty
                ? const Center(
                    child: Text(
                      'Aún no hay escaneos.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: recentScans.length,
                    itemBuilder: (context, index) {
                      final scan = recentScans[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(scan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(scan.location, style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 4),
                              Text(scan.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
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
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pop(context);
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
