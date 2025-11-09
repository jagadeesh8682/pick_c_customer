import '../../../core/data/services/api_service.dart';
import '../../../core/data/models/payment/payment_models.dart';

/// Repository for payment-related API operations
class PaymentRepository {
  final ApiService _apiService = ApiService();

  /// Get bill details for booking
  Future<BillDetails> getBillDetails(String bookingNo) async {
    try {
      return await _apiService.getBillDetails(bookingNo);
    } catch (e) {
      throw Exception('Failed to get bill details: $e');
    }
  }

  /// Pay by cash
  Future<bool> payByCash({
    required String bookingNo,
    required String driverId,
    String payType = '1100', // 1100 for cash
  }) async {
    try {
      return await _apiService.payByCash(bookingNo, driverId, payType);
    } catch (e) {
      throw Exception('Failed to process cash payment: $e');
    }
  }

  /// Get RSA key for online payment
  Future<RSAKeyResponse> getRSAKey({
    required String bookingNumber,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final request = PaymentRequest(
        bookingNumber: bookingNumber,
        driverId: '', // Not needed for RSA key
        paymentMethod: paymentMethod,
        amount: amount,
      );
      return await _apiService.getRSAKey(request);
    } catch (e) {
      throw Exception('Failed to get RSA key: $e');
    }
  }

  /// Check if customer has due payment
  Future<bool> hasCustomerDuePayment() async {
    try {
      return await _apiService.hasCustomerDuePayment();
    } catch (e) {
      throw Exception('Failed to check payment status: $e');
    }
  }
}

