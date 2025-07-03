import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import 'qr_generator_screen.dart';
import 'profile.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
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

      if (authProvider.currentUser != null) {
        scheduleProvider.loadSchedules(
          UserRole.dosen,
          authProvider.currentUser!.id,
        );
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
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ScheduleProvider>(
      builder: (context, authProvider, scheduleProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 32, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang,',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NIP: ${user.nip}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Kelas',
                      value: '${scheduleProvider.schedules.length}',
                      icon: Icons.class_,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Hari Ini',
                      value: '${scheduleProvider.getTodaySchedules().length}',
                      icon: Icons.today,
                      color: Colors.green,
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
                  (schedule) => _LecturerScheduleCard(
                    schedule: schedule,
                    onGenerateQR: () => _generateQR(context, schedule),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _generateQR(BuildContext context, Schedule schedule) {
    if (schedule.status == ScheduleStatus.offline) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRGeneratorScreen(schedule: schedule),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code hanya tersedia untuk kelas offline'),
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
        if (scheduleProvider.isLoading)
          return const Center(child: CircularProgressIndicator());
        if (scheduleProvider.schedules.isEmpty)
          return const Center(child: Text('Tidak ada jadwal tersedia'));

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
          itemCount: scheduleProvider.schedules.length,
          itemBuilder: (context, index) {
            final schedule = scheduleProvider.schedules[index];
            return _LecturerScheduleCard(
              schedule: schedule,
              onGenerateQR: () => _generateQR(context, schedule),
            );
          },
        );
      },
    );
  }

  void _generateQR(BuildContext context, Schedule schedule) {
    if (schedule.status == ScheduleStatus.offline) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRGeneratorScreen(schedule: schedule),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code hanya tersedia untuk kelas offline'),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _LecturerScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onGenerateQR;

  const _LecturerScheduleCard({
    required this.schedule,
    required this.onGenerateQR,
  });

  @override
  Widget build(BuildContext context) {
    final isToday =
        schedule.waktuMulai.day == DateTime.now().day &&
        schedule.waktuMulai.month == DateTime.now().month &&
        schedule.waktuMulai.year == DateTime.now().year;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: const Color(0xFF1E3A8A), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  schedule.mataKuliah,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: schedule.status == ScheduleStatus.online
                      ? Colors.green[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule.status == ScheduleStatus.online
                      ? 'Online'
                      : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: schedule.status == ScheduleStatus.online
                        ? Colors.green[700]
                        : Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.class_, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(schedule.kelas),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(schedule.ruangan),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${schedule.formattedDate} • ${schedule.formattedTime}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: schedule.status == ScheduleStatus.offline
                      ? onGenerateQR
                      : null,
                  icon: Icon(
                    schedule.status == ScheduleStatus.offline
                        ? Icons.qr_code
                        : Icons.videocam,
                    size: 18,
                  ),
                  label: Text(
                    schedule.status == ScheduleStatus.offline
                        ? 'Generate QR'
                        : 'Kelas Online',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: schedule.status == ScheduleStatus.offline
                        ? const Color(0xFF1E3A8A)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur daftar kehadiran akan segera tersedia',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.people, size: 18),
                label: const Text('Kehadiran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
