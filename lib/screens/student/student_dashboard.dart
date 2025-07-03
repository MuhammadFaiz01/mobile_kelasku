import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/schedule.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import 'qr_scanner_screen.dart';
import 'face_recognition_screen.dart';
import 'attendance_history_screen.dart';
import 'profile.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final scheduleProvider = Provider.of<ScheduleProvider>(
        context,
        listen: false,
      );
      final attendanceProvider = Provider.of<AttendanceProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        scheduleProvider.loadSchedules(
          UserRole.mahasiswa,
          authProvider.currentUser!.id,
        );
        attendanceProvider.loadAttendanceHistory(authProvider.currentUser!.id);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _HomeTab(),
      const _ScheduleTab(),
      const AttendanceHistoryScreen(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'KELASKU',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout, color: Color(0xFF1E3A8A)),
        //     onPressed: _logout,
        //   ),
        // ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, ScheduleProvider, AttendanceProvider>(
      builder:
          (context, authProvider, scheduleProvider, attendanceProvider, child) {
            final user = authProvider.currentUser;
            if (user == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'NIM: ${user.nim}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Kehadiran',
                          value:
                              '${attendanceProvider.getAttendancePercentage(user.id).toStringAsFixed(1)}%',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Kelas',
                          value: '${scheduleProvider.schedules.length}',
                          icon: Icons.class_,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jadwal Hari Ini',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (scheduleProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (scheduleProvider.getTodaySchedules().isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.event_busy, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada jadwal hari ini',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  else
                    ...scheduleProvider.getTodaySchedules().map(
                      (schedule) => _ScheduleCard(
                        schedule: schedule,
                        onAttend: () => _attendClass(context, schedule),
                      ),
                    ),
                ],
              ),
            );
          },
    );
  }

  void _attendClass(BuildContext context, Schedule schedule) {
    if (schedule.status == ScheduleStatus.offline) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(schedule: schedule),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceRecognitionScreen(schedule: schedule),
        ),
      );
    }
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, scheduleProvider, child) {
        if (scheduleProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (scheduleProvider.schedules.isEmpty) {
          return const Center(child: Text('Tidak ada jadwal tersedia'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scheduleProvider.schedules.length,
          itemBuilder: (context, index) {
            final schedule = scheduleProvider.schedules[index];
            return _ScheduleCard(
              schedule: schedule,
              onAttend: () => _attendClass(context, schedule),
            );
          },
        );
      },
    );
  }

  void _attendClass(BuildContext context, Schedule schedule) {
    if (schedule.status == ScheduleStatus.offline) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(schedule: schedule),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FaceRecognitionScreen(schedule: schedule),
        ),
      );
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
            radius: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onAttend;

  const _ScheduleCard({required this.schedule, required this.onAttend});

  @override
  Widget build(BuildContext context) {
    final isToday =
        schedule.waktuMulai.day == DateTime.now().day &&
        schedule.waktuMulai.month == DateTime.now().month &&
        schedule.waktuMulai.year == DateTime.now().year;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isToday
            ? Border.all(color: const Color(0xFF1E3A8A), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    schedule.mataKuliah,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.status == ScheduleStatus.online
                        ? Colors.green[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.status == ScheduleStatus.online
                        ? 'Online'
                        : 'Offline',
                    style: TextStyle(
                      color: schedule.status == ScheduleStatus.online
                          ? Colors.green
                          : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(icon: Icons.person, text: schedule.dosen),
            const SizedBox(height: 6),
            _DetailRow(icon: Icons.location_on, text: schedule.ruangan),
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.access_time,
              text: '${schedule.formattedDate} • ${schedule.formattedTime}',
            ),
            if (isToday)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAttend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(
                      schedule.status == ScheduleStatus.offline
                          ? Icons.qr_code
                          : Icons.face,
                      size: 18,
                    ),
                    label: Text(
                      schedule.status == ScheduleStatus.offline
                          ? 'Scan QR Code'
                          : 'Face Recognition',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
