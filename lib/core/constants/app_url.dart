class AppUrl {
  static const String baseUrl = 'http://api.pickcargo.in/api';
  static const String webApiAddress = 'http://api.pickcargo.in/';

  // Authentication
  static const String login = '/master/customer/login';
  static const String logout = 'master/customer/logout';
  static const String userDetails = 'master/customer/{mobile}';
  static const String saveCustomerDetails = 'master/customer/save';
  static const String saveDeviceId = 'master/customer/deviceId';
  static const String isNewNumber = 'master/customer/check/{mobile}';
  static const String verifyOtp = 'master/customer/verifyOtp/{mobile}/{otp}';
  static const String generateOtp = 'master/customer/forgotPassword/{mobile}';
  static const String forgotPassword = 'master/customer/forgotPassword';
  static const String changePassword =
      'master/customer/changePassword/{mobile}';
  static const String updateUserData = 'master/customer/{mobile}';
  static const String validateYourPwd =
      'master/customer/checkCustomerPassword/{mobile}/{password}';

  // Vehicle & Cargo
  static const String getVehicleTypes = 'master/customer/vehicleGroupList';
  static const String getOpenClosed = 'master/customer/vehicleTypeList';
  static const String getCargoTypes = 'master/customer/cargoTypeList';
  static const String getTrucksFromNearLocation =
      'operation/driveractivity/user';
  // New lookup APIs
  static const String getVehicleTypeList = 'master/vehicletype/list';
  static const String getVehicleGroupList = 'master/vehiclegroup/list';
  static const String selectedRateCard =
      'master/rateCard/{closedOpenId}/{truckId}';

  // Booking
  static const String bookingHistory =
      '/master/customer/bookingHistoryListbyCustomerMobileNo/{mobile}';
  static const String getBookingInfo = 'master/customer/booking/{bookingno}';
  static const String confirmBooking = 'master/customer/bookingSave';
  static const String cancelBooking = 'master/customer/cancelBooking';
  static const String getTripEstimate = 'master/customer/tripEstimate';
  static const String isCustomerInTrip = 'master/customer/isInTrip';
  static const String hasCustomerDuePayment =
      'master/customer/customerPaymentsIsPaidCheck';

  // Driver
  static const String getConfirmedDriverDetails =
      'master/customer/isConfirm/{bno}';
  static const String driverCurLatLngPickup =
      'master/customer/drivergeOposition/{dId}';
  static const String getDriverRating =
      'master/customer/avgDriverRating/{mDriverId}';
  static const String isDriverReachedPickUpLocation =
      'master/customer/isReachPickupWaiting';
  static const String monitorDriver =
      'master/customer/driverMonitorInCustomer/{drvierId}';

  // Payment
  static const String getAmountCurrentBooking =
      'master/customer/billDetails/{bno}';
  static const String payByCash =
      'master/customer/pay/{bookingNo}/{mDriverId}/{payType}';
  static const String onlinePayment = 'master/customer/getRSAKey';
  static const String getUserInvoiceDetails =
      'master/customer/tripInvoice/{bookingNumber}';
  static const String sendInvoiceMail =
      'master/customer/sendInvoiceMail/{bno}/{email}/true';
  static const String userRatingDriver = 'master/customer/driverRating';

  // Support
  static const String sendQuery = 'master/customer/sendMessageToPickC';

  // Google Maps
  static const String googleMapBaseUrl =
      'https://maps.googleapis.com/maps/api/';
  static const String getAddressFromLatlng = 'geocode/json';
  static const String getTravelTimeBetSourceDestination = 'distancematrix/json';

  // Constants
  static const String timeOut = 'TimeoutError';
  static const int interval = 10000;

  static String replacePathParams(String url, Map<String, String> params) {
    String result = url;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
