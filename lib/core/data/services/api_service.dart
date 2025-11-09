import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../screens/auth/repo/auth_models.dart';
import '../../constants/app_url.dart';
import '../../constants/api_keys.dart';
import '../../network/interceptors/auth_interceptor.dart';
import '../../network/interceptors/logging_interceptor.dart';
import '../models/booking/booking_models.dart';
import '../models/vehicle/vehicle_models.dart';
import '../models/driver/driver_models.dart';
import '../models/payment/payment_models.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

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

    // Add authentication interceptor first (to add auth headers)
    _dio.interceptors.add(AuthInterceptor());

    // Add logging interceptor after auth (to log final request with headers)
    _dio.interceptors.add(LoggingInterceptor());
  }

  // Authentication APIs
  /// Login API: POST /master/customer/login
  /// Request Body: { "mobileNo": "String", "password": "String" }
  /// Response: Token object with authentication token
  Future<Map<String, dynamic>> login(LoginCredentials credentials) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.login,
        data: credentials.toJson(),
      );
      log('Login response type: ${response.data.runtimeType}');
      log('Login response data: ${response.data}');

      // Safely convert response.data to a workable format
      dynamic responseData = response.data;

      // Handle different possible response formats
      if (responseData is List) {
        // If response is a List, try to extract token from first element
        try {
          if (responseData.isNotEmpty) {
            final firstItem = responseData[0];
            if (firstItem is Map) {
              final data = Map<String, dynamic>.from(firstItem);
              final token = data['token'] ?? data['Token'] ?? '';
              return {
                'Status': token.isNotEmpty,
                'Token': token.toString(),
                'tokenType': 'Bearer',
                'expiresIn': 3600,
                'Message': token.isNotEmpty
                    ? 'Login successful'
                    : 'Login failed',
              };
            }
          }
          throw Exception(
            'Invalid login response format: List with invalid structure',
          );
        } catch (e) {
          log('Error parsing List response: $e');
          throw Exception('Failed to parse login response: $e');
        }
      } else if (responseData is Map) {
        // Convert to Map<String, dynamic> safely
        final data = Map<String, dynamic>.from(responseData);

        // Check if response contains token in various possible fields
        final token =
            data['token'] ??
            data['Token'] ??
            data['accessToken'] ??
            data['access_token'] ??
            data['authToken'] ??
            '';

        // Extract status if available
        final status =
            data['status'] ??
            data['Status'] ??
            data['success'] ??
            (token.isNotEmpty ? true : false);

        // Return standardized response format
        return {
          'Status': status == true || status == 'true',
          'Token': token.toString(),
          'tokenType': data['tokenType'] ?? data['token_type'] ?? 'Bearer',
          'expiresIn': data['expiresIn'] ?? data['expires_in'] ?? 3600,
          'Message':
              data['message'] ??
              data['Message'] ??
              (token.isNotEmpty ? 'Login successful' : 'Login failed'),
        };
      } else if (responseData is String) {
        // If response is just a token string
        final tokenString = responseData.toString();
        log(
          'Login API returned token string: ${tokenString.length > 20 ? tokenString.substring(0, 20) : tokenString}...',
        );
        return {
          'Status': true,
          'Token': tokenString,
          'tokenType': 'Bearer',
          'expiresIn': 3600,
          'Message': 'Login successful',
        };
      } else {
        log(
          'Warning: Unexpected login response format: ${responseData.runtimeType}',
        );
        return {
          'Status': false,
          'Token': '',
          'Message': 'Invalid response format: ${responseData.runtimeType}',
        };
      }
    } catch (e, stackTrace) {
      log('Login error: $e');
      log('Stack trace: $stackTrace');
      // Re-throw as exception with proper message
      if (e is DioException) {
        final errorMessage = _handleError(e);
        throw Exception(errorMessage);
      } else {
        // Extract the actual error message
        String errorMsg = e.toString();
        if (errorMsg.contains('type') && errorMsg.contains('subtype')) {
          errorMsg = 'Invalid response format from server. Please try again.';
        }
        throw Exception(errorMsg);
      }
    }
  }

  Future<bool> logout() async {
    _ensureInitialized();
    try {
      await _dio.post(AppUrl.logout);
      return true;
    } catch (e) {
      return true; // Always logout locally even if server fails
    }
  }

  Future<Map<String, dynamic>> signUp(SignUpRequest request) async {
    _ensureInitialized();
    try {
      final url = '${AppUrl.baseUrl}/${AppUrl.saveCustomerDetails}';
      log('SignUp request URL: $url');
      log('SignUp request data: ${request.toJson()}');

      final response = await _dio.post(url, data: request.toJson());
      log('SignUp response: ${response.data}');
      log('SignUp response type: ${response.data.runtimeType}');

      // Handle both boolean and Map responses
      if (response.data is bool) {
        return {'success': response.data};
      } else if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        // Convert other types to Map
        return {'success': true, 'data': response.data};
      }
    } catch (e) {
      log('SignUp error: $e');
      throw _handleError(e);
    }
  }

  Future<Customer> getUserDetails(String mobile) async {
    _ensureInitialized();
    try {
      final response = await _dio.get(
        AppUrl.replacePathParams(AppUrl.userDetails, {'mobile': mobile}),
      );

      log('User details response type: ${response.data.runtimeType}');
      log('User details response: ${response.data}');

      // Safely convert response.data
      dynamic responseData = response.data;

      // Handle different response formats
      if (responseData is Map) {
        // Convert to Map<String, dynamic> safely
        try {
          final data = Map<String, dynamic>.from(responseData);
          return Customer.fromJson(data);
        } catch (e) {
          log('Error converting Map to Customer: $e');
          throw Exception('Failed to parse user details: $e');
        }
      } else if (responseData is List) {
        // If API returns a list, take the first element
        try {
          if (responseData.isNotEmpty) {
            final firstItem = responseData[0];
            if (firstItem is Map) {
              final data = Map<String, dynamic>.from(firstItem);
              return Customer.fromJson(data);
            } else {
              throw Exception(
                'Invalid response format: List element is not a Map',
              );
            }
          } else {
            throw Exception('Invalid response format: Empty list received');
          }
        } catch (e) {
          log('Error parsing List response: $e');
          throw Exception('Failed to parse user details from list: $e');
        }
      } else {
        throw Exception(
          'Invalid response format: expected Map or List, got ${responseData.runtimeType}',
        );
      }
    } catch (e, stackTrace) {
      log('Error getting user details: $e');
      log('Stack trace: $stackTrace');
      if (e is DioException && e.response != null) {
        log('Response data type: ${e.response!.data.runtimeType}');
        log('Response data: ${e.response!.data}');
      }
      // Provide user-friendly error message
      String errorMsg = e.toString();
      if (errorMsg.contains('type') && errorMsg.contains('subtype')) {
        errorMsg = 'Invalid response format from server. Please try again.';
      }
      throw Exception(errorMsg);
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

  /// Verify OTP: GET /master/customer/verifyOtp/{mobile}/{otp}
  Future<bool> verifyOTP(String mobile, String otp) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.verifyOtp, {
        'mobile': mobile,
        'otp': otp,
      });
      final response = await _dio.get(url);
      // Response can be boolean or Map with status
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return data['status'] == true || data['success'] == true;
      }
      return false;
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

  // Vehicle & Booking APIs
  Future<List<VehicleGroup>> getVehicleGroups() async {
    _ensureInitialized();
    try {
      final response = await _dio.get(AppUrl.getVehicleTypes);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => VehicleGroup.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<VehicleType>> getVehicleTypes() async {
    _ensureInitialized();
    try {
      final response = await _dio.get(AppUrl.getOpenClosed);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => VehicleType.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get vehicle types from lookup API
  /// GET /master/vehicletype/list
  Future<List<VehicleLookup>> getVehicleTypeList() async {
    _ensureInitialized();
    try {
      log(
        'Fetching vehicle types from: ${AppUrl.baseUrl}/${AppUrl.getVehicleTypeList}',
      );
      final response = await _dio.get(AppUrl.getVehicleTypeList);
      log('Vehicle types response type: ${response.data.runtimeType}');
      log('Vehicle types response: ${response.data}');

      if (response.data is List) {
        final list = (response.data as List)
            .map((json) => VehicleLookup.fromJson(json))
            .toList();
        log('✅ Parsed ${list.length} vehicle types');
        return list;
      } else {
        log(
          '⚠️ Vehicle types response is not a List: ${response.data.runtimeType}',
        );
        return [];
      }
    } catch (e, stackTrace) {
      log('❌ Error fetching vehicle types: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get vehicle groups from lookup API
  /// GET /master/vehiclegroup/list
  Future<List<VehicleLookup>> getVehicleGroupList() async {
    _ensureInitialized();
    try {
      log(
        'Fetching vehicle groups from: ${AppUrl.baseUrl}/${AppUrl.getVehicleGroupList}',
      );
      final response = await _dio.get(AppUrl.getVehicleGroupList);
      log('Vehicle groups response type: ${response.data.runtimeType}');
      log('Vehicle groups response: ${response.data}');

      if (response.data is List) {
        final list = (response.data as List)
            .map((json) => VehicleLookup.fromJson(json))
            .toList();
        log('✅ Parsed ${list.length} vehicle groups');
        return list;
      } else {
        log(
          '⚠️ Vehicle groups response is not a List: ${response.data.runtimeType}',
        );
        return [];
      }
    } catch (e, stackTrace) {
      log('❌ Error fetching vehicle groups: $e');
      log('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<CargoType>> getCargoTypes() async {
    _ensureInitialized();
    try {
      final response = await _dio.get(AppUrl.getCargoTypes);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => CargoType.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Truck>> searchNearbyTrucks(NearestDataRequest request) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.getTrucksFromNearLocation,
        data: request.toJson(),
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Truck.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RateCard> getRateCard(String closedOpenId, String truckId) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.selectedRateCard, {
        'closedOpenId': closedOpenId,
        'truckId': truckId,
      });
      final response = await _dio.get(url);
      return RateCard.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TripEstimate> getTripEstimate(TripEstimateRequest request) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.getTripEstimate,
        data: request.toJson(),
      );
      return TripEstimate.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<BookingResponse> confirmBooking(BookingRequest request) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.confirmBooking,
        data: request.toJson(),
      );
      return BookingResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> cancelBooking(CancelBookingRequest request) async {
    _ensureInitialized();
    try {
      await _dio.post(AppUrl.cancelBooking, data: request.toJson());
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Driver APIs
  Future<DriverDetails> getDriverDetails(String bookingNo) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.getConfirmedDriverDetails, {
        'bno': bookingNo,
      });
      final response = await _dio.get(url);
      return DriverDetails.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DriverLocation> getDriverLocation(String driverId) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.driverCurLatLngPickup, {
        'dId': driverId,
      });
      final response = await _dio.get(url);
      return DriverLocation.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DriverRating> getDriverRating(String driverId) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.getDriverRating, {
        'mDriverId': driverId,
      });
      final response = await _dio.get(url);
      return DriverRating.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> checkDriverReachedPickup() async {
    _ensureInitialized();
    try {
      final response = await _dio.get(AppUrl.isDriverReachedPickUpLocation);
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Monitor driver location continuously
  /// GET /master/customer/driverMonitorInCustomer/{drvierId}
  Future<DriverLocation> monitorDriverLocation(String driverId) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.monitorDriver, {
        'drvierId': driverId,
      });
      final response = await _dio.get(url);
      return DriverLocation.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get booking information
  /// GET /master/customer/booking/{bookingno}
  Future<Map<String, dynamic>> getBookingInfo(String bookingNo) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.getBookingInfo, {
        'bookingno': bookingNo,
      });
      final response = await _dio.get(url);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Validate customer password
  /// GET /master/customer/checkCustomerPassword/{mobile}/{password}
  Future<bool> validatePassword(String mobile, String password) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.validateYourPwd, {
        'mobile': mobile,
        'password': password,
      });
      final response = await _dio.get(url);
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return data['valid'] == true || data['status'] == true;
      }
      return false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit driver rating
  /// POST /master/customer/driverRating
  Future<bool> submitDriverRating({
    required String driverId,
    required int rating,
    String? comment,
    required String bookingNumber,
  }) async {
    _ensureInitialized();
    try {
      final requestData = {
        'driverId': driverId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        'bookingNumber': bookingNumber,
      };
      final response = await _dio.post(
        AppUrl.userRatingDriver,
        data: requestData,
      );
      if (response.data is bool) {
        return response.data as bool;
      } else if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        return data['success'] == true || data['status'] == true;
      }
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Payment APIs
  Future<BillDetails> getBillDetails(String bookingNo) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.getAmountCurrentBooking, {
        'bno': bookingNo,
      });
      final response = await _dio.get(url);
      return BillDetails.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> payByCash(
    String bookingNo,
    String driverId,
    String payType,
  ) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.payByCash, {
        'bookingNo': bookingNo,
        'mDriverId': driverId,
        'payType': payType,
      });
      await _dio.get(url);
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<RSAKeyResponse> getRSAKey(PaymentRequest request) async {
    _ensureInitialized();
    try {
      final response = await _dio.post(
        AppUrl.onlinePayment,
        data: request.toJson(),
      );
      return RSAKeyResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Invoice APIs
  Future<Invoice> getInvoice(String bookingNumber) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.getUserInvoiceDetails, {
        'bookingNumber': bookingNumber,
      });
      final response = await _dio.get(url);
      return Invoice.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> sendInvoiceEmail(String bookingNo, String email) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.sendInvoiceMail, {
        'bno': bookingNo,
        'email': email,
      });
      await _dio.get(url);
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Trip Status APIs
  Future<bool> isInTrip() async {
    _ensureInitialized();
    try {
      final response = await _dio.get(AppUrl.isCustomerInTrip);
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> hasCustomerDuePayment() async {
    _ensureInitialized();
    try {
      final response = await _dio.get(AppUrl.hasCustomerDuePayment);
      return response.data ?? false;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Support API
  /// Send query to support
  /// POST /master/customer/sendMessageToPickC
  Future<bool> sendQuery({
    required String customerMobile,
    required String subject,
    required String message,
    required String queryType,
  }) async {
    _ensureInitialized();
    try {
      final queryData = {
        'customerMobile': customerMobile,
        'subject': subject,
        'message': message,
        'queryType': queryType,
      };
      await _dio.post(AppUrl.sendQuery, data: queryData);
      return true;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update User Data
  /// Update user data
  /// POST /master/customer/{mobile}
  /// Body: { "Name": "String", "EmailId": "String", "Password": "String" }
  Future<Customer> updateUserData(
    String mobile, {
    required String name,
    required String emailId,
    required String password,
  }) async {
    _ensureInitialized();
    try {
      final url = AppUrl.replacePathParams(AppUrl.updateUserData, {
        'mobile': mobile,
      });
      final data = {'Name': name, 'EmailId': emailId, 'Password': password};
      final response = await _dio.post(url, data: data);
      return Customer.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Google Maps APIs
  /// Reverse geocoding - Get address from coordinates
  /// GET https://maps.googleapis.com/maps/api/geocode/json
  Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
    String language = 'en_IN',
  }) async {
    try {
      final googleMapsApiKey = ApiKeys.googleMapsApiKey;
      if (googleMapsApiKey.isEmpty) {
        throw Exception('Google Maps API key not configured');
      }

      final url =
          '${AppUrl.googleMapBaseUrl}${AppUrl.getAddressFromLatlng}?latlng=$latitude,$longitude&key=$googleMapsApiKey&language=$language';

      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
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
