import 'package:flutter/foundation.dart';
import '../../data/models/auth_models.dart';
import '../../data/services/api_service.dart';
import '../../core/utils/credential_manager.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  Customer? _currentUser;
  String? _authToken;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  Customer? get currentUser => _currentUser;
  String? get authToken => _authToken;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      final token = await _apiService.getAuthToken();
      if (token != null) {
        _authToken = token;
        _isLoggedIn = true;
        // Get mobile number from stored credentials
        final mobile = await CredentialManager.getMobileNumber();
        if (mobile != null) {
          _currentUser = await _apiService.getUserDetails(mobile);
        }
      }
    } catch (e) {
      debugPrint('Failed to load user details: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String mobileNumber, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credentials = LoginCredentials(
        mobileNo: mobileNumber,
        password: password,
      );

      final token = await _apiService.login(credentials);

      if (token.accessToken.isNotEmpty) {
        _authToken = token.accessToken;
        _isLoggedIn = true;

        // Save token and credentials
        await _apiService.setAuthToken(token.accessToken);
        await CredentialManager.saveCredentials(mobileNumber, password);

        // Load user details
        _currentUser = await _apiService.getUserDetails(mobileNumber);

        notifyListeners();
        return true;
      } else {
        _setError('Invalid credentials');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(SignUpRequest signUpRequest) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.signUp(signUpRequest);

      // After successful signup, automatically login
      return await login(signUpRequest.mobileNo, signUpRequest.password);
    } catch (e) {
      _setError('Signup failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> logout() async {
    _setLoading(true);
    try {
      await _apiService.logout();
      _clearAuthState();
      return true;
    } catch (e) {
      _clearAuthState();
      return true; // Always logout locally even if server fails
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOTP(String mobileNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _apiService.verifyOTP(mobileNumber, otp);
      return success;
    } catch (e) {
      _setError('OTP verification failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> generateOTP(String mobileNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _apiService.generateOTP(mobileNumber);
      return success;
    } catch (e) {
      _setError('Failed to generate OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendForgotPasswordOTP(String mobileNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _apiService.generateOTP(mobileNumber);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to send OTP');
        return false;
      }
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    }
  }

  Future<bool> resetPassword(
    String mobileNumber,
    String newPassword,
    String otp,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final request = ForgotPasswordRequest(
        mobileNo: mobileNumber,
        newPassword: newPassword,
        otp: otp,
      );

      final success = await _apiService.forgotPassword(request);
      return success;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        _setError('User not logged in');
        return false;
      }

      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final isValid = await _apiService.changePassword(
        _currentUser!.mobileNo,
        request,
      );
      return isValid;
    } catch (e) {
      _setError('Password validation failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkMobileNumberExists(String mobileNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final exists = await _apiService.isNewNumber(mobileNumber);
      return exists;
    } catch (e) {
      _setError('Failed to check mobile number: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> validatePassword(String password) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentUser == null) {
        _setError('User not logged in');
        return false;
      }

      final request = ChangePasswordRequest(
        currentPassword: password,
        newPassword: password, // For validation, we use the same password
      );
      final isValid = await _apiService.changePassword(
        _currentUser!.mobileNo,
        request,
      );
      return isValid;
    } catch (e) {
      _setError('Password validation failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUserDetails() async {
    try {
      if (_currentUser != null) {
        _currentUser = await _apiService.getUserDetails(_currentUser!.mobileNo);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh user details: $e');
    }
  }

  void _clearAuthState() {
    _isLoggedIn = false;
    _authToken = null;
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Validation methods
  bool isValidMobileNumber(String mobile) {
    return RegExp(r'^[0-9]{10}$').hasMatch(mobile);
  }

  bool isValidName(String name) {
    return name.length >= 2 && name.length <= 50;
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
