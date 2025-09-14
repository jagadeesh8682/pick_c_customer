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
        mobileNumber:
            email, // Using email as mobileNumber for legacy compatibility
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

  // Sign up with mobile number
  Future<bool> signUpWithMobile({
    required String name,
    required String mobileNumber,
    String? email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.signUpWithMobile(
        name: name,
        mobileNumber: mobileNumber,
        email: email,
        password: password,
      );

      if (response['status'] == 'success') {
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

  // Login with mobile number
  Future<bool> loginWithMobile({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.loginWithMobile(
        mobileNumber: mobileNumber,
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

  // Send forgot password OTP
  Future<bool> sendForgotPasswordOTP({required String mobileNumber}) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.sendForgotPasswordOTP(
        mobileNumber: mobileNumber,
      );

      if (response['status'] == 'success') {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to send OTP');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.verifyOTP(
        mobileNumber: mobileNumber,
        otp: otp,
      );

      if (response['status'] == 'success') {
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'OTP verification failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String mobileNumber,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authRepository.resetPassword(
        mobileNumber: mobileNumber,
        newPassword: newPassword,
      );

      if (response['status'] == 'success') {
        _setLoading(false);
        return true;
      } else {
        _setError(response['message'] ?? 'Password reset failed');
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
