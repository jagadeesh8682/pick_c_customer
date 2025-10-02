import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/map_provider.dart';
import '../core/routes/routes_name.dart';
import '../core/utils/navigation_service.dart';
import '../core/constants/api_keys.dart';
import 'booking/cargo_selection_screen.dart';

/// Main Map Screen for truck booking
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initialize();
      _debugApiKeys();
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
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  /// Update text controllers when provider addresses change
  void _updateControllers(MapProvider mapProvider) {
    if (_pickupController.text != mapProvider.pickupAddress) {
      _pickupController.text = mapProvider.pickupAddress;
      print('Updated pickup controller: ${mapProvider.pickupAddress}');
    }
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

          // Check if API keys are loaded
          if (!ApiKeys.areApiKeysLoaded) {
            return _buildApiKeyError();
          }

          return Stack(
            children: [
              // Google Map
              _buildGoogleMap(mapProvider),

              // App Bar
              _buildAppBar(),

              // Location Input Fields
              _buildLocationFields(mapProvider),

              // Truck Type Selector
              _buildTruckTypeSelector(mapProvider),

              // Bottom Action Buttons
              _buildBottomButtons(mapProvider),
            ],
          );
        },
      ),
    );
  }

  /// Build API key error widget
  Widget _buildApiKeyError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'API Key Configuration Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please ensure your .env file contains:\n'
              'GOOGLE_MAPS_API_KEY=your_api_key_here\n'
              'GOOGLE_PLACES_API_KEY=your_api_key_here',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Restart the app to reload environment variables
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Google Map widget
  Widget _buildGoogleMap(MapProvider mapProvider) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        // Map controller can be used for future map operations
      },
      initialCameraPosition: CameraPosition(
        target: mapProvider.currentLocation ?? const LatLng(17.3850, 78.4867),
        zoom: 15.0,
      ),
      markers: _buildMarkers(mapProvider),
      onTap: (LatLng position) {
        // Handle map tap to set pickup or drop location
        _handleMapTap(mapProvider, position);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  /// Build markers for pickup, drop, and current location
  Set<Marker> _buildMarkers(MapProvider mapProvider) {
    Set<Marker> markers = {};

    // Current location marker (blue)
    if (mapProvider.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: mapProvider.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
          infoWindow: InfoWindow(title: 'Pickup: ${mapProvider.pickupAddress}'),
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            mapProvider.onMarkerDrag('pickup', newPosition);
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'Drop: ${mapProvider.dropAddress}'),
          draggable: true,
          onDragEnd: (LatLng newPosition) {
            mapProvider.onMarkerDrag('drop', newPosition);
          },
        ),
      );
    }

    return markers;
  }

  /// Handle map tap to set pickup or drop location
  void _handleMapTap(MapProvider mapProvider, LatLng position) {
    if (mapProvider.selectedLocationType == 'pickup') {
      mapProvider.updatePickupLocation(position);
      mapProvider.setSelectedLocationType(null);
    } else if (mapProvider.selectedLocationType == 'drop') {
      mapProvider.updateDropLocation(position);
      mapProvider.setSelectedLocationType(null);
    }
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
            hintText: 'Enter pickup address',
            controller: _pickupController,
            isSelected: mapProvider.selectedLocationType == 'pickup',
            onTap: () {
              mapProvider.setSelectedLocationType('pickup');
            },
            onChanged: (value) {
              mapProvider.updatePickupAddress(value);
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
            hintText: 'Enter drop address',
            controller: _dropController,
            isSelected: mapProvider.selectedLocationType == 'drop',
            onTap: () {
              mapProvider.setSelectedLocationType('drop');
            },
            onChanged: (value) {
              mapProvider.updateDropAddress(value);
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
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
        border: InputBorder.none,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        suffixIcon: Icon(
          isSelected ? Icons.edit_location : Icons.lock,
          color: isSelected ? Colors.orange : Colors.black,
          size: 20,
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

  /// Build Truck Type Selector
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
          children: [
            // Loading/Unloading Icon
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

                // Truck Type Options
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Mini', 'Small', 'Medium', 'Large'].map((
                      truckType,
                    ) {
                      final isSelected =
                          mapProvider.selectedTruckType == truckType;
                      final availability =
                          mapProvider.truckAvailability[truckType] ??
                          'No trucks';

                      return _buildTruckTypeOption(
                        truckType: truckType,
                        isSelected: isSelected,
                        availability: availability,
                        onTap: () => mapProvider.selectTruckType(truckType),
                      );
                    }).toList(),
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
          Text(
            availability,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
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
