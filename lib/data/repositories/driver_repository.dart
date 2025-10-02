import '../../core/network/network_service.dart';
import '../../core/constants/app_url.dart';

class DriverRepository {
  final NetworkService _networkService;

  DriverRepository({required NetworkService networkService})
    : _networkService = networkService;

  Future<Map<String, dynamic>> getConfirmedDriverDetails({
    required String bookingNo,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.getConfirmedDriverDetails.replaceAll('{bno}', bookingNo),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> monitorDriver({required String driverId}) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.monitorDriver.replaceAll('{drvierId}', driverId),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDriverCurrentLocation({
    required String driverId,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.driverCurLatLngPickup.replaceAll('{dId}', driverId),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> isDriverReachedPickupLocation() async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.isDriverReachedPickUpLocation,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendUserRating({
    required Map<String, dynamic> ratingData,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.userRatingDriver,
        ratingData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDriverAverageRating({
    required String driverId,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.getDriverRating.replaceAll('{mDriverId}', driverId),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
