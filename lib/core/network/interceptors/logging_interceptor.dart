import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

/// Logging interceptor for Dio that logs curl commands and responses
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final curlCommand = _buildCurlCommand(options);

    log('═══════════════════════════════════════════════════════════');
    log('📤 API REQUEST');
    log('═══════════════════════════════════════════════════════════');
    log('Method: ${options.method}');
    log('URL: ${options.uri}');
    log('Headers: ${_formatHeaders(options.headers)}');
    if (options.data != null) {
      log('Body: ${_formatBody(options.data)}');
    }
    log('');
    log('📋 CURL COMMAND:');
    log('───────────────────────────────────────────────────────────');
    log(curlCommand);
    log('───────────────────────────────────────────────────────────');
    log('');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('═══════════════════════════════════════════════════════════');
    log('📥 API RESPONSE');
    log('═══════════════════════════════════════════════════════════');
    log('Status Code: ${response.statusCode}');
    log('URL: ${response.requestOptions.uri}');
    log('Response Type: ${response.data.runtimeType}');
    log('Response Data:');
    log('───────────────────────────────────────────────────────────');
    log(_formatResponse(response.data));
    log('───────────────────────────────────────────────────────────');
    log('');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('═══════════════════════════════════════════════════════════');
    log('❌ API ERROR');
    log('═══════════════════════════════════════════════════════════');
    log('Error Type: ${err.type}');
    log('Error Message: ${err.message}');
    log('URL: ${err.requestOptions.uri}');
    log('Method: ${err.requestOptions.method}');

    if (err.response != null) {
      log('Status Code: ${err.response?.statusCode}');
      log('Response Data:');
      log('───────────────────────────────────────────────────────────');
      log(_formatResponse(err.response?.data));
      log('───────────────────────────────────────────────────────────');
    } else {
      log('No response received');
    }

    log('');
    log('📋 CURL COMMAND (for retry):');
    log('───────────────────────────────────────────────────────────');
    log(_buildCurlCommand(err.requestOptions));
    log('───────────────────────────────────────────────────────────');
    log('');

    super.onError(err, handler);
  }

  /// Build curl command from RequestOptions
  String _buildCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();

    // Start with curl command
    buffer.write('curl -X ${options.method}');

    // Add URL
    buffer.write(' \'${options.uri}\'');

    // Add headers
    options.headers.forEach((key, value) {
      if (key.toLowerCase() != 'content-length') {
        buffer.write(' \\\n  -H \'$key: $value\'');
      }
    });

    // Add body for POST, PUT, PATCH
    if (options.data != null &&
        ['POST', 'PUT', 'PATCH'].contains(options.method.toUpperCase())) {
      String body;
      if (options.data is String) {
        body = options.data as String;
      } else if (options.data is Map || options.data is List) {
        body = jsonEncode(options.data);
      } else {
        body = options.data.toString();
      }

      // Escape single quotes in body
      body = body.replaceAll("'", "'\\''");
      buffer.write(' \\\n  -d \'$body\'');
    }

    return buffer.toString();
  }

  /// Format headers for logging
  String _formatHeaders(Map<String, dynamic> headers) {
    final formatted = <String>[];
    headers.forEach((key, value) {
      // Mask sensitive headers in formatted output (but keep full in curl)
      if (key.toLowerCase() == 'authorization') {
        final authValue = value.toString();
        if (authValue.length > 30) {
          formatted.add('$key: ${authValue.substring(0, 30)}... (masked)');
        } else {
          formatted.add('$key: *** (masked)');
        }
      } else {
        formatted.add('$key: $value');
      }
    });
    return formatted.join('\n  ');
  }

  /// Format request body for logging
  String _formatBody(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is String) {
        // Try to format as JSON if possible
        try {
          final json = jsonDecode(data);
          return _formatJson(json);
        } catch (e) {
          return data;
        }
      } else if (data is Map || data is List) {
        return _formatJson(data);
      } else if (data is FormData) {
        // Handle FormData
        final fields = <String>[];
        data.fields.forEach((field) {
          fields.add('${field.key}: ${field.value}');
        });
        return fields.join('\n  ');
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }

  /// Format response data for logging
  String _formatResponse(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is String) {
        // Try to format as JSON if possible
        try {
          final json = jsonDecode(data);
          return _formatJson(json);
        } catch (e) {
          return data;
        }
      } else if (data is Map || data is List) {
        return _formatJson(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }

  /// Format JSON with indentation
  String _formatJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}
