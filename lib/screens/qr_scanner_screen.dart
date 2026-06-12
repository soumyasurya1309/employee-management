import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final raw = barcode!.rawValue!;

    // Parse QR data: EMP:EMP001|NAME:John|DEPT:Engineering|DESG:Developer
    String? employeeId;
    for (final part in raw.split('|')) {
      if (part.startsWith('EMP:')) {
        employeeId = part.replaceFirst('EMP:', '');
        break;
      }
    }

    if (employeeId == null) {
      _showError('Invalid QR Code');
      return;
    }

    setState(() => _scanned = true);
    await controller.stop();

    if (!mounted) return;

    final provider = context.read<EmployeeProvider>();
    final employee = provider.allEmployees
        .where((e) => e.employeeId == employeeId)
        .firstOrNull;

    if (!mounted) return;

    if (employee != null) {
      Navigator.pushReplacementNamed(
        context,
        '/employees/detail',
        arguments: employee,
      );
    } else {
      _showError('Employee not found: $employeeId');
      setState(() => _scanned = false);
      controller.start();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFF87171),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Scan Employee QR',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color: Colors.white,
                  size: 22,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Scan frame
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.accent, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Corner decorations
                      _Corner(top: true, left: true),
                      _Corner(top: true, left: false),
                      _Corner(top: false, left: true),
                      _Corner(top: false, left: false),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Point camera at employee QR code',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Loading overlay when scanned
          if (_scanned)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(
                    color: AppColors.accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final bool top;
  final bool left;
  const _Corner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? -1 : null,
      bottom: top ? null : -1,
      left: left ? -1 : null,
      right: left ? null : -1,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: AppColors.accent, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}