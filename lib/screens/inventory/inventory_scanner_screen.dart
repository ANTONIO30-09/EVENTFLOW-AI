import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_item_model.dart';
import '../../data/services/mock_data_service.dart';

class InventoryScannerScreen extends StatefulWidget {
  const InventoryScannerScreen({super.key});

  @override
  State<InventoryScannerScreen> createState() => _InventoryScannerScreenState();
}

class _InventoryScannerScreenState extends State<InventoryScannerScreen> {
  List<ScanItem> recentScans = [];

  @override
  void initState() {
    super.initState();
    recentScans = MockDataService.getRecentScans();
  }

  void _simulateScan() {
    final newScan = ScanItem(
      id: DateTime.now().toString(),
      name: 'Mesa redonda 100',
      location: 'Ubicación Zona A',
      scannedAt: DateTime.now(),
    );
    setState(() {
      recentScans.insert(0, newScan);
      if (recentScans.length > 5) recentScans.removeLast();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ítem escaneado: Mesa redonda 100')));
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
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'APUNTA LA CÁMARA AL CÓDIGO QR DEL MOBILIARIO\nMANTÉN EL CELULAR ESTABLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _simulateScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('SIMULAR ESCANEO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ÚLTIMOS ESCANEOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: () {}, child: const Text('Ver todos')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('QR MANUALMENTE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildNavItem('Eventos', false, () => Navigator.pop(context)),
        _buildNavItem('Inventario', true, () {}),
        _buildNavItem('Perfil', false, () => Navigator.pushReplacementNamed(context, '/profile')),
      ]),
    );
  }

  Widget _buildNavItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 75, height: 12, decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.grey.shade300, borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.grey.shade400)),
      ]),
    );
  }
}