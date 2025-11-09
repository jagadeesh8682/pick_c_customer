import '../../../core/data/services/api_service.dart';

/// Repository for rating-related API operations
class RatingRepository {
  final ApiService _apiService = ApiService();

  /// Submit driver rating
  Future<bool> submitRating({
    required String driverId,
    required int rating,
    String? comment,
    required String bookingNumber,
  }) async {
    try {
      return await _apiService.submitDriverRating(
        driverId: driverId,
        rating: rating,
        comment: comment,
        bookingNumber: bookingNumber,
      );
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }
}

