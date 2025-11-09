import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../provider/map_provider.dart';
import '../../../core/constants/api_keys.dart';
import '../../booking/screen/cargo_selection_screen.dart';

/// Main Map Screen for truck booking
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initialize();
      _debugApiKeys();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh active trip status when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().refreshActiveTrip();
    });
  }

  /// Debug method to verify API keys are loaded
  void _debugApiKeys() {
    print('🔑 API Keys Debug Info:');
    print(
      'Maps Key: ${ApiKeys.googleMapsApiKey.isNotEmpty ? "✅ Loaded" : "❌ Missing"}',
    );
    print(
      'Places Key: ${ApiKeys.googlePlacesApiKey.isNotEmpty ? "✅ Loaded" : "❌ Missing"}',
    );
    print(
      'Directions Key: ${ApiKeys.googleDirectionsApiKey.isNotEmpty ? "✅ Loaded" : "❌ Missing"}',
    );
    print('All Keys Loaded: ${ApiKeys.areApiKeysLoaded ? "✅ Yes" : "❌ No"}');
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  /// Update text controllers when provider addresses change
  void _updateControllers(MapProvider mapProvider) {
    // Update pickup controller
    if (_pickupController.text != mapProvider.pickupAddress) {
      _pickupController.text = mapProvider.pickupAddress;
      print('Updated pickup controller: ${mapProvider.pickupAddress}');
    }

    // Update drop controller
    if (_dropController.text != mapProvider.dropAddress) {
      _dropController.text = mapProvider.dropAddress;
      print('Updated drop controller: ${mapProvider.dropAddress}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildNavigationDrawer(),
      body: Consumer<MapProvider>(
        builder: (context, mapProvider, child) {
          _updateControllers(mapProvider);

          // Check if API keys are loaded and not placeholders
          final mapsKey = ApiKeys.googleMapsApiKey;
          final isPlaceholder =
              mapsKey.isEmpty ||
              mapsKey.contains('your_') ||
              mapsKey.contains('YOUR_') ||
              mapsKey == 'your_google_maps_api_key_here';

          if (!ApiKeys.areApiKeysLoaded || isPlaceholder) {
            return _buildApiKeyError();
          }

          // Show loading state while initializing
          if (mapProvider.isLoadingLocation ||
              mapProvider.isLoadingNearbyDrivers) {
            return _buildLoadingState();
          }

          return SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Google Map - Full screen background
                _buildGoogleMap(mapProvider),

                // App Bar
                _buildAppBar(),

                // Location Input Fields
                _buildLocationFields(mapProvider),

                // Truck Type Selector
                _buildTruckTypeSelector(mapProvider),

                // Bottom Action Buttons
                _buildBottomButtons(mapProvider),

                // Floating Action Button for current location
                _buildCurrentLocationButton(mapProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading map...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting your location',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Build API key error widget
  Widget _buildApiKeyError() {
    final mapsKey = ApiKeys.googleMapsApiKey;
    final isPlaceholder =
        mapsKey.contains('your_') ||
        mapsKey.contains('YOUR_') ||
        mapsKey.isEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              '🚨 API Authorization Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '❌ Error: "API project is not authorized to use this API"',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your API key exists but Google Cloud project is not authorized.\n\n'
                    '🔧 FIX STEPS:\n\n'
                    '1️⃣ Go to: https://console.cloud.google.com/apis/library\n'
                    '   → Search "Maps SDK for Android"\n'
                    '   → Click "ENABLE"\n\n'
                    '2️⃣ Go to: https://console.cloud.google.com/billing\n'
                    '   → Link a billing account (Free tier: \$200/month credit)\n\n'
                    '3️⃣ Wait 5-10 minutes for changes to propagate\n\n'
                    '4️⃣ Restart this app',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _debugApiKeys();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📋 Check console for API key details'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('Show API Key Info'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isPlaceholder)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Current API Key: ${mapsKey.isEmpty ? "Not set" : mapsKey.substring(0, mapsKey.length > 30 ? 30 : mapsKey.length) + "..."}\n'
                  'This appears to be a placeholder. Please update .env file.',
                  style: TextStyle(fontSize: 12, color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build Google Map widget
  Widget _buildGoogleMap(MapProvider mapProvider) {
    print(
      '🗺️ Building Google Map with location: ${mapProvider.currentLocation}',
    );
    final apiKey = ApiKeys.googleMapsApiKey;
    print(
      '🔑 Google Maps API Key: ${apiKey.isNotEmpty ? "Present (${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...)" : "Missing"}',
    );

    // Default location (Hyderabad) if current location is null
    final defaultLocation = const LatLng(17.3850, 78.4867);
    final targetLocation = mapProvider.currentLocation ?? defaultLocation;

    print('📍 Map target location: $targetLocation');

    // Check if API key is valid (not empty and not placeholder)
    if (apiKey.isEmpty ||
        apiKey.contains('your_') ||
        apiKey.contains('YOUR_') ||
        apiKey == 'your_google_maps_api_key_here') {
      print('❌ Invalid API key - map will not render');
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Invalid Google Maps API Key',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your .env file',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: Container(
        color: Colors.grey[200], // Background color while map loads
        child: Stack(
          children: [
            // The actual Google Map
            GoogleMap(
              key: ValueKey(
                'google_map_${targetLocation.latitude}_${targetLocation.longitude}',
              ),
              onMapCreated: (GoogleMapController controller) async {
                _mapController = controller;
                print('✅ Google Map created successfully!');
                print('📍 Map center: $targetLocation');
                print('🎛️ Map controller ready');
                print('🗺️ Map widget is rendering');

                // Wait a bit for map to initialize
                await Future.delayed(const Duration(milliseconds: 1000));

                // Move camera to target location
                if (_mapController != null) {
                  try {
                    final location =
                        mapProvider.currentLocation ?? defaultLocation;
                    await _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(location, 15.0),
                    );
                    print('📍 Camera animated to: $location');

                    // Force a map update
                    await Future.delayed(const Duration(milliseconds: 500));
                    _mapController!.getVisibleRegion();
                    print('🗺️ Map region updated');
                  } catch (e) {
                    print('❌ Error animating camera: $e');
                  }
                }

                // Diagnostic check after delay
                Future.delayed(const Duration(seconds: 5), () {
                  print('🔍 Diagnostic Check:');
                  print(
                    '   - Map controller: ${_mapController != null ? "✅ Present" : "❌ Missing"}',
                  );
                  print(
                    '   - Current location: ${mapProvider.currentLocation}',
                  );
                  print(
                    '   - API Key loaded: ${apiKey.isNotEmpty ? "✅ Yes" : "❌ No"}',
                  );
                  print('   - If map is blank, check:');
                  print(
                    '     1. Test on physical device (emulator may have issues)',
                  );
                  print(
                    '     2. Verify API key restrictions in Google Cloud Console',
                  );
                  print('     3. Check internet connection');
                  print('     4. Ensure Maps SDK for Android is enabled');
                });
              },
              initialCameraPosition: CameraPosition(
                target: targetLocation,
                zoom: 15.0,
              ),
              markers: _buildMarkers(mapProvider),
              onTap: (LatLng position) {
                print('🗺️ Map tapped at: $position');
                // Handle map tap to set pickup or drop location
                _handleMapTap(mapProvider, position);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true, // Enable to help with debugging
              mapToolbarEnabled: false,
              mapType: MapType.normal,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
              trafficEnabled: false,
              buildingsEnabled: true,
              liteModeEnabled: false, // Ensure full map mode, not lite mode
              // Try satellite view as fallback if normal doesn't work
              // mapStyleId: null, // Will use default style
              onCameraMove: (CameraPosition position) {
                // Only log occasionally to avoid spam
                // print('📷 Camera moved to: ${position.target}');
              },
              onCameraIdle: () {
                print('📷 Camera idle');
              },
            ),
            // Debug indicator (remove in production)
            if (apiKey.contains('your_') || apiKey.isEmpty)
              Container(
                color: Colors.red.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'Map not rendering - Check API Key',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build markers for pickup, drop, current location, active trip, and nearby drivers
  Set<Marker> _buildMarkers(MapProvider mapProvider) {
    Set<Marker> markers = {};

    // Show nearby drivers on map (like Uber/Rapido)
    if (!mapProvider.hasActiveTrip) {
      // Only show nearby drivers if there's no active trip
      for (int i = 0; i < mapProvider.nearbyDrivers.length; i++) {
        final driver = mapProvider.nearbyDrivers[i];
        if (driver.latitude != 0 && driver.longitude != 0) {
          markers.add(
            Marker(
              markerId: MarkerId('nearby_driver_${driver.id}_$i'),
              position: LatLng(driver.latitude, driver.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor
                    .hueViolet, // Purple/violet color for nearby drivers
              ),
              infoWindow: InfoWindow(
                title:
                    '🚚 ${driver.driverName.isNotEmpty ? driver.driverName : "Driver"}',
                snippet: driver.vehicleNumber.isNotEmpty
                    ? '${driver.vehicleNumber}\n${driver.vehicleType}\n${driver.distance.toStringAsFixed(1)} km away'
                    : '${driver.vehicleType}\n${driver.distance.toStringAsFixed(1)} km away',
              ),
              anchor: const Offset(0.5, 0.5),
            ),
          );
        }
      }
    }

    // If there's an active trip, show active trip markers
    if (mapProvider.hasActiveTrip) {
      // Active trip pickup location marker (green)
      if (mapProvider.activePickupLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('active_pickup_location'),
            position: mapProvider.activePickupLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: 'Pickup Location',
              snippet: mapProvider.activePickupAddress.isNotEmpty
                  ? mapProvider.activePickupAddress
                  : 'Active Trip Pickup',
            ),
          ),
        );
      }

      // Active trip drop location marker (red)
      if (mapProvider.activeDropLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('active_drop_location'),
            position: mapProvider.activeDropLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Drop Location',
              snippet: mapProvider.activeDropAddress.isNotEmpty
                  ? mapProvider.activeDropAddress
                  : 'Active Trip Drop',
            ),
          ),
        );
      }

      // Driver/Truck location marker (orange/yellow - truck icon)
      if (mapProvider.driverLocation != null) {
        final driverName = mapProvider.activeDriver?.name ?? 'Driver';
        final vehicleNumber = mapProvider.activeDriver?.vehicleNumber ?? '';
        markers.add(
          Marker(
            markerId: const MarkerId('driver_location'),
            position: mapProvider.driverLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: '🚚 $driverName',
              snippet: vehicleNumber.isNotEmpty
                  ? 'Vehicle: $vehicleNumber\nTap to view details'
                  : 'Active Trip Driver',
            ),
            anchor: const Offset(0.5, 0.5),
          ),
        );
      }

      // Current location marker (blue) - still show during active trip
      if (mapProvider.currentLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: mapProvider.currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      }
    } else {
      // No active trip - show normal booking markers
      // Current location marker (blue)
      if (mapProvider.currentLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: mapProvider.currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );
      }

      // Pickup location marker (green, draggable)
      if (mapProvider.pickupLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('pickup_location'),
            position: mapProvider.pickupLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: 'Pickup Location',
              snippet: mapProvider.pickupAddress.isNotEmpty
                  ? mapProvider.pickupAddress
                  : 'Tap to edit',
            ),
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              mapProvider.onMarkerDrag('pickup', newPosition);
              _showLocationSelectedSnackBar('Pickup location updated');
            },
          ),
        );
      }

      // Drop location marker (red, draggable)
      if (mapProvider.dropLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('drop_location'),
            position: mapProvider.dropLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Drop Location',
              snippet: mapProvider.dropAddress.isNotEmpty
                  ? mapProvider.dropAddress
                  : 'Tap to edit',
            ),
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              mapProvider.onMarkerDrag('drop', newPosition);
              _showLocationSelectedSnackBar('Drop location updated');
            },
          ),
        );
      }
    }

    return markers;
  }

  /// Handle map tap to set pickup or drop location
  void _handleMapTap(MapProvider mapProvider, LatLng position) {
    if (mapProvider.selectedLocationType == 'pickup') {
      mapProvider.updatePickupLocation(position);
      mapProvider.setSelectedLocationType(null);
      _showLocationSelectedSnackBar('Pickup location selected');
      print('Pickup location set: $position');
    } else if (mapProvider.selectedLocationType == 'drop') {
      mapProvider.updateDropLocation(position);
      mapProvider.setSelectedLocationType(null);
      _showLocationSelectedSnackBar('Drop location selected');
      print('Drop location set: $position');
    } else {
      // If no location type is selected, show instruction
      _showLocationSelectionHint();
    }
  }

  /// Show snackbar when location is selected
  void _showLocationSelectedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show hint for location selection
  void _showLocationSelectionHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Tap on pickup or drop field first, then tap on map to select location',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  /// Build App Bar
  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).padding.top + 56,
        decoration: const BoxDecoration(color: Colors.black),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Hamburger menu
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                  ),
                ),

                // Title
                const Expanded(
                  child: Text(
                    'Book Pick-C Truck',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Notification bell
                IconButton(
                  onPressed: () {
                    // TODO: Implement notification functionality
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build Location Input Fields
  Widget _buildLocationFields(MapProvider mapProvider) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Pickup Location Field with Google Places Autocomplete
          _buildPlacesAutocompleteField(
            icon: Icons.flag,
            iconColor: Colors.green,
            hintText: mapProvider.pickupAddress.isNotEmpty
                ? mapProvider.pickupAddress
                : 'Tap to select pickup location',
            controller: _pickupController,
            isSelected: mapProvider.selectedLocationType == 'pickup',
            mapProvider: mapProvider,
            onTap: () {
              mapProvider.setSelectedLocationType('pickup');
              _showLocationSelectionHint();
            },
            onChanged: (value) {
              mapProvider.updatePickupAddress(value);
              // Trigger search if user types a location
              if (value.length > 3) {
                mapProvider.searchLocation(value, 'pickup');
              }
            },
            onPlaceSelected: (dynamic prediction) {
              // Place selection handled by text input
            },
          ),

          const SizedBox(height: 12),

          // Drop Location Field with Google Places Autocomplete
          _buildPlacesAutocompleteField(
            icon: Icons.flag,
            iconColor: Colors.red,
            hintText: mapProvider.dropAddress.isNotEmpty
                ? mapProvider.dropAddress
                : 'Tap to select drop location',
            controller: _dropController,
            isSelected: mapProvider.selectedLocationType == 'drop',
            mapProvider: mapProvider,
            onTap: () {
              mapProvider.setSelectedLocationType('drop');
              _showLocationSelectionHint();
            },
            onChanged: (value) {
              mapProvider.updateDropAddress(value);
              // Trigger search if user types a location
              if (value.length > 3) {
                mapProvider.searchLocation(value, 'drop');
              }
            },
            onPlaceSelected: (dynamic prediction) {
              // Place selection handled by text input
            },
          ),
        ],
      ),
    );
  }

  /// Build Google Places Autocomplete field
  Widget _buildPlacesAutocompleteField({
    required IconData icon,
    required Color iconColor,
    required String hintText,
    required TextEditingController controller,
    required VoidCallback onTap,
    required ValueChanged<String> onChanged,
    required Function(dynamic) onPlaceSelected,
    required MapProvider mapProvider,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow[100] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.yellow, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildLocationTextField(
          controller: controller,
          hintText: hintText,
          icon: icon,
          iconColor: iconColor,
          isSelected: isSelected,
          onChanged: onChanged,
          mapProvider: mapProvider,
        ),
      ),
    );
  }

  /// Build location text field (fallback for Google Places)
  Widget _buildLocationTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required ValueChanged<String> onChanged,
    required MapProvider mapProvider,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
        border: InputBorder.none,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  // Clear the location based on icon color
                  if (iconColor == Colors.green) {
                    mapProvider.clearPickupLocation();
                  } else if (iconColor == Colors.red) {
                    mapProvider.clearDropLocation();
                  }
                },
              ),
            Icon(
              isSelected ? Icons.edit_location : Icons.my_location,
              color: isSelected ? Colors.orange : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: isSelected ? Colors.black : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      enabled: isSelected,
    );
  }

  /// Build Truck Type Selector with Vehicle Types and Groups from API
  Widget _buildTruckTypeSelector(MapProvider mapProvider) {
    return Positioned(
      bottom: 120,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Type Selector (Open/Closed)
            if (mapProvider.vehicleTypes.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'Vehicle Type:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...mapProvider.vehicleTypes.map((vehicleType) {
                    final isSelected =
                        mapProvider.selectedVehicleType?.lookupId ==
                        vehicleType.lookupId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => mapProvider.selectVehicleType(vehicleType),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.yellow : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            vehicleType.lookupCode,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Vehicle Group Selector (Mini/Small/Medium/Large)
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loading',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Unloading',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 40, color: Colors.grey[400]),
                const SizedBox(width: 16),

                // Vehicle Group Options (from API)
                Expanded(
                  child: mapProvider.vehicleGroups.isEmpty
                      ? const Center(
                          child: Text(
                            'Loading vehicle groups...',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: mapProvider.vehicleGroups.map((
                              vehicleGroup,
                            ) {
                              final isSelected =
                                  mapProvider.selectedVehicleGroup?.lookupId ==
                                  vehicleGroup.lookupId;
                              final availability =
                                  mapProvider.truckAvailability[vehicleGroup
                                      .lookupCode] ??
                                  'Check';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: _buildTruckTypeOption(
                                  truckType: vehicleGroup.lookupCode,
                                  isSelected: isSelected,
                                  availability: availability,
                                  onTap: () => mapProvider.selectVehicleGroup(
                                    vehicleGroup,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual truck type option
  Widget _buildTruckTypeOption({
    required String truckType,
    required bool isSelected,
    required String availability,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.yellow : Colors.white,
              border: Border.all(
                color: Colors.black,
                width: isSelected ? 0 : 1,
              ),
            ),
            child: Icon(
              _getTruckIcon(truckType),
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          // Show vehicle group name
          Text(
            truckType,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Show availability below the name (if not empty and not "Check")
          if (availability.isNotEmpty &&
              availability != 'Check' &&
              availability != 'Loading vehicle groups...')
            Text(
              availability,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[700],
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  /// Get truck icon based on type
  IconData _getTruckIcon(String truckType) {
    switch (truckType) {
      case 'Mini':
        return Icons.local_shipping;
      case 'Small':
        return Icons.local_shipping;
      case 'Medium':
        return Icons.local_shipping;
      case 'Large':
        return Icons.local_shipping;
      default:
        return Icons.local_shipping;
    }
  }

  /// Build Current Location Button
  Widget _buildCurrentLocationButton(MapProvider mapProvider) {
    return Positioned(
      right: 16,
      bottom: 200,
      child: FloatingActionButton(
        onPressed: () {
          if (mapProvider.currentLocation != null) {
            mapProvider.updatePickupLocation(mapProvider.currentLocation!);
            _showLocationSelectedSnackBar('Current location set as pickup');
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  /// Build Bottom Action Buttons
  Widget _buildBottomButtons(MapProvider mapProvider) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            // Book Later Button
            Expanded(
              child: GestureDetector(
                onTap: mapProvider.isBooking
                    ? null
                    : () async {
                        final result = await mapProvider.bookLater();
                        if (result != null) {
                          _showBookingConfirmation(result);
                        }
                      },
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: mapProvider.isBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : const Text(
                            'BOOK LATER',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            // Book Now Button
            Expanded(
              child: GestureDetector(
                onTap: mapProvider.isBooking
                    ? null
                    : () {
                        _showCargoSelectionDialog();
                      },
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: mapProvider.isBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.yellow,
                              ),
                            ),
                          )
                        : const Text(
                            'BOOK NOW',
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show booking confirmation dialog
  void _showBookingConfirmation(Map<String, dynamic> bookingData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed! 🚛'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingDetailRow('Booking ID', bookingData['bookingId']),
            _buildBookingDetailRow('Truck Type', bookingData['truckType']),
            _buildBookingDetailRow('Status', bookingData['status']),
            _buildBookingDetailRow(
              'Estimated Arrival',
              bookingData['estimatedArrival'],
            ),
            _buildBookingDetailRow(
              'Driver',
              bookingData['driverName'] ?? 'N/A',
            ),
            _buildBookingDetailRow(
              'Driver Phone',
              bookingData['driverPhone'] ?? 'N/A',
            ),
            _buildBookingDetailRow(
              'Truck Number',
              bookingData['truckNumber'] ?? 'N/A',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Build booking detail row
  Widget _buildBookingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Build Navigation Drawer
  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Container(
        // margin: EdgeInsets.only(top: 120),
        color: Colors.grey[100],
        child: Column(
          children: [
            // User Profile Section
            SizedBox(height: 100),
            _buildUserProfileSection(),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Booking history',
                    onTap: () => _navigateToScreen('/booking-history'),
                  ),
                  _buildMenuItem(
                    icon: Icons.attach_money,
                    title: 'Rate card',
                    onTap: () => _navigateToScreen('/rate-card'),
                  ),
                  _buildMenuItem(
                    icon: Icons.person_add,
                    title: 'Emergency contacts',
                    onTap: () => _navigateToScreen('/emergency-contacts'),
                  ),
                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'Help',
                    onTap: () => _navigateToScreen('/help'),
                  ),
                  _buildMenuItem(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () => _navigateToScreen('/about'),
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'Referral',
                    onTap: () => _navigateToScreen('/referral'),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Log out',
                    onTap: () => _handleLogout(),
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build User Profile Section
  Widget _buildUserProfileSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Icon(Icons.person, size: 30, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'john doe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '8682944609',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Menu Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.grey[700],
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isLogout ? Colors.red : Colors.grey[800],
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
    );
  }

  /// Navigate to specific screen
  void _navigateToScreen(String route) {
    Navigator.pushNamed(context, route);
  }

  /// Handle logout
  void _handleLogout() {
    Navigator.pop(context); // Close drawer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              _performLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Perform logout with safe navigation
  void _performLogout(BuildContext context) {
    try {
      // Clear any existing routes and navigate to login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // Fallback: try pushReplacementNamed
      try {
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e2) {
        // Last resort: show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCargoSelectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CargoSelectionDialog();
      },
    );
    // Dialog will handle navigation to payment screen
  }
}
