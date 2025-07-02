import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/schedule.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class QRScannerScreen extends StatefulWidget {
  final Schedule schedule;

  const QRScannerScreen({super.key, required this.schedule});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _hasPermission = false;
  String? _scanResult;

  @override
  void reassemble() {
    super.reassemble();
    cameraController.stop();
    cameraController.start();
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanning && capture.barcodes.isNotEmpty) {
      final String code = capture.barcodes.first.rawValue ?? '';
      setState(() {
        _isScanning = false;
        _scanResult = code;
      });
      _handleQRCode(code);
    }
  }

  void _handleQRCode(String code) async {
    if (code.isEmpty) return;

    // Validate QR Code format
    if (!code.startsWith('KELASKU_ATTENDANCE_')) {
      _showErrorDialog('QR Code tidak valid untuk absensi Kelasku');
      return;
    }

    // Extract schedule ID from QR code
    final parts = code.split('_');
    if (parts.length < 3) {
      _showErrorDialog('Format QR Code tidak valid');
      return;
    }

    final qrScheduleId = parts[2];
    if (qrScheduleId != widget.schedule.id) {
      _showErrorDialog('QR Code tidak sesuai dengan jadwal ini');
      return;
    }

    // Submit attendance
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);

    try {
      await attendanceProvider.submitAttendance(
        scheduleId: widget.schedule.id,
        studentId: authProvider.currentUser!.id,
        method: AttendanceMethod.qr_code,
      );

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Gagal melakukan absensi: $e');
    }
  }



  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Absensi berhasil dicatat untuk:'),
            const SizedBox(height: 8),
            Text(
              widget.schedule.mataKuliah,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Waktu: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = true;
              });
              cameraController.start();
            },
            child: const Text('Coba Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _simulateQRScan() {
    // Simulate scanning a valid QR code for demo purposes
    final demoQRCode = 'KELASKU_ATTENDANCE_${widget.schedule.id}_${DateTime.now().millisecondsSinceEpoch}';
    _handleQRCode(demoQRCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Schedule Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.schedule.mataKuliah,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.schedule.dosen} • ${widget.schedule.ruangan}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  widget.schedule.formattedTime,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // QR Scanner
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                _hasPermission
                    ? MobileScanner(
                        controller: cameraController,
                        onDetect: _onDetect,
                      )
                    : const Center(
                        child: Text(
                          'Izin kamera diperlukan untuk scan QR',
                          textAlign: TextAlign.center,
                        ),
                      ),
                if (!_isScanning)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Instructions
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Arahkan kamera ke QR Code yang ditampilkan dosen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Demo button for testing
                  ElevatedButton(
                    onPressed: !_isScanning ? null : _simulateQRScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Demo: Simulasi Scan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}