import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/mock_data.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check credentials
      if (MockData.loginCredentials.containsKey(email) &&
          MockData.loginCredentials[email] == password) {
        _currentUser = MockData.getUserByEmail(email);
        if (_currentUser != null) {
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _errorMessage = 'Email atau password salah';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat login';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}