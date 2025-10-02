import '../../core/network/network_service.dart';
import '../../core/constants/app_url.dart';

class SupportRepository {
  final NetworkService _networkService;

  SupportRepository({required NetworkService networkService})
    : _networkService = networkService;

  Future<Map<String, dynamic>> sendQuery({
    required Map<String, dynamic> queryData,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.sendQuery,
        queryData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkIsNewNumber({
    required String mobileNumber,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.isNewNumber.replaceAll('{mobile}', mobileNumber),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> validatePassword({
    required String mobileNumber,
    required String password,
  }) async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.validateYourPwd
                .replaceAll('{mobile}', mobileNumber)
                .replaceAll('{password}', password),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserData({
    required String mobileNumber,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.baseUrl +
            AppUrl.updateUserData.replaceAll('{mobile}', mobileNumber),
        userData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveDeviceId({
    required Map<String, dynamic> deviceData,
  }) async {
    try {
      final response = await _networkService.getPostApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.saveDeviceId,
        deviceData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkCustomerInTrip() async {
    try {
      final response = await _networkService.getGetApiResponseUnauthenticated(
        AppUrl.baseUrl + AppUrl.isCustomerInTrip,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
