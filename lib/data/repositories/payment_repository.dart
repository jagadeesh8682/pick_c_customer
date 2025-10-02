import '../../core/network/network_service.dart';
import '../../core/constants/app_url.dart';

class PaymentRepository {
  final NetworkService _networkService;

  PaymentRepository({required NetworkService networkService})
    : _networkService = networkService;

  Future<Map<String, dynamic>> getAmountOfCurrentBooking({
    required String bookingNo,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.getAmountCurrentBooking.replaceAll('{bno}', bookingNo),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> payByCash({
    required String bookingNo,
    required String driverId,
    required String payType,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.payByCash
                .replaceAll('{bookingNo}', bookingNo)
                .replaceAll('{mDriverId}', driverId)
                .replaceAll('{payType}', payType),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOnlinePaymentStatus({
    required Map<String, dynamic> paymentData,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.onlinePayment,
        paymentData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserInvoiceDetails({
    required String bookingNumber,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.getUserInvoiceDetails.replaceAll(
              '{bookingNumber}',
              bookingNumber,
            ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendInvoiceMail({
    required String bookingNo,
    required String email,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.sendInvoiceMail
                .replaceAll('{bno}', bookingNo)
                .replaceAll('{email}', email),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPaymentDue() async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.hasCustomerDuePayment,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
