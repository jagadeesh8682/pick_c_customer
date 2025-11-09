# API Integration Analysis - Pick-C Customer Flutter App

## Executive Summary

This document provides a comprehensive analysis of the current API implementation state and recommendations for integrating all API endpoints from the Android reference document into the Flutter application.

**Date**: 2025-01-20
**Base URL**: `http://api.pickcargo.in/api/`

---

## Current State Analysis

### ✅ What's Already Implemented

1. **Authentication APIs** (Partial)
   - Login (`POST /master/customer/login`)
   - Sign Up (`POST /master/customer/save`)
   - Get User Details (`GET /master/customer/{mobile}`)
   - Device ID registration
   - OTP generation for forgot password
   - Token management via SharedPreferences

2. **Infrastructure**
   - Dio-based API service (`ApiService`)
   - Network service using http package (`NetworkService`)
   - Credential management utility
   - URL constant definitions

### ❌ What's Missing

**Critical Gaps Identified:**

1. **Dual API Implementation** - Two different approaches exist:
   - `ApiService` (Dio-based) - Primary service
   - `NetworkServiceImpl` (http-based) - Used by some repositories
   - **Issue**: Inconsistent approach, makes maintenance difficult

2. **Missing API Endpoints** (36 total, only ~8 implemented):
   - Booking-related: Truck search, trip estimate, booking confirmation
   - Vehicle selection: Vehicle groups, types, rate cards
   - Driver tracking: Real-time location monitoring
   - Payment: Cash payment, online payment, invoice
   - Profile: Update user data, change password
   - Support: Send query

3. **Missing API Models**:
   - Booking models
   - Vehicle/rate card models
   - Driver models
   - Payment models
   - Invoice models

4. **Authentication Issues**:
   - Token not properly stored in Dio interceptor
   - No automatic token refresh
   - Missing Bearer token injection

5. **Repository Pattern Issues**:
   - Some repositories use mock data
   - Inconsistent error handling
   - No centralized response parsing

---

## Recommendations

### Phase 1: Standardize API Architecture (Priority: High)

#### Action Items:

1. **Unify on Dio** (Recommended)
   - Remove http-based `NetworkServiceImpl`
   - Enhance `ApiService` with all required features
   - Add proper authentication interceptor

2. **Create Comprehensive API Models**
   - Location: `lib/core/data/models/`
   - Create models for: Booking, Vehicle, Driver, Payment, Invoice, etc.

3. **Implement Authentication Interceptor**
   - Auto-inject Bearer token
   - Handle token refresh
   - Retry logic for 401 errors

### Phase 2: Implement Core APIs (Priority: High)

Based on the API reference document, implement these critical endpoints:

#### 2.1 Vehicle Selection & Booking
```
✅ GET /master/customer/vehicleGroupList       - Get vehicle groups
✅ GET /master/customer/vehicleTypeList        - Get Open/Closed types
✅ POST /master/customer/user                   - Get trucks near location
✅ GET /master/rateCard/{closedOpenId}/{truckId} - Get rate card
✅ POST /master/customer/tripEstimate         - Get trip estimate
✅ POST /master/customer/bookingSave           - Confirm booking
```

#### 2.2 Driver Tracking
```
✅ GET /master/customer/isConfirm/{bno}        - Get confirmed driver
✅ GET /master/customer/drivergeOposition/{dId} - Get driver location
✅ GET /master/customer/avgDriverRating/{mDriverId} - Driver rating
✅ GET /master/customer/driverMonitorInCustomer/{drvierId} - Monitor driver
```

#### 2.3 Payment
```
✅ GET /master/customer/billDetails/{bno}      - Get booking amount
✅ GET /master/customer/pay/{bookingNo}/{mDriverId}/{payType} - Cash payment
✅ POST /master/customer/getRSAKey             - Get RSA key for online payment
✅ GET /master/customer/tripInvoice/{bookingNumber} - Get invoice
```

#### 2.4 Profile & Support
```
✅ POST /master/customer/{mobile}              - Update user data
✅ POST /master/customer/changePassword/{mobile} - Change password
✅ POST /master/customer/driverRating         - Rate driver
✅ POST /master/customer/sendMessageToPickC   - Send support query
```

### Phase 3: Enhanced Features (Priority: Medium)

1. **Booking Management**
   - Check active trips (`GET /master/customer/isInTrip`)
   - Check payment due status
   - Check driver reached pickup location

2. **Google Maps Integration**
   - Reverse geocoding
   - Distance matrix
   - Directions API

3. **Error Handling**
   - Standardized error responses
   - User-friendly error messages
   - Network error handling

---

## Implementation Plan

### Step 1: Create API Models

Create comprehensive models in `lib/core/data/models/`:

```
models/
├── api_response.dart          - Generic API response wrapper
├── booking/
│   ├── booking_request.dart   - Booking request model
│   ├── booking_response.dart  - Booking response model
│   └── trip_estimate.dart     - Trip estimate model
├── vehicle/
│   ├── vehicle_group.dart     - Vehicle group model
│   ├── vehicle_type.dart      - Vehicle type model
│   └── rate_card.dart        - Rate card model
├── driver/
│   ├── driver_details.dart    - Driver details model
│   ├── driver_location.dart  - Driver location model
│   └── driver_rating.dart    - Driver rating model
└── payment/
    ├── payment_request.dart  - Payment request model
    └── invoice.dart          - Invoice model
```

### Step 2: Enhance ApiService

Add all missing API methods to `ApiService` class:

```dart
class ApiService {
  // ... existing code ...
  
  // Vehicle & Booking APIs
  Future<List<VehicleGroup>> getVehicleGroups() async { }
  Future<List<VehicleType>> getVehicleTypes() async { }
  Future<List<Truck>> searchNearbyTrucks(NearestDataRequest request) async { }
  Future<RateCard> getRateCard(String closedOpenId, String truckId) async { }
  Future<TripEstimate> getTripEstimate(TripEstimateRequest request) async { }
  Future<BookingResponse> confirmBooking(BookingRequest request) async { }
  
  // Driver APIs
  Future<DriverDetails> getDriverDetails(String bookingNo) async { }
  Future<DriverLocation> getDriverLocation(String driverId) async { }
  Future<void> monitorDriver(String driverId) async { }
  
  // Payment APIs
  Future<BillDetails> getBillDetails(String bookingNo) async { }
  Future<bool> payByCash(String bookingNo, String driverId, String payType) async { }
  Future<String> getRSAKey(PaymentRequest request) async { }
  
  // Profile APIs
  Future<Customer> updateUserData(String mobile, UpdateUserRequest request) async { }
  Future<bool> changePassword(String mobile, ChangePasswordRequest request) async { }
  Future<bool> rateDriver(RatingRequest request) async { }
  
  // Support APIs
  Future<bool> sendQuery(QueryRequest request) async { }
}
```

### Step 3: Implement Authentication Interceptor

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle token refresh or logout
    }
    super.onError(err, handler);
  }
}
```

### Step 4: Update AppUrl Constants

Add missing endpoint constants:

```dart
class AppUrl {
  // ... existing code ...
  
  // Add missing endpoints
  static const String getVehicleGroups = 'master/customer/vehicleGroupList';
  static const String getVehicleTypes = 'master/customer/vehicleTypeList';
  static const String cargoTypes = 'master/customer/cargoTypeList';
  static const String cancelBooking = 'master/customer/cancelBooking';
  static const String isInTrip = 'master/customer/isInTrip';
  static const String checkPaymentDue = 'master/customer/customerPaymentsIsPaidCheck';
  static const String checkDriverReached = 'master/customer/isReachPickupWaiting';
  static const String sendInvoiceEmail = 'master/customer/sendInvoiceMail/{bno}/{email}/true';
  static const String driverRating = 'master/customer/avgDriverRating/{mDriverId}';
  static const String userRating = 'master/customer/driverRating';
  static const String sendQuery = 'master/customer/sendMessageToPickC';
  
  // Google Maps endpoints
  static const String geocoding = 'geocode/json';
  static const String distanceMatrix = 'distancematrix/json';
}
```

---

## File Structure Recommendations

```
lib/
├── core/
│   ├── data/
│   │   ├── models/               # All data models
│   │   └── repositories/         # Repository implementations
│   ├── network/
│   │   ├── api_service.dart      # Enhanced ApiService (Dio-based)
│   │   └── interceptors/         # Interceptors (auth, logging)
│   └── constants/
│       └── app_url.dart          # Updated with all endpoints
├── screens/
│   ├── booking/
│   │   └── repository/           # BookingRepository
│   ├── driver/
│   │   └── repository/           # DriverRepository
│   ├── payment/
│   │   └── repository/           # PaymentRepository
│   └── ...
```

---

## Testing Strategy

### 1. Unit Tests
- Test all API methods with mock responses
- Test error handling scenarios
- Test authentication flow

### 2. Integration Tests
- Test end-to-end booking flow
- Test driver tracking
- Test payment flow

### 3. Manual Testing Checklist
- [ ] Login/Logout
- [ ] Sign Up with OTP
- [ ] Search trucks
- [ ] Book truck
- [ ] Track driver
- [ ] Payment (cash & online)
- [ ] Rate driver
- [ ] View booking history
- [ ] Invoice download/email

---

## Security Considerations

1. **Token Management**
   - Store tokens securely in SharedPreferences
   - Never log tokens in production
   - Implement token refresh mechanism

2. **API Keys**
   - Store Google Maps API key in .env file ✅ (Already done)
   - Never commit API keys to version control ✅ (Already in .gitignore)

3. **HTTPS Consideration**
   - Current API uses HTTP (security concern)
   - Recommendation: Migrate to HTTPS ASAP

---

## Next Steps

### Immediate Actions (This Week)

1. ✅ Create this analysis document
2. [ ] Implement all API models
3. [ ] Add missing endpoints to AppUrl
4. [ ] Implement authentication interceptor
5. [ ] Add booking-related API methods

### Short Term (Next 2 Weeks)

6. [ ] Implement driver tracking APIs
7. [ ] Implement payment APIs
8. [ ] Implement profile APIs
9. [ ] Remove mock data from repositories
10. [ ] Write unit tests for API layer

### Medium Term (Next Month)

11. [ ] Implement Google Maps integration
12. [ ] Add offline caching
13. [ ] Implement push notifications
14. [ ] Add comprehensive error handling
15. [ ] Performance optimization

---

## Conclusion

The Flutter app has a solid foundation but needs significant work to match the Android app's API integration. The primary areas of focus should be:

1. **Standardizing on Dio** for all API calls
2. **Creating comprehensive data models** for all API responses
3. **Implementing authentication interceptor** for token management
4. **Adding all 36 API endpoints** from the reference document
5. **Removing mock data** and connecting to real APIs

The estimated effort is **3-4 weeks** for a complete integration, assuming one developer working full-time.

---

**Document Version**: 1.0
**Last Updated**: 2025-01-20
**Author**: AI Assistant (Based on API Reference Document)



