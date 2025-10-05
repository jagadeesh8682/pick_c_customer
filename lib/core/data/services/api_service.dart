import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../screens/auth/repo/auth_models.dart';
import '../../constants/app_url.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void _ensureInitialized() {
    try {
      _dio;
    } catch (e) {
      initialize();
    }
  }

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppUrl.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(LoginCredentials credentials) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.login,
        data: credentials.toJson(),
      );
      log('response---->$response');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> logout() async {
    _ensureInitialized();
    try {
      await _dio.post(AppUrl.logout);
      return true;
    } catch (e) {
      return true; // Always logout locally even if server fails
    }
  }

  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    _ensureInitialized();
    try {
      final url = '${AppUrl.baseUrl}/${AppUrl.saveCustomerDetails}';
      log('SignUp request URL: $url');
      log('SignUp request data: ${request.toJson()}');

      final response = await _dio.post(url, data: request.toJson());
      log('SignUp response: ${response.data}');
      log('SignUp response type: ${response.data.runtimeType}');

      // Handle both boolean and Map responses
      if (response.data is bool) {
        return {'success': response.data};
      } else if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        // Convert other types to Map
        return {'success': true, 'data': response.data};
      }
    } catch (e) {
      log('SignUp error: $e');
      throw _handleError(e);
    }
  }

  Future<Customer> getUserDetails(String mobile) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(
        AppUrl.replacePathParams(AppUrl.userDetails, {'mobile': mobile}),
      );
      return Customer.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> saveDeviceId(Device device) async {
    _ensureInitialized();
    try {
      await _dio.post(AppUrl.saveDeviceId, data: device.toJson());
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> isNewNumber(String mobile) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(
        AppUrl.replacePathParams(AppUrl.isNewNumber, {'mobile': mobile}),
      );
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> generateOTP(String mobile) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(
        AppUrl.replacePathParams(AppUrl.generateOtp, {'mobile': mobile}),
      );
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.forgotPassword,
        data: request.toJson(),
      );
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> changePassword(
    String mobile,
    ChangePasswordRequest request,
  ) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.replacePathParams(AppUrl.changePassword, {'mobile': mobile}),
        data: request.toJson(),
      );
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data?['message'] ?? 'Server error occurred';
          return 'Error $statusCode: $message';
        case DioExceptionType.cancel:
          return 'Request was cancelled';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badCertificate:
          return 'Certificate error occurred';
        case DioExceptionType.unknown:
          return 'An unexpected error occurred';
      }
    }
    return error.toString();
  }
}
