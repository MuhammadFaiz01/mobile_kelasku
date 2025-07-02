import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../data/mock_data.dart';

class AttendanceProvider with ChangeNotifier {
  List<Attendance> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isProcessingAttendance = false;

  List<Attendance> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isProcessingAttendance => _isProcessingAttendance;

  Future<void> loadAttendanceHistory(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _attendanceHistory = MockData.getAttendanceByStudent(studentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat absensi';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitAttendance({
    required String scheduleId,
    required String studentId,
    required AttendanceMethod method,
    String? notes,
  }) async {
    _isProcessingAttendance = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate processing time
      await Future.delayed(const Duration(seconds: 3));

      // Create new attendance record
      final newAttendance = Attendance(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        scheduleId: scheduleId,
        studentId: studentId,
        timestamp: DateTime.now(),
        status: AttendanceStatus.hadir,
        method: method,
        notes: notes ?? 'Absensi berhasil',
      );

      // Add to history (in real app, this would be sent to server)
      _attendanceHistory.insert(0, newAttendance);
      
      _isProcessingAttendance = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal melakukan absensi';
      _isProcessingAttendance = false;
      notifyListeners();
      return false;
    }
  }

  bool hasAttendedToday(String scheduleId, String studentId) {
    final today = DateTime.now();
    return _attendanceHistory.any((attendance) {
      return attendance.scheduleId == scheduleId &&
          attendance.studentId == studentId &&
          attendance.timestamp.day == today.day &&
          attendance.timestamp.month == today.month &&
          attendance.timestamp.year == today.year;
    });
  }

  double getAttendancePercentage(String studentId) {
    if (_attendanceHistory.isEmpty) return 0.0;
    
    final totalClasses = _attendanceHistory.length;
    final attendedClasses = _attendanceHistory
        .where((a) => a.status == AttendanceStatus.hadir || a.status == AttendanceStatus.terlambat)
        .length;
    
    return (attendedClasses / totalClasses) * 100;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}