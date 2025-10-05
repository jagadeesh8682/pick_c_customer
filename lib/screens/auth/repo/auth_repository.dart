import '../../../core/network/network_service.dart';
import '../../../core/constants/app_url.dart';

class AuthRepository {
  final NetworkService _networkService;

  AuthRepository({required NetworkService networkService})
    : _networkService = networkService;

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.saveCustomerDetails,
        {'email': email, 'password': password, 'name': name},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.login,
        {'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validateUser({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.verifyOtp,
        {'mobileNumber': mobileNumber, 'otp': otp},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signUpWithMobile({
    required String name,
    required String mobileNumber,
    String? email,
    required String password,
  }) async {
    try {
      final response = await _networkService
          .getPostApiResponseUnauthenticated(AppUrl.saveCustomerDetails, {
            'name': name,
            'mobileNumber': mobileNumber,
            if (email != null) 'email': email,
            'password': password,
          });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithMobile({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.login,
        {'mobileNumber': mobileNumber, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendForgotPasswordOTP({
    required String mobileNumber,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.forgotPassword,
        {'mobileNumber': mobileNumber},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOTP({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.verifyOtp,
        {'mobileNumber': mobileNumber, 'otp': otp},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String mobileNumber,
    required String newPassword,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.forgotPassword,
        {'mobileNumber': mobileNumber, 'newPassword': newPassword},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
