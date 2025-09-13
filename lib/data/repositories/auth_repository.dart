import '../../core/network/network_service.dart';
import '../../core/constants/app_url.dart';

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
        AppUrl.signup,
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
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.signupValidation,
        {'email': email, 'otp': otp},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
