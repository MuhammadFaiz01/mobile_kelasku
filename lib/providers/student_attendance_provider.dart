import 'package:flutter/foundation.dart';
import '../../models/student.dart';
import '../../models/attendance.dart';

class StudentAttendanceProvider extends ChangeNotifier {
  StudentAttendanceProvider() {
    _bootstrap(); // langsung load dummy data
  }

  final List<Student> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// ===== PUBLIC GETTERS =====
  List<Student> get students => List.unmodifiable(_students);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get presentCount =>
      _students.where((s) => s.status == AttendanceStatus.hadir).length;

  /// ===== PRIVATE HELPERS =====
  Future<void> _bootstrap() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 300)); // simulasi API
    try {
      _students
        ..clear()
        ..addAll(List.generate(
          20,
          (i) => Student(
            id: 'S${i + 1000}',
            name: 'Siswa ${i + 1}',
            studentId: 'STD${i + 1000}',
            photoUrl: 'https://picsum.photos/100?random=$i',
            status: AttendanceStatus.tidak_hadir,
          ),
        ));
      _errorMessage = null;
    } catch (e, s) {
      _errorMessage = 'Gagal memuat data siswa';
      debugPrint('Student load error: $e\n$s');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// ===== PUBLIC METHODS =====
  /// Ubah status kehadiran satu siswa lalu beri tahu listener.
  void updateStatus(String studentId, AttendanceStatus newStatus) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx == -1) return;
    _students[idx] = _students[idx].copyWith(status: newStatus);
    notifyListeners();
  }

  /// Submit kehadiran (saat ini hanya debug print).
  Future<void> submitAttendance() async {
    debugPrint('Total hadir: $presentCount / ${_students.length}');
    // TODO: panggil API di sini
  }
}
