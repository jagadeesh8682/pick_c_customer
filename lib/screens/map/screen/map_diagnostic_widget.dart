import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/api_keys.dart';

/// Diagnostic widget to test if Google Maps is working
class MapDiagnosticWidget extends StatefulWidget {
  const MapDiagnosticWidget({super.key});

  @override
  State<MapDiagnosticWidget> createState() => _MapDiagnosticWidgetState();
}

class _MapDiagnosticWidgetState extends State<MapDiagnosticWidget> {
  GoogleMapController? _controller;
  bool _mapLoaded = false;
  String _status = 'Initializing...';

  @override
  Widget build(BuildContext context) {
    final apiKey = ApiKeys.googleMapsApiKey;
    final hasValidKey =
        apiKey.isNotEmpty &&
        !apiKey.contains('your_') &&
        !apiKey.contains('YOUR_');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Diagnostic'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Status Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_status',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('API Key: ${hasValidKey ? "✅ Valid" : "❌ Invalid"}'),
                Text(
                  'Key preview: ${apiKey.isNotEmpty ? apiKey.substring(0, apiKey.length > 20 ? 20 : apiKey.length) + "..." : "Missing"}',
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                if (hasValidKey)
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _controller = controller;
                        _mapLoaded = true;
                        _status = 'Map loaded successfully!';
                      });
                      print('✅ Diagnostic: Map controller created');
                    },
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(17.3850, 78.4867), // Hyderabad
                      zoom: 15.0,
                    ),
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    compassEnabled: true,
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Invalid API Key'),
                        const SizedBox(height: 8),
                        Text(
                          'Please check your .env file',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                // Overlay with info
                if (_mapLoaded)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '✅ Map is working!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_controller != null) {
                      _controller!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          const LatLng(37.4219983, -122.084), // Google HQ
                          15.0,
                        ),
                      );
                      setState(() {
                        _status = 'Camera moved to Google HQ';
                      });
                    }
                  },
                  child: const Text('Test: Move to Google HQ'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller != null) {
                      _controller!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          const LatLng(17.3850, 78.4867), // Hyderabad
                          15.0,
                        ),
                      );
                      setState(() {
                        _status = 'Camera moved to Hyderabad';
                      });
                    }
                  },
                  child: const Text('Test: Move to Hyderabad'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

