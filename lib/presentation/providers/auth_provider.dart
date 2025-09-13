import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up method
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (response['status'] == 'success') {
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Sign up failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Login method
  Future<bool> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Validate user method
  Future<bool> validateUser({
    required String email,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.validateUser(
        email: email,
        otp: otp,
      );

      if (response['status'] == 'success') {
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Validation failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout method
  void logout() {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}
