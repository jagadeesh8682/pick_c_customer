import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../screens/auth/repo/auth_models.dart';
import '../../constants/app_url.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

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
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _clearAuthToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<void> setAuthToken(String token) async {
    _ensureInitialized();
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    _ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  void _clearAuthToken() {
    _authToken = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });
  }

  // Authentication APIs
  Future<Token> login(LoginCredentials credentials) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.login,
        data: credentials.toJson(),
      );
      return Token.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> logout() async {
    _ensureInitialized();
    try {
      await _dio.post(AppUrl.logout);
      _clearAuthToken();
      return true;
    } catch (e) {
      _clearAuthToken();
      return true; // Always logout locally even if server fails
    }
  }

  Future<Customer> signUp(SignUpRequest request) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.saveCustomerDetails,
        data: request.toJson(),
      );
      return Customer.fromJson(response.data);
    } catch (e) {
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

  Future<bool> verifyOTP(String mobile, String otp) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(
        AppUrl.replacePathParams(AppUrl.verifyOtp, {
          'mobile': mobile,
          'otp': otp,
        }),
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
