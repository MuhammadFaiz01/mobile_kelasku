import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/attendance.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        attendanceProvider.loadAttendanceHistory(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AttendanceProvider, AuthProvider>(
        builder: (context, attendanceProvider, authProvider, child) {
          if (attendanceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (attendanceProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    attendanceProvider.errorMessage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (authProvider.currentUser != null) {
                        attendanceProvider.loadAttendanceHistory(
                          authProvider.currentUser!.id,
                        );
                      }
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final attendanceHistory = attendanceProvider.attendanceHistory;
          final user = authProvider.currentUser;

          if (attendanceHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada riwayat absensi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Riwayat absensi akan muncul setelah Anda melakukan absensi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Tingkat Kehadiran',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${attendanceProvider.getAttendancePercentage(user?.id ?? '').toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Total',
                            value: attendanceHistory.length.toString(),
                            color: Colors.white70,
                          ),
                          _StatItem(
                            label: 'Hadir',
                            value: attendanceHistory
                                .where((a) => a.status == AttendanceStatus.hadir)
                                .length
                                .toString(),
                            color: Colors.green[200]!,
                          ),
                          _StatItem(
                            label: 'Terlambat',
                            value: attendanceHistory
                                .where((a) => a.status == AttendanceStatus.terlambat)
                                .length
                                .toString(),
                            color: Colors.orange[200]!,
                          ),
                          _StatItem(
                            label: 'Tidak Hadir',
                            value: attendanceHistory
                                .where((a) => a.status == AttendanceStatus.tidak_hadir)
                                .length
                                .toString(),
                            color: Colors.red[200]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // History Title
                const Text(
                  'Riwayat Absensi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Attendance List
                ...attendanceHistory.map(
                  (attendance) => _AttendanceCard(attendance: attendance),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final Attendance attendance;

  const _AttendanceCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (attendance.status) {
      case AttendanceStatus.hadir:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Hadir';
        break;
      case AttendanceStatus.terlambat:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Terlambat';
        break;
      case AttendanceStatus.sakit:
        statusColor = Colors.lightGreen;
        statusIcon = Icons.sick;
        statusText = 'Sakit';
        break;
      case AttendanceStatus.izin:
        statusColor = Colors.lightGreen;
        statusIcon = Icons.person_off;
        statusText = 'Izin';
        break;
      case AttendanceStatus.tidak_hadir:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Tidak Hadir';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mata Kuliah: ${attendance.scheduleId}', // In real app, you'd fetch the schedule name
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                attendance.formattedDate,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                attendance.formattedTime,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                attendance.method == AttendanceMethod.qr_code
                    ? Icons.qr_code
                    : Icons.face,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                attendance.method == AttendanceMethod.qr_code
                    ? 'QR Code'
                    : 'Face Recognition',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          if (attendance.notes != null && attendance.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                attendance.notes!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}