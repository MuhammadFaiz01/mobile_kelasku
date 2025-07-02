import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import '../data/mock_data.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSchedules(UserRole role, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _schedules = MockData.getSchedulesByRole(role, userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat jadwal';
      _isLoading = false;
      notifyListeners();
    }
  }

  Schedule? getScheduleById(String id) {
    try {
      return _schedules.firstWhere((schedule) => schedule.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Schedule> getTodaySchedules() {
    final today = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.waktuMulai.day == today.day &&
          schedule.waktuMulai.month == today.month &&
          schedule.waktuMulai.year == today.year;
    }).toList();
  }

  List<Schedule> getUpcomingSchedules() {
    final now = DateTime.now();
    return _schedules.where((schedule) {
      return schedule.waktuMulai.isAfter(now);
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}