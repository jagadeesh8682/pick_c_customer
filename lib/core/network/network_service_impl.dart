import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'network_service.dart';

class NetworkServiceImpl implements NetworkService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  @override
  Future getGetApiResponse(String url) async {
    try {
      final response = await _makeRequestWithRetry(() async {
        final headers = await _buildHeaders();
        return await http
            .get(Uri.parse(url), headers: headers)
            .timeout(_defaultTimeout);
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Get API response without authentication headers (for public endpoints)
  @override
  Future getGetApiResponseUnauthenticated(String url) async {
    try {
      final headers = {"Content-Type": "application/json"};
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_defaultTimeout);
      log('response---->$response');
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future getPostApiResponse(String url, [dynamic data]) async {
    try {
      final response = await _makeRequestWithRetry(() async {
        final headers = await _buildHeaders();
        return await http
            .post(
              Uri.parse(url),
              body: data != null ? jsonEncode(data) : null,
              headers: headers,
            )
            .timeout(_defaultTimeout);
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Post API response without authentication headers (for OTP verification, login, etc.)
  @override
  Future getPostApiResponseUnauthenticated(String url, [dynamic data]) async {
    try {
      log('NetworkServiceImpl: Making POST request to: $url');
      log('NetworkServiceImpl: Request data: $data');

      final headers = {"Content-Type": "application/json"};
      log('NetworkServiceImpl: Request headers: $headers');

      final response = await http
          .post(
            Uri.parse(url),
            body: data != null ? jsonEncode(data) : null,
            headers: headers,
          )
          .timeout(_defaultTimeout);

      log('NetworkServiceImpl: Response status: ${response.statusCode}');
      log('NetworkServiceImpl: Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      log('NetworkServiceImpl: Error in getPostApiResponseUnauthenticated: $e');
      log('NetworkServiceImpl: Error type: ${e.runtimeType}');
      return _handleError(e);
    }
  }

  @override
  Future getPutApiResponse(String url, [dynamic data]) async {
    try {
      final response = await _makeRequestWithRetry(() async {
        final headers = await _buildHeaders();
        return await http
            .put(
              Uri.parse(url),
              body: data != null ? jsonEncode(data) : null,
              headers: headers,
            )
            .timeout(_defaultTimeout);
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  @override
  Future getDeleteApiResponse(String url) async {
    try {
      final response = await _makeRequestWithRetry(() async {
        final headers = await _buildHeaders();
        return await http
            .delete(Uri.parse(url), headers: headers)
            .timeout(_defaultTimeout);
      });
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case >= 200 && < 300: //9444246473 123456
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw FormatException("Invalid JSON: ${response.body}");
        }
      case 400:
        return _handleBadRequest(response);
      case 401:
        throw Exception("Unauthorized - Session expired");
      case 403:
        throw Exception("Access denied");
      case 404:
        // Handle 404 responses that might contain valid JSON with error messages
        return _handleNotFoundResponse(response);
      case 500:
        throw Exception("Internal server error");
      default:
        throw Exception(
          "HTTP ${response.statusCode}: ${response.reasonPhrase}",
        );
    }
  }

  dynamic _handleBadRequest(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      // Return the error data instead of throwing, so caller can handle specific errors
      return errorData;
    } catch (e) {
      if (e is FormatException) {
        throw Exception("Bad request: ${response.body}");
      }
      rethrow;
    }
  }

  dynamic _handleNotFoundResponse(http.Response response) {
    try {
      // Try to parse the response body as JSON
      final data = jsonDecode(response.body);
      // If it's a valid JSON response, return it (might contain error info)
      return data;
    } catch (e) {
      // If it's not valid JSON, throw a generic 404 error
      throw Exception("Resource not found");
    }
  }

  Future<http.Response> _makeRequestWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        final response = await request();
        return response;
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          rethrow;
        }
        // Wait before retrying
        await Future.delayed(_retryDelay * attempts);
      }
    }
    throw Exception("Max retries exceeded");
  }

  Future<Map<String, String>> _buildHeaders() async {
    // Simple headers without authentication tokens
    return {"Content-Type": "application/json"};
  }

  dynamic _handleError(dynamic error) {
    if (error is FormatException) {
      throw Exception("Data format error: ${error.message}");
    } else if (error is Exception) {
      throw error;
    } else {
      throw Exception("Network error: $error");
    }
  }
}
