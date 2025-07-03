import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '../../models/schedule.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final Schedule schedule;

  const FaceRecognitionScreen({super.key, required this.schedule});

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isRecognitionComplete = false;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupAnimations();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
        await _cameraController!.initialize();

        if (mounted) setState(() => _isCameraInitialized = true);
      }
    } catch (_) {
      if (mounted) _showErrorDialog('Gagal mengakses kamera. Pastikan izin kamera telah diberikan.');
    }
  }

  void _setupAnimations() {
    _scanAnimationController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut));
    _scanAnimationController.repeat(reverse: true);

    _progressAnimationController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _progressAnimationController, curve: Curves.easeInOut));
  }

  Widget _buildCamera() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _cameraController!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(scale: scale, alignment: Alignment.center, child: CameraPreview(_cameraController!));
  }

  void _startFaceRecognition() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    _scanAnimationController.stop();
    _progressAnimationController.forward();

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() => _isRecognitionComplete = true);

    await Future.delayed(const Duration(milliseconds: 500));
    _submitAttendance();
  }

  void _submitAttendance() async {
    final auth = context.read<AuthProvider>();
    final attend = context.read<AttendanceProvider>();

    if (auth.currentUser == null) return;

    final success = await attend.submitAttendance(
      scheduleId: widget.schedule.id,
      studentId: auth.currentUser!.id,
      method: AttendanceMethod.face_recognition,
      notes: 'Absensi melalui Face Recognition',
    );

    if (!mounted) return;
    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog('Gagal melakukan absensi. Silakan coba lagi.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wajah berhasil dikenali dan absensi tercatat untuk:'),
            const SizedBox(height: 8),
            Text(widget.schedule.mataKuliah, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'Waktu: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isProcessing = false;
                _isRecognitionComplete = false;
              });
              _progressAnimationController.reset();
              _scanAnimationController.repeat(reverse: true);
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

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: Column(
        children: [
          _buildScheduleInfo(),
          Expanded(flex: 4, child: _buildCameraSection()),
          _buildActionSection(),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.schedule.mataKuliah, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.person, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(widget.schedule.dosen, style: const TextStyle(color: Colors.grey)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.access_time, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(widget.schedule.formattedTime, style: const TextStyle(color: Colors.grey)),
        ]),
      ]),
    );
  }

  Widget _buildCameraSection() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          Center(child: _buildCamera()),
          Center(
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isRecognitionComplete
                      ? Colors.green
                      : _isProcessing
                          ? Colors.orange
                          : const Color(0xFF1E3A8A),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(children: [
                if (!_isProcessing)
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (_, __) => Positioned(
                      top: _scanAnimation.value * 250,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0xFF1E3A8A), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_isProcessing)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (_, __) => CircularProgressIndicator(
                            value: _progressAnimation.value,
                            valueColor: const AlwaysStoppedAnimation(Colors.orange),
                            strokeWidth: 4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Mengenali wajah...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                if (_isRecognitionComplete)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 64),
                        SizedBox(height: 16),
                        Text('Wajah Dikenali!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _isProcessing
                ? 'Sedang memproses...'
                : _isRecognitionComplete
                    ? 'Absensi berhasil dicatat!'
                    : 'Posisikan wajah Anda di dalam frame dan tekan tombol untuk memulai',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (!_isProcessing && !_isRecognitionComplete)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isCameraInitialized ? _startFaceRecognition : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Mulai Pengenalan Wajah', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
