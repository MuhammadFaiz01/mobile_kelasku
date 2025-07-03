import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../models/schedule.dart';
import 'student_attendance_screen.dart';

class QRGeneratorScreen extends StatefulWidget {
  final Schedule schedule;

  const QRGeneratorScreen({super.key, required this.schedule});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final Animation<double> _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
  );

  bool _isQRGenerated = false;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateQRCode() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    if (!mounted) return;
    setState(() {
      _qrData = 'KELASKU_ATTENDANCE_${widget.schedule.id}_${DateTime.now().millisecondsSinceEpoch}';
      _isQRGenerated = true;
    });
    _animationController.forward();
  }

  void _regenerateQR() {
    setState(() {
      _isQRGenerated = false;
      _qrData = null;
    });
    _animationController
      ..reset()
      ..forward();
    _generateQRCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildScheduleCard(),
          const SizedBox(height: 32),
          const Text('QR Code Absensi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _isQRGenerated ? _buildQRCard() : _buildLoading(),
          const SizedBox(height: 24),
          _buildGuideCard(),
          const SizedBox(height: 24),
          if (_isQRGenerated) _buildActionButtons(context),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.schedule.mataKuliah, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _infoRow(Icons.class_, widget.schedule.kelas),
        _infoRow(Icons.location_on, widget.schedule.ruangan),
        _infoRow(Icons.access_time, '${widget.schedule.formattedDate} • ${widget.schedule.formattedTime}'),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: _cardDecoration(),
      child: const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF1E3A8A))),
          SizedBox(height: 16),
          Text('Generating QR Code...', style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildQRCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, _) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration().copyWith(
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox.square(
                dimension: 200,
                child: PrettyQrView.data(
                  data: _qrData!,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  decoration: const PrettyQrDecoration(quietZone: PrettyQrQuietZone.standart),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(
                'QR ID: ${_qrData!.split('_').last}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey[300]!),
    );
  }

  Widget _buildGuideCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Text('Petunjuk Penggunaan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700])),
        ]),
        const SizedBox(height: 12),
        const Text(
          '• Tampilkan QR Code ini ke mahasiswa\n'
          '• Mahasiswa scan menggunakan aplikasi\n'
          '• QR Code otomatis expired setelah kelas selesai\n'
          '• Tekan Regenerate jika perlu QR baru',
          style: TextStyle(height: 1.5, fontSize: 14),
        ),
      ]),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _regenerateQR,
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.people),
            label: const Text('Lihat Kehadiran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const StudentAttendanceScreen()),
              );
            },
          ),
        ),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR Code berhasil disimpan ke galeri'), backgroundColor: Colors.green),
            );
          },
          icon: const Icon(Icons.save_alt),
          label: const Text('Simpan QR Code'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ]);
  }
}
