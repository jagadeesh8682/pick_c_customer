import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repo/map_repository.dart';
import '../../home/repo/home_repository.dart';
import '../../../core/data/services/api_service.dart';
import '../../../core/data/models/driver/driver_models.dart';
import '../../../core/data/models/booking/booking_models.dart';
import '../../../core/data/models/vehicle/vehicle_models.dart';
import '../../../screens/booking_history/repo/booking_history_repository.dart';

/// Map Provider for managing map state and truck booking logic
class MapProvider extends ChangeNotifier {
  final MapRepository _mapRepository;
  final HomeRepository _homeRepository = HomeRepository();
  final ApiService _apiService = ApiService();
  final BookingHistoryRepository _bookingHistoryRepository =
      BookingHistoryRepository();

  MapProvider({required MapRepository mapRepository})
    : _mapRepository = mapRepository;

  // Active trip tracking
  Timer? _driverLocationTimer;
  bool _hasActiveTrip = false;
  bool get hasActiveTrip => _hasActiveTrip;

  String? _activeBookingNumber;
  String? get activeBookingNumber => _activeBookingNumber;

  DriverDetails? _activeDriver;
  DriverDetails? get activeDriver => _activeDriver;

  LatLng? _driverLocation;
  LatLng? get driverLocation => _driverLocation;

  LatLng? _activePickupLocation;
  LatLng? get activePickupLocation => _activePickupLocation;

  LatLng? _activeDropLocation;
  LatLng? get activeDropLocation => _activeDropLocation;

  String _activePickupAddress = '';
  String get activePickupAddress => _activePickupAddress;

  String _activeDropAddress = '';
  String get activeDropAddress => _activeDropAddress;

  // Current location
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  // Vehicle types and groups from API
  List<VehicleLookup> _vehicleTypes = [];
  List<VehicleLookup> get vehicleTypes => _vehicleTypes;

  List<VehicleLookup> _vehicleGroups = [];
  List<VehicleLookup> get vehicleGroups => _vehicleGroups;

  // Selected vehicle type and group
  VehicleLookup? _selectedVehicleType;
  VehicleLookup? get selectedVehicleType => _selectedVehicleType;

  VehicleLookup? _selectedVehicleGroup;
  VehicleLookup? get selectedVehicleGroup => _selectedVehicleGroup;

  // Selected truck type (for backward compatibility)
  String _selectedTruckType = 'Mini';
  String get selectedTruckType =>
      _selectedVehicleGroup?.lookupCode ?? _selectedTruckType;

  // Location locked state
  bool _isLocationLocked = false;
  bool get isLocationLocked => _isLocationLocked;

  // Pickup and drop locations (coordinates)
  LatLng? _pickupLocation;
  LatLng? get pickupLocation => _pickupLocation;

  LatLng? _dropLocation;
  LatLng? get dropLocation => _dropLocation;

  // Pickup and drop location addresses (text)
  String _pickupAddress = '';
  String get pickupAddress => _pickupAddress;

  String _dropAddress = '';
  String get dropAddress => _dropAddress;

  // Currently selected location type for editing
  String? _selectedLocationType; // 'pickup' or 'drop'
  String? get selectedLocationType => _selectedLocationType;

  // Truck availability
  final Map<String, String> _truckAvailability = {};
  Map<String, String> get truckAvailability => _truckAvailability;

  // Loading states
  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  bool _isBooking = false;
  bool get isBooking => _isBooking;

  // Nearby drivers/trucks
  Timer? _nearbyDriversTimer;
  List<Truck> _nearbyDrivers = [];
  List<Truck> get nearbyDrivers => _nearbyDrivers;
  bool _isLoadingNearbyDrivers = false;
  bool get isLoadingNearbyDrivers => _isLoadingNearbyDrivers;

  /// Initialize the provider and fetch initial data
  Future<void> initialize() async {
    await _fetchCurrentLocation();

    // Fetch vehicle types and groups from API
    await _fetchVehicleTypesAndGroups();

    await _fetchTruckAvailability();

    // Check for active trip
    await checkActiveTrip();

    // Search for nearby drivers when map loads (only if user is logged in)
    if (_currentLocation != null && await _isUserLoggedIn()) {
      await searchNearbyDrivers();
      // Start periodic refresh of nearby drivers
      _startNearbyDriversRefresh();
    } else if (_currentLocation != null) {
      print('⚠️ User not logged in - skipping nearby drivers search');
    }

    // Set pickup location to current location on first load (only if no active trip)
    if (_currentLocation != null &&
        _pickupLocation == null &&
        !_hasActiveTrip) {
      _pickupLocation = _currentLocation;
      // Also update the pickup address to reflect current location
      await _reverseGeocode(_currentLocation!, 'pickup');
      print('Set current location as default pickup: ${_currentLocation}');
    }
  }

  @override
  void dispose() {
    _driverLocationTimer?.cancel();
    _nearbyDriversTimer?.cancel();
    super.dispose();
  }

  /// Update current location
  Future<void> updateLocation(LatLng newLocation) async {
    final oldLocation = _currentLocation;
    _currentLocation = newLocation;

    // If location changed significantly (more than 1km), refresh nearby drivers
    if (oldLocation != null) {
      final distance = _calculateDistance(
        oldLocation.latitude,
        oldLocation.longitude,
        newLocation.latitude,
        newLocation.longitude,
      );

      // If moved more than 1km, refresh nearby drivers
      if (distance > 1.0) {
        print(
          '📍 Location changed significantly (${distance.toStringAsFixed(2)} km), refreshing nearby drivers...',
        );
        searchNearbyDrivers();
      }
    }

    notifyListeners();
  }

  /// Calculate distance between two coordinates in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Select truck type (for backward compatibility)
  void selectTruckType(String truckType) {
    _selectedTruckType = truckType;
    // Find matching vehicle group
    final group = _vehicleGroups.firstWhere(
      (g) => g.lookupCode.toLowerCase() == truckType.toLowerCase(),
      orElse: () => _vehicleGroups.isNotEmpty
          ? _vehicleGroups.first
          : VehicleLookup(
              lookupId: 1000,
              lookupCode: truckType,
              lookupDescription: truckType,
              lookupCategory: 'VehicleGroup',
            ),
    );
    _selectedVehicleGroup = group;
    notifyListeners();
  }

  /// Select vehicle type (Open/Closed)
  void selectVehicleType(VehicleLookup vehicleType) {
    _selectedVehicleType = vehicleType;
    notifyListeners();
    // Refresh nearby drivers when vehicle type changes
    if (_currentLocation != null) {
      _isUserLoggedIn().then((isLoggedIn) {
        if (isLoggedIn) {
          searchNearbyDrivers();
        }
      });
    }
  }

  /// Select vehicle group (Mini/Small/Medium/Large)
  void selectVehicleGroup(VehicleLookup vehicleGroup) {
    _selectedVehicleGroup = vehicleGroup;
    _selectedTruckType = vehicleGroup.lookupCode;
    notifyListeners();
    // Refresh nearby drivers when vehicle group changes
    if (_currentLocation != null) {
      _isUserLoggedIn().then((isLoggedIn) {
        if (isLoggedIn) {
          searchNearbyDrivers();
        }
      });
    }
  }

  /// Fetch vehicle types and groups from API
  Future<void> _fetchVehicleTypesAndGroups() async {
    try {
      print('🔄 Fetching vehicle types and groups from API...');

      // Fetch vehicle types (Open/Closed)
      try {
        final types = await _apiService.getVehicleTypeList();
        _vehicleTypes = types;
        print('✅ Loaded ${_vehicleTypes.length} vehicle types');
      } catch (e) {
        print('❌ Error fetching vehicle types: $e');
        // Use fallback defaults if API fails
        _vehicleTypes = [
          VehicleLookup(
            lookupId: 1300,
            lookupCode: 'Open',
            lookupDescription: 'Open',
            lookupCategory: 'VehicleType',
          ),
          VehicleLookup(
            lookupId: 1301,
            lookupCode: 'Closed',
            lookupDescription: 'Closed',
            lookupCategory: 'VehicleType',
          ),
        ];
        print('⚠️ Using fallback vehicle types');
      }

      // Fetch vehicle groups (Mini/Small/Medium/Large)
      try {
        final groups = await _apiService.getVehicleGroupList();
        _vehicleGroups = groups;
        print('✅ Loaded ${_vehicleGroups.length} vehicle groups');
      } catch (e) {
        print('❌ Error fetching vehicle groups: $e');
        // Use fallback defaults if API fails
        _vehicleGroups = [
          VehicleLookup(
            lookupId: 1000,
            lookupCode: 'Mini',
            lookupDescription: 'Mini',
            lookupCategory: 'VehicleGroup',
          ),
          VehicleLookup(
            lookupId: 1001,
            lookupCode: 'Small',
            lookupDescription: 'Small',
            lookupCategory: 'VehicleGroup',
          ),
          VehicleLookup(
            lookupId: 1002,
            lookupCode: 'Medium',
            lookupDescription: 'Medium',
            lookupCategory: 'VehicleGroup',
          ),
          VehicleLookup(
            lookupId: 1003,
            lookupCode: 'Large',
            lookupDescription: 'Large',
            lookupCategory: 'VehicleGroup',
          ),
        ];
        print('⚠️ Using fallback vehicle groups');
      }

      // Set default selections
      if (_vehicleTypes.isNotEmpty && _selectedVehicleType == null) {
        _selectedVehicleType =
            _vehicleTypes.first; // Default to first (usually "Open")
        print('📌 Default vehicle type: ${_selectedVehicleType!.lookupCode}');
      }

      if (_vehicleGroups.isNotEmpty && _selectedVehicleGroup == null) {
        // Try to find "Mini" or use first available
        _selectedVehicleGroup = _vehicleGroups.firstWhere(
          (g) => g.lookupCode.toLowerCase() == 'mini',
          orElse: () => _vehicleGroups.first,
        );
        _selectedTruckType = _selectedVehicleGroup!.lookupCode;
        print('📌 Default vehicle group: ${_selectedVehicleGroup!.lookupCode}');
      }

      print(
        '✅ Vehicle data loaded: ${_vehicleTypes.length} types, ${_vehicleGroups.length} groups',
      );
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Unexpected error fetching vehicle types/groups: $e');
      print('Stack trace: $stackTrace');
      // Use fallback defaults on unexpected error
      _vehicleTypes = [
        VehicleLookup(
          lookupId: 1300,
          lookupCode: 'Open',
          lookupDescription: 'Open',
          lookupCategory: 'VehicleType',
        ),
        VehicleLookup(
          lookupId: 1301,
          lookupCode: 'Closed',
          lookupDescription: 'Closed',
          lookupCategory: 'VehicleType',
        ),
      ];
      _vehicleGroups = [
        VehicleLookup(
          lookupId: 1000,
          lookupCode: 'Mini',
          lookupDescription: 'Mini',
          lookupCategory: 'VehicleGroup',
        ),
        VehicleLookup(
          lookupId: 1001,
          lookupCode: 'Small',
          lookupDescription: 'Small',
          lookupCategory: 'VehicleGroup',
        ),
        VehicleLookup(
          lookupId: 1002,
          lookupCode: 'Medium',
          lookupDescription: 'Medium',
          lookupCategory: 'VehicleGroup',
        ),
        VehicleLookup(
          lookupId: 1003,
          lookupCode: 'Large',
          lookupDescription: 'Large',
          lookupCategory: 'VehicleGroup',
        ),
      ];
      // Set defaults
      _selectedVehicleType = _vehicleTypes.first;
      _selectedVehicleGroup = _vehicleGroups.first;
      _selectedTruckType = _selectedVehicleGroup!.lookupCode;
      notifyListeners();
    }
  }

  /// Lock/unlock location
  void lockLocation() {
    _isLocationLocked = !_isLocationLocked;
    notifyListeners();
  }

  /// Update pickup location coordinates
  void updatePickupLocation(LatLng location) {
    _pickupLocation = location;
    // Trigger reverse geocoding to get the address
    _reverseGeocode(location, 'pickup');
    notifyListeners();
  }

  /// Update drop location coordinates
  void updateDropLocation(LatLng location) {
    _dropLocation = location;
    // Trigger reverse geocoding to get the address
    _reverseGeocode(location, 'drop');
    notifyListeners();
    print('Drop location updated: $location');
  }

  /// Update pickup address text and geocode to coordinates
  Future<void> updatePickupAddress(String address) async {
    _pickupAddress = address;
    notifyListeners();

    // Geocode address to coordinates
    if (address.isNotEmpty) {
      await _geocodeAddress(address, 'pickup');
    }
  }

  /// Update drop address text and geocode to coordinates
  Future<void> updateDropAddress(String address) async {
    _dropAddress = address;
    notifyListeners();

    // Geocode address to coordinates
    if (address.isNotEmpty) {
      await _geocodeAddress(address, 'drop');
    }
  }

  /// Geocode address to coordinates
  Future<void> _geocodeAddress(String address, String locationType) async {
    try {
      // Simulate geocoding API call
      // In a real app, you would use Google Geocoding API or similar
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock coordinates based on address keywords
      LatLng? coordinates = _getMockCoordinates(address);

      if (coordinates != null) {
        if (locationType == 'pickup') {
          _pickupLocation = coordinates;
        } else if (locationType == 'drop') {
          _dropLocation = coordinates;
        }
        notifyListeners();
        _logLocations();
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

  /// Get mock coordinates based on address keywords
  LatLng? _getMockCoordinates(String address) {
    final lowerAddress = address.toLowerCase();

    // Mock coordinates for common locations
    if (lowerAddress.contains('hyderabad') || lowerAddress.contains('hitech')) {
      return const LatLng(17.3850, 78.4867);
    } else if (lowerAddress.contains('bangalore') ||
        lowerAddress.contains('bengaluru')) {
      return const LatLng(12.9716, 77.5946);
    } else if (lowerAddress.contains('mumbai')) {
      return const LatLng(19.0760, 72.8777);
    } else if (lowerAddress.contains('delhi')) {
      return const LatLng(28.7041, 77.1025);
    } else if (lowerAddress.contains('chennai')) {
      return const LatLng(13.0827, 80.2707);
    } else if (lowerAddress.contains('kolkata')) {
      return const LatLng(22.5726, 88.3639);
    } else if (lowerAddress.contains('pune')) {
      return const LatLng(18.5204, 73.8567);
    } else if (lowerAddress.contains('ahmedabad')) {
      return const LatLng(23.0225, 72.5714);
    } else if (lowerAddress.contains('jaipur')) {
      return const LatLng(26.9124, 75.7873);
    } else if (lowerAddress.contains('lucknow')) {
      return const LatLng(26.8467, 80.9462);
    }

    // Default to a random location near current location if available
    if (_currentLocation != null) {
      return LatLng(
        _currentLocation!.latitude + (0.01 * (address.length % 10 - 5)),
        _currentLocation!.longitude + (0.01 * (address.length % 10 - 5)),
      );
    }

    return null;
  }

  /// Reverse geocode coordinates to address using Google Maps API
  Future<void> _reverseGeocode(LatLng coordinates, String locationType) async {
    try {
      // Use real Google Maps reverse geocoding API
      final address = await _homeRepository.getAddressFromCoordinates(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      );

      print('Reverse geocoding: $locationType -> $address');

      if (locationType == 'pickup') {
        _pickupAddress = address;
      } else if (locationType == 'drop') {
        _dropAddress = address;
      } else if (locationType == 'active_pickup') {
        _activePickupAddress = address;
      } else if (locationType == 'active_drop') {
        _activeDropAddress = address;
      }
      notifyListeners();
    } catch (e) {
      print('Reverse geocoding error: $e');
      // Fallback to mock address if API fails
      String address = _getMockAddress(coordinates);
      if (locationType == 'pickup') {
        _pickupAddress = address;
      } else if (locationType == 'drop') {
        _dropAddress = address;
      } else if (locationType == 'active_pickup') {
        _activePickupAddress = address;
      } else if (locationType == 'active_drop') {
        _activeDropAddress = address;
      }
      notifyListeners();
    }
  }

  /// Get mock address based on coordinates
  String _getMockAddress(LatLng coordinates) {
    // Generate unique addresses based on precise coordinates to avoid duplicates
    final lat = coordinates.latitude;
    final lng = coordinates.longitude;

    // Create unique identifiers from coordinates
    final latInt = (lat * 10000).round();
    final lngInt = (lng * 10000).round();
    final flatNumber = ((latInt + lngInt) % 200) + 1;
    final streetNumber = ((latInt * 2 + lngInt) % 500) + 1;
    final areaCode = ((latInt + lngInt * 3) % 50) + 1;

    // Mock addresses based on coordinate ranges with more specific locations
    if (lat > 17.3 && lat < 17.5 && lng > 78.4 && lng < 78.6) {
      return 'Flat ${flatNumber}A, Tower ${String.fromCharCode(65 + (areaCode % 5))}, Cyber Gateway, Hitech City, Hyderabad, Telangana 500081, India';
    } else if (lat > 12.9 && lat < 13.1 && lng > 77.5 && lng < 77.7) {
      return 'Flat ${flatNumber}B, ${streetNumber} Brigade Road, MG Road, Bangalore, Karnataka 560001, India';
    } else if (lat > 19.0 && lat < 19.2 && lng > 72.8 && lng < 73.0) {
      return 'Flat ${flatNumber}C, ${streetNumber} Marine Drive, Mumbai, Maharashtra 400020, India';
    } else if (lat > 28.6 && lat < 28.8 && lng > 77.0 && lng < 77.2) {
      return 'Flat ${flatNumber}D, ${streetNumber} Connaught Place, New Delhi, Delhi 110001, India';
    } else if (lat > 13.0 && lat < 13.2 && lng > 80.2 && lng < 80.4) {
      return 'Flat ${flatNumber}E, ${streetNumber} Anna Salai, Chennai, Tamil Nadu 600002, India';
    } else if (lat > 22.5 && lat < 22.7 && lng > 88.3 && lng < 88.5) {
      return 'Flat ${flatNumber}F, ${streetNumber} Park Street, Kolkata, West Bengal 700016, India';
    } else if (lat > 18.4 && lat < 18.6 && lng > 73.8 && lng < 74.0) {
      return 'Flat ${flatNumber}G, ${streetNumber} Koregaon Park, Pune, Maharashtra 411001, India';
    } else if (lat > 22.9 && lat < 23.1 && lng > 72.5 && lng < 72.7) {
      return 'Flat ${flatNumber}H, ${streetNumber} CG Road, Ahmedabad, Gujarat 380006, India';
    } else if (lat > 26.8 && lat < 27.0 && lng > 75.7 && lng < 75.9) {
      return 'Flat ${flatNumber}I, ${streetNumber} C-Scheme, Jaipur, Rajasthan 302001, India';
    } else if (lat > 26.8 && lat < 27.0 && lng > 80.9 && lng < 81.1) {
      return 'Flat ${flatNumber}J, ${streetNumber} Hazratganj, Lucknow, Uttar Pradesh 226001, India';
    } else if (lat > 37.4 && lat < 37.5 && lng > -122.1 && lng < -122.0) {
      // San Francisco Bay Area coordinates (for testing)
      return '${streetNumber} Main Street, Apt ${flatNumber}B, Mountain View, CA 94041, USA';
    } else {
      // Generate a more descriptive address for unknown locations with unique details
      final latDir = lat >= 0 ? 'N' : 'S';
      final lngDir = lng >= 0 ? 'E' : 'W';
      final areaName = 'Area${areaCode}';
      final cityName = 'City${streetNumber % 20}';
      return 'Flat ${flatNumber}A, ${streetNumber} Custom Street, ${areaName}, ${cityName}, ${latDir}${lat.abs().toStringAsFixed(2)}, ${lngDir}${lng.abs().toStringAsFixed(2)}';
    }
  }

  /// Set selected location type for editing
  void setSelectedLocationType(String? locationType) {
    _selectedLocationType = locationType;
    notifyListeners();
  }

  /// Handle marker drag for pickup or drop location
  void onMarkerDrag(String locationType, LatLng newPosition) {
    if (locationType == 'pickup') {
      updatePickupLocation(newPosition);
      _reverseGeocode(newPosition, 'pickup');
    } else if (locationType == 'drop') {
      updateDropLocation(newPosition);
      _reverseGeocode(newPosition, 'drop');
    }
    _logLocations();
  }

  /// Search for a location and update the selected location type
  Future<void> searchLocation(String query, String locationType) async {
    if (query.isEmpty) return;

    try {
      // Simulate location search API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock search results based on query
      LatLng? coordinates = _getMockCoordinates(query);
      String address = _getMockSearchAddress(query);

      if (coordinates != null) {
        if (locationType == 'pickup') {
          _pickupLocation = coordinates;
          _pickupAddress = address;
        } else if (locationType == 'drop') {
          _dropLocation = coordinates;
          _dropAddress = address;
        }
        notifyListeners();
        print('Location search result: $query -> $address at $coordinates');
      }
    } catch (e) {
      print('Location search error: $e');
    }
  }

  /// Get mock search address based on query
  String _getMockSearchAddress(String query) {
    final lowerQuery = query.toLowerCase();

    // Generate unique identifiers from query to avoid duplicates
    final queryHash = query.hashCode.abs();
    final flatNumber = (queryHash % 200) + 1;
    final streetNumber = ((queryHash * 2) % 500) + 1;
    final areaCode = ((queryHash * 3) % 50) + 1;

    // Mock addresses for common search terms with detailed addresses
    if (lowerQuery.contains('hyderabad') || lowerQuery.contains('hitech')) {
      return 'Flat ${flatNumber}A, Tower ${String.fromCharCode(65 + (areaCode % 5))}, Cyber Gateway, Hitech City, Hyderabad, Telangana 500081, India';
    } else if (lowerQuery.contains('bangalore') ||
        lowerQuery.contains('bengaluru')) {
      return 'Flat ${flatNumber}B, ${streetNumber} Brigade Road, MG Road, Bangalore, Karnataka 560001, India';
    } else if (lowerQuery.contains('mumbai')) {
      return 'Flat ${flatNumber}C, ${streetNumber} Marine Drive, Mumbai, Maharashtra 400020, India';
    } else if (lowerQuery.contains('delhi')) {
      return 'Flat ${flatNumber}D, ${streetNumber} Connaught Place, New Delhi, Delhi 110001, India';
    } else if (lowerQuery.contains('chennai')) {
      return 'Flat ${flatNumber}E, ${streetNumber} Anna Salai, Chennai, Tamil Nadu 600002, India';
    } else if (lowerQuery.contains('kolkata')) {
      return 'Flat ${flatNumber}F, ${streetNumber} Park Street, Kolkata, West Bengal 700016, India';
    } else if (lowerQuery.contains('pune')) {
      return 'Flat ${flatNumber}G, ${streetNumber} Koregaon Park, Pune, Maharashtra 411001, India';
    } else if (lowerQuery.contains('ahmedabad')) {
      return 'Flat ${flatNumber}H, ${streetNumber} CG Road, Ahmedabad, Gujarat 380006, India';
    } else if (lowerQuery.contains('jaipur')) {
      return 'Flat ${flatNumber}I, ${streetNumber} C-Scheme, Jaipur, Rajasthan 302001, India';
    } else if (lowerQuery.contains('lucknow')) {
      return 'Flat ${flatNumber}J, ${streetNumber} Hazratganj, Lucknow, Uttar Pradesh 226001, India';
    } else if (lowerQuery.contains('san francisco') ||
        lowerQuery.contains('sf')) {
      return '${streetNumber} Main Street, Apt ${flatNumber}B, Mountain View, CA 94041, USA';
    } else if (lowerQuery.contains('kondapur') ||
        lowerQuery.contains('konda')) {
      return 'Flat ${flatNumber}K, Kondapur Heights, Hitech City Road, Kondapur, Hyderabad, Telangana 500081, India';
    } else if (lowerQuery.contains('tcs') || lowerQuery.contains('kohinoor')) {
      return 'Flat ${flatNumber}L, Tower ${String.fromCharCode(65 + (areaCode % 3))}, TCS Kohinoor Park, Kondapur, Hyderabad, Telangana 500081, India';
    } else if (lowerQuery.contains('flat') ||
        lowerQuery.contains('apartment')) {
      return 'Flat ${flatNumber}M, ${query} Street, Area ${areaCode}, City ${streetNumber % 20}';
    } else {
      // Return the query as address if no specific match, but make it more detailed
      return 'Flat ${flatNumber}N, ${query} Road, Area ${areaCode}, City ${streetNumber % 25}, State ${streetNumber % 30}';
    }
  }

  /// Clear pickup location
  void clearPickupLocation() {
    _pickupLocation = null;
    _pickupAddress = '';
    notifyListeners();
  }

  /// Clear drop location
  void clearDropLocation() {
    _dropLocation = null;
    _dropAddress = '';
    notifyListeners();
  }

  /// Log pickup and drop locations
  void _logLocations() {
    print('=== LOCATION LOG ===');
    print(
      'Current Location: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}',
    );
    print(
      'Pickup Location: ${_pickupLocation?.latitude}, ${_pickupLocation?.longitude}',
    );
    print('Pickup Address: $_pickupAddress');
    print(
      'Drop Location: ${_dropLocation?.latitude}, ${_dropLocation?.longitude}',
    );
    print('Drop Address: $_dropAddress');
    print('==================');
  }

  /// Public method to log locations (can be called from UI)
  void logLocations() {
    _logLocations();
  }

  /// Book truck now
  Future<Map<String, dynamic>?> bookNow() async {
    if (_currentLocation == null) return null;

    _isBooking = true;
    notifyListeners();

    try {
      final result = await _mapRepository.bookTruck(
        truckType: _selectedTruckType,
        pickupLocation: {
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
        },
        dropLocation: {
          'latitude': _currentLocation!.latitude + 0.01, // Mock drop location
          'longitude': _currentLocation!.longitude + 0.01,
        },
        isNow: true,
      );

      _isBooking = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isBooking = false;
      notifyListeners();
      return null;
    }
  }

  /// Book truck for later
  Future<Map<String, dynamic>?> bookLater() async {
    if (_currentLocation == null) return null;

    _isBooking = true;
    notifyListeners();

    try {
      final result = await _mapRepository.bookTruck(
        truckType: _selectedTruckType,
        pickupLocation: {
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
        },
        dropLocation: {
          'latitude': _currentLocation!.latitude + 0.01, // Mock drop location
          'longitude': _currentLocation!.longitude + 0.01,
        },
        isNow: false,
      );

      _isBooking = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isBooking = false;
      notifyListeners();
      return null;
    }
  }

  /// Fetch current location
  Future<void> _fetchCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final location = await _mapRepository.getCurrentLocation();
      _currentLocation = LatLng(location['latitude']!, location['longitude']!);
    } catch (e) {
      // Fallback to default location (Hyderabad)
      _currentLocation = const LatLng(17.3850, 78.4867);
    }

    _isLoadingLocation = false;
    notifyListeners();
  }

  /// Fetch truck availability for all types
  Future<void> _fetchTruckAvailability() async {
    final truckTypes = ['Mini', 'Small', 'Medium', 'Large'];

    // Check if we have pickup and drop locations to search for trucks
    if (_currentLocation != null &&
        _pickupLocation != null &&
        _dropLocation != null) {
      // Try to search for trucks using real API
      try {
        // Map truck type to vehicle group ID (approximate mapping)
        final vehicleGroupMap = {
          'Mini': 1000,
          'Small': 1001,
          'Medium': 1002,
          'Large': 1003,
        };

        for (final type in truckTypes) {
          try {
            final trucks = await _homeRepository.searchNearbyTrucks(
              currentLat: _currentLocation!.latitude,
              currentLng: _currentLocation!.longitude,
              pickupLat: _pickupLocation!.latitude,
              pickupLng: _pickupLocation!.longitude,
              dropLat: _dropLocation!.latitude,
              dropLng: _dropLocation!.longitude,
              vehicleTypeId:
                  _selectedVehicleType?.lookupId ??
                  1300, // Default to Open (1300)
              vehicleGroupId: vehicleGroupMap[type] ?? 1000,
            );

            _truckAvailability[type] = trucks.isNotEmpty
                ? '${trucks.length} trucks available'
                : 'No trucks';
          } catch (e) {
            print('Error fetching trucks for $type: $e');
            _truckAvailability[type] = 'Check availability';
          }
        }
      } catch (e) {
        print('Error in truck availability: $e');
        // Fallback to mock data
        for (final type in truckTypes) {
          try {
            final availability = await _mapRepository.fetchTruckAvailability(
              type,
            );
            _truckAvailability[type] = availability;
          } catch (e) {
            _truckAvailability[type] = 'Check availability';
          }
        }
      }
    } else {
      // No locations set, use mock availability
      for (final type in truckTypes) {
        try {
          final availability = await _mapRepository.fetchTruckAvailability(
            type,
          );
          _truckAvailability[type] = availability;
        } catch (e) {
          _truckAvailability[type] = 'Check availability';
        }
      }
    }

    notifyListeners();
  }

  /// Check if user has an active trip
  Future<void> checkActiveTrip() async {
    try {
      final isInTrip = await _homeRepository.isInTrip();
      _hasActiveTrip = isInTrip;

      if (isInTrip) {
        print('✅ Active trip detected, fetching booking details...');
        await _loadActiveTripDetails();
      } else {
        print('ℹ️ No active trip');
        _clearActiveTrip();
      }

      notifyListeners();
    } catch (e) {
      print('Error checking active trip: $e');
      _hasActiveTrip = false;
      notifyListeners();
    }
  }

  /// Load active trip details (booking, driver, locations)
  Future<void> _loadActiveTripDetails() async {
    try {
      // Get booking history to find active booking
      final bookings = await _bookingHistoryRepository.getBookingHistory();

      // Find the most recent active booking
      final activeBookings = bookings.where((booking) {
        final status = (booking['status'] ?? '').toString().toLowerCase();
        return status == 'in_progress' ||
            status == 'assigned' ||
            status == 'on_way' ||
            status == 'confirmed';
      }).toList();

      if (activeBookings.isNotEmpty) {
        // Get the most recent active booking
        activeBookings.sort((a, b) {
          final aTime =
              DateTime.tryParse(a['bookingTime'] ?? '') ?? DateTime(0);
          final bTime =
              DateTime.tryParse(b['bookingTime'] ?? '') ?? DateTime(0);
          return bTime.compareTo(aTime);
        });

        final activeBooking = activeBookings.first;
        _activeBookingNumber =
            activeBooking['bookingId']?.toString() ??
            activeBooking['bookingNumber']?.toString();

        if (_activeBookingNumber != null && _activeBookingNumber!.isNotEmpty) {
          print('📋 Active booking found: $_activeBookingNumber');

          // Get detailed booking info
          final bookingInfo = await _homeRepository.getBookingInfo(
            _activeBookingNumber!,
          );

          // Extract pickup and drop locations from booking
          if (bookingInfo['pickupLat'] != null &&
              bookingInfo['pickupLng'] != null) {
            _activePickupLocation = LatLng(
              (bookingInfo['pickupLat'] as num).toDouble(),
              (bookingInfo['pickupLng'] as num).toDouble(),
            );
            _activePickupAddress =
                bookingInfo['pickupLocation']?.toString() ?? '';
            if (_activePickupAddress.isEmpty && _activePickupLocation != null) {
              await _reverseGeocode(_activePickupLocation!, 'active_pickup');
            }
          }

          if (bookingInfo['dropLat'] != null &&
              bookingInfo['dropLng'] != null) {
            _activeDropLocation = LatLng(
              (bookingInfo['dropLat'] as num).toDouble(),
              (bookingInfo['dropLng'] as num).toDouble(),
            );
            _activeDropAddress = bookingInfo['dropLocation']?.toString() ?? '';
            if (_activeDropAddress.isEmpty && _activeDropLocation != null) {
              await _reverseGeocode(_activeDropLocation!, 'active_drop');
            }
          }

          // Get driver details
          try {
            final driverDetails = await _apiService.getDriverDetails(
              _activeBookingNumber!,
            );
            _activeDriver = driverDetails;

            // Start tracking driver location
            if (_activeDriver != null && _activeDriver!.id.isNotEmpty) {
              await _updateDriverLocation();
              _startDriverLocationTracking();
            }
          } catch (e) {
            print('Error fetching driver details: $e');
          }
        }
      } else {
        print('⚠️ No active booking found in history');
        _hasActiveTrip = false;
      }
    } catch (e) {
      print('Error loading active trip details: $e');
      _hasActiveTrip = false;
    }
  }

  /// Update driver location
  Future<void> _updateDriverLocation() async {
    if (_activeDriver == null || _activeDriver!.id.isEmpty) return;

    try {
      final location = await _apiService.getDriverLocation(_activeDriver!.id);
      _driverLocation = LatLng(location.latitude, location.longitude);
      print('🚚 Driver location updated: $_driverLocation');
      notifyListeners();
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  /// Start periodic driver location tracking
  void _startDriverLocationTracking() {
    _driverLocationTimer?.cancel();
    _driverLocationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_hasActiveTrip && _activeDriver != null) {
        _updateDriverLocation();
      } else {
        timer.cancel();
      }
    });
  }

  /// Clear active trip data
  void _clearActiveTrip() {
    _driverLocationTimer?.cancel();
    _activeBookingNumber = null;
    _activeDriver = null;
    _driverLocation = null;
    _activePickupLocation = null;
    _activeDropLocation = null;
    _activePickupAddress = '';
    _activeDropAddress = '';
  }

  /// Refresh active trip status
  Future<void> refreshActiveTrip() async {
    await checkActiveTrip();
  }

  int _apiCallCount = 0; // Counter for logging

  /// Check if user is logged in by checking for token in SharedPreferences
  Future<bool> _isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Search for nearby drivers/trucks using POST /master/customer/user
  /// This API is called every 2-3 seconds to get real-time driver locations
  /// Only works if user is logged in
  Future<void> searchNearbyDrivers() async {
    if (_currentLocation == null) {
      return; // Silently return if location not available
    }

    // Check if user is logged in before making API call
    if (!await _isUserLoggedIn()) {
      print('⚠️ Cannot search nearby drivers: User not logged in');
      _nearbyDrivers = [];
      notifyListeners();
      return;
    }

    // Don't search if already loading to prevent multiple simultaneous requests
    if (_isLoadingNearbyDrivers) {
      return;
    }

    _isLoadingNearbyDrivers = true;
    // Don't notify listeners immediately to avoid UI flicker during frequent updates

    try {
      // Use current location as both pickup and drop for initial search
      // This will show all available drivers in the nearby area
      final currentLat = _currentLocation!.latitude;
      final currentLng = _currentLocation!.longitude;

      // Use a nearby point (about 5km away) as drop location for search
      // This helps get drivers in a wider area
      final dropLat = currentLat + 0.05; // ~5km north
      final dropLng = currentLng + 0.05; // ~5km east

      print('🔍 Searching for nearby drivers...');
      print('   📍 User location: ($currentLat, $currentLng)');
      print('   🎯 Search radius: ~5km');

      // Use selected vehicle type and group IDs
      final selectedTypeId =
          _selectedVehicleType?.lookupId ?? 1300; // Default to Open (1300)
      final selectedGroupId = _selectedVehicleGroup?.lookupId;

      print(
        '   🚛 Selected Vehicle Type ID: $selectedTypeId (${_selectedVehicleType?.lookupCode ?? "Open"})',
      );
      print(
        '   🚛 Selected Vehicle Group ID: ${selectedGroupId ?? "All"} (${_selectedVehicleGroup?.lookupCode ?? "All"})',
      );

      // Search for drivers with selected vehicle type and group
      final allDrivers = <Truck>[];
      final searchFutures = <Future<List<Truck>>>[];

      if (selectedGroupId != null) {
        // Search with selected vehicle type and group
        searchFutures.add(
          _searchDriversForType(
            currentLat: currentLat,
            currentLng: currentLng,
            pickupLat: currentLat,
            pickupLng: currentLng,
            dropLat: dropLat,
            dropLng: dropLng,
            vehicleTypeId: selectedTypeId,
            vehicleGroupId: selectedGroupId,
          ),
        );
      } else {
        // If no group selected, search all groups with selected type
        final vehicleGroupIds = _vehicleGroups.map((g) => g.lookupId).toList();
        if (vehicleGroupIds.isEmpty) {
          vehicleGroupIds.addAll([1000, 1001, 1002, 1003]); // Fallback defaults
        }

        for (final vehicleGroupId in vehicleGroupIds) {
          searchFutures.add(
            _searchDriversForType(
              currentLat: currentLat,
              currentLng: currentLng,
              pickupLat: currentLat,
              pickupLng: currentLng,
              dropLat: dropLat,
              dropLng: dropLng,
              vehicleTypeId: selectedTypeId,
              vehicleGroupId: vehicleGroupId,
            ),
          );
        }
      }

      // Wait for all searches to complete in parallel
      final results = await Future.wait(searchFutures);

      // Combine all results
      for (final trucks in results) {
        allDrivers.addAll(trucks);
      }

      // Remove duplicates based on driver ID and filter invalid locations
      final uniqueDrivers = <String, Truck>{};
      for (final driver in allDrivers) {
        if (driver.id.isNotEmpty &&
            driver.latitude != 0 &&
            driver.longitude != 0 &&
            !uniqueDrivers.containsKey(driver.id)) {
          uniqueDrivers[driver.id] = driver;
        }
      }

      final previousCount = _nearbyDrivers.length;
      _nearbyDrivers = uniqueDrivers.values.toList();
      final currentCount = _nearbyDrivers.length;

      // Log driver count on every API call
      _apiCallCount++;
      print(
        '🚚 [API Call #$_apiCallCount] Nearby drivers found: $currentCount',
      );

      if (currentCount != previousCount) {
        print('   📊 Driver count changed: $previousCount → $currentCount');
      }

      if (currentCount > 0) {
        print('   ✅ Active drivers on map: $currentCount');
        // Log first few driver details for debugging
        final driversToLog = _nearbyDrivers.take(3).toList();
        for (int i = 0; i < driversToLog.length; i++) {
          final driver = driversToLog[i];
          print(
            '   🚛 Driver ${i + 1}: ${driver.driverName} | ${driver.vehicleNumber} | ${driver.distance.toStringAsFixed(1)} km away',
          );
        }
        if (currentCount > 3) {
          print('   ... and ${currentCount - 3} more drivers');
        }
      } else {
        print('   ⚠️ No drivers found nearby');
      }

      print('   📍 Search location: ($currentLat, $currentLng)');
      print('   🔄 API: POST /master/customer/user');

      _isLoadingNearbyDrivers = false;
      notifyListeners();
    } catch (e) {
      // Silently handle errors to avoid spam during frequent updates
      _isLoadingNearbyDrivers = false;
      // Only notify listeners if we have an error and no drivers
      if (_nearbyDrivers.isEmpty) {
        notifyListeners();
      }
    }
  }

  /// Search drivers for a specific vehicle type and group
  /// Uses POST /master/customer/user API endpoint
  Future<List<Truck>> _searchDriversForType({
    required double currentLat,
    required double currentLng,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required int vehicleTypeId,
    required int vehicleGroupId,
  }) async {
    try {
      final trucks = await _homeRepository.searchNearbyTrucks(
        currentLat: currentLat,
        currentLng: currentLng,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropLat: dropLat,
        dropLng: dropLng,
        vehicleTypeId: vehicleTypeId,
        vehicleGroupId: vehicleGroupId,
      );
      return trucks;
    } catch (e) {
      // Return empty list on error (silent fail for frequent calls)
      return [];
    }
  }

  /// Start periodic refresh of nearby drivers
  void _startNearbyDriversRefresh() {
    _nearbyDriversTimer?.cancel();
    // Refresh nearby drivers every 2-3 seconds (using 2.5 seconds average)
    _nearbyDriversTimer = Timer.periodic(const Duration(milliseconds: 2500), (
      timer,
    ) async {
      // Check if user is still logged in before each API call
      if (_currentLocation != null &&
          !_isLoadingNearbyDrivers &&
          !_hasActiveTrip &&
          await _isUserLoggedIn()) {
        searchNearbyDrivers();
      } else {
        // If user logged out, clear drivers and stop timer
        if (!await _isUserLoggedIn()) {
          _nearbyDrivers = [];
          notifyListeners();
          timer.cancel();
        }
      }
    });
  }

  /// Refresh nearby drivers manually
  Future<void> refreshNearbyDrivers() async {
    await searchNearbyDrivers();
  }
}
