import '../../../core/data/services/api_service.dart';
import '../../../screens/auth/repo/auth_models.dart';

/// Repository for profile-related API operations
class ProfileRepository {
  final ApiService _apiService = ApiService();

  /// Get customer details
  Future<Customer> getCustomerDetails(String mobile) async {
    try {
      return await _apiService.getUserDetails(mobile);
    } catch (e) {
      throw Exception('Failed to get customer details: $e');
    }
  }

  /// Validate password
  Future<bool> validatePassword(String mobile, String password) async {
    try {
      return await _apiService.validatePassword(mobile, password);
    } catch (e) {
      throw Exception('Failed to validate password: $e');
    }
  }

  /// Update user data
  Future<Customer> updateUserData({
    required String mobile,
    required String name,
    required String emailId,
    required String password,
  }) async {
    try {
      return await _apiService.updateUserData(
        mobile,
        name: name,
        emailId: emailId,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }
}

