import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication interceptor for injecting Bearer token into requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Get mobile number for additional authentication if needed
    final mobile = prefs.getString('mobile_number');
    if (mobile != null && mobile.isNotEmpty) {
      options.headers['X-Mobile-Number'] = mobile;
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('mobile_number');
      
      // TODO: Navigate to login screen
      // You might want to use a global navigator key here
    }
    
    super.onError(err, handler);
  }
}



