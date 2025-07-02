import '../models/user.dart';
import '../models/schedule.dart';
import '../models/attendance.dart';

class MockData {
  // Mock Users
  static final List<User> users = [
    // Mahasiswa
    User(
      id: '1',
      name: 'Ahmad Rizki',
      email: 'ahmad.rizki@bsi.ac.id',
      role: UserRole.mahasiswa,
      nim: '12345678',
    ),
    User(
      id: '2',
      name: 'Siti Nurhaliza',
      email: 'siti.nurhaliza@bsi.ac.id',
      role: UserRole.mahasiswa,
      nim: '12345679',
    ),
    User(
      id: '3',
      name: 'Budi Santoso',
      email: 'budi.santoso@bsi.ac.id',
      role: UserRole.mahasiswa,
      nim: '12345680',
    ),
    // Dosen
    User(
      id: '4',
      name: 'Dr. Andi Wijaya, M.Kom',
      email: 'andi.wijaya@bsi.ac.id',
      role: UserRole.dosen,
      nip: '198501012010121001',
    ),
    User(
      id: '5',
      name: 'Prof. Sari Indah, Ph.D',
      email: 'sari.indah@bsi.ac.id',
      role: UserRole.dosen,
      nip: '198201012008122001',
    ),
  ];

  // Mock Schedules
  static final List<Schedule> schedules = [
    Schedule(
      id: 'sch1',
      mataKuliah: 'Mobile Programming',
      dosen: 'Dr. Andi Wijaya, M.Kom',
      ruangan: 'Lab Komputer 1',
      waktuMulai: DateTime.now().add(const Duration(hours: 1)),
      waktuSelesai: DateTime.now().add(const Duration(hours: 3)),
      status: ScheduleStatus.offline,
      kelas: '4SI1',
      semester: 'Genap 2023/2024',
    ),
    Schedule(
      id: 'sch2',
      mataKuliah: 'Basis Data',
      dosen: 'Prof. Sari Indah, Ph.D',
      ruangan: 'Online Meeting',
      waktuMulai: DateTime.now().add(const Duration(days: 1, hours: 2)),
      waktuSelesai: DateTime.now().add(const Duration(days: 1, hours: 4)),
      status: ScheduleStatus.online,
      kelas: '4SI1',
      semester: 'Genap 2023/2024',
    ),
    Schedule(
      id: 'sch3',
      mataKuliah: 'Algoritma dan Struktur Data',
      dosen: 'Dr. Andi Wijaya, M.Kom',
      ruangan: 'Ruang 201',
      waktuMulai: DateTime.now().add(const Duration(days: 2, hours: 1)),
      waktuSelesai: DateTime.now().add(const Duration(days: 2, hours: 3)),
      status: ScheduleStatus.offline,
      kelas: '4SI1',
      semester: 'Genap 2023/2024',
    ),
    Schedule(
      id: 'sch4',
      mataKuliah: 'Pemrograman Web',
      dosen: 'Prof. Sari Indah, Ph.D',
      ruangan: 'Lab Komputer 2',
      waktuMulai: DateTime.now().add(const Duration(days: 3, hours: 2)),
      waktuSelesai: DateTime.now().add(const Duration(days: 3, hours: 4)),
      status: ScheduleStatus.online,
      kelas: '4SI1',
      semester: 'Genap 2023/2024',
    ),
    Schedule(
      id: 'sch5',
      mataKuliah: 'Sistem Operasi',
      dosen: 'Dr. Andi Wijaya, M.Kom',
      ruangan: 'Ruang 301',
      waktuMulai: DateTime.now().add(const Duration(days: 4, hours: 1)),
      waktuSelesai: DateTime.now().add(const Duration(days: 4, hours: 3)),
      status: ScheduleStatus.offline,
      kelas: '4SI1',
      semester: 'Genap 2023/2024',
    ),
    Schedule(
      id: 'sch6',
      mataKuliah: 'Sistem Operasi Linux',
      dosen: 'Dr. Andi Wijaya, M.Kom',
      ruangan: 'Online Meeting',
      waktuMulai: DateTime.now().add(const Duration(hours: 3)),
      waktuSelesai: DateTime.now().add(const Duration( hours: 6)),
      status: ScheduleStatus.online,
      kelas: '4SI1',
      semester: 'Genap 2023/2024',
    ),
  ];

  // Mock Attendance History
  static final List<Attendance> attendanceHistory = [
    Attendance(
      id: 'att1',
      scheduleId: 'sch1',
      studentId: '1',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      status: AttendanceStatus.hadir,
      method: AttendanceMethod.qr_code,
      notes: 'Hadir tepat waktu',
    ),
    Attendance(
      id: 'att2',
      scheduleId: 'sch2',
      studentId: '1',
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
      status: AttendanceStatus.hadir,
      method: AttendanceMethod.face_recognition,
      notes: 'Hadir via online',
    ),
    Attendance(
      id: 'att3',
      scheduleId: 'sch3',
      studentId: '1',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      status: AttendanceStatus.terlambat,
      method: AttendanceMethod.qr_code,
      notes: 'Terlambat 15 menit',
    ),
    Attendance(
      id: 'att4',
      scheduleId: 'sch4',
      studentId: '1',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      status: AttendanceStatus.hadir,
      method: AttendanceMethod.face_recognition,
      notes: 'Hadir via online',
    ),
    Attendance(
      id: 'att5',
      scheduleId: 'sch5',
      studentId: '1',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: AttendanceStatus.tidak_hadir,
      method: AttendanceMethod.qr_code,
      notes: 'Tidak hadir tanpa keterangan',
    ),
  ];

  // Login credentials for demo
  static const Map<String, String> loginCredentials = {
    // Mahasiswa
    'ahmad@bsi.ac.id': 'password123',
    'siti@bsi.ac.id': 'password123',
    'budi@bsi.ac.id': 'password123',
    // Dosen
    'andi@bsi.ac.id': 'password123',
    'sari@bsi.ac.id': 'password123',
  };

  static User? getUserByEmail(String email) {
    try {
      return users.firstWhere((user) => user.email.contains(email.split('@')[0]));
    } catch (e) {
      return null;
    }
  }

  static List<Schedule> getSchedulesByRole(UserRole role, String userId) {
    if (role == UserRole.dosen) {
      final user = users.firstWhere((u) => u.id == userId);
      return schedules.where((s) => s.dosen == user.name).toList();
    } else {
      return schedules;
    }
  }

  static List<Attendance> getAttendanceByStudent(String studentId) {
    return attendanceHistory.where((a) => a.studentId == studentId).toList();
  }
}