import '../../../core/data/services/api_service.dart';

/// Repository for support/query-related API operations
class SupportRepository {
  final ApiService _apiService = ApiService();

  /// Send query to support
  Future<bool> sendQuery({
    required String customerMobile,
    required String subject,
    required String message,
    required String queryType,
  }) async {
    try {
      return await _apiService.sendQuery(
        customerMobile: customerMobile,
        subject: subject,
        message: message,
        queryType: queryType,
      );
    } catch (e) {
      throw Exception('Failed to send query: $e');
    }
  }
}

