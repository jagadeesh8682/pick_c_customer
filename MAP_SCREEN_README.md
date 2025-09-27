# Pick-C Customer App - Truck Booking Screen

A Flutter customer app screen for truck booking with Google Maps integration, designed with a black and yellow theme similar to Uber's interface.

## 📁 Project Structure

```
lib/
├── screens/
│   └── map_screen.dart          # Main map screen with Google Maps
├── providers/
│   └── map_provider.dart        # State management for map functionality
├── repos/
│   └── map_repository.dart      # Repository for backend simulation
└── main.dart                    # App entry point with MultiProvider setup
```

## 🚀 Features

### Map Screen (`screens/map_screen.dart`)
- **Google Maps Integration**: Full-screen Google Maps with current location marker
- **App Bar**: Black background with yellow "Book Pick-C Truck" title
  - Left: Hamburger menu button
  - Right: Notification bell icon
- **Location Input Fields**: 
  - Pickup location field with green flag icon
  - Drop location field with red flag icon
  - Both fields have lock icons on the right
- **Floating Lock Button**: Centered black button with yellow "Lock location" text
- **Truck Type Selector**: Horizontal selector with Mini, Small, Medium, Large options
  - Mini truck is pre-selected with yellow background
  - Each option shows availability status ("No trucks")
- **Bottom Action Buttons**:
  - "BOOK LATER" - Yellow background with black text
  - "BOOK NOW" - Black background with yellow text

### State Management (`providers/map_provider.dart`)
- **ChangeNotifier-based** state management
- **Location Management**: Current location tracking and updates
- **Truck Selection**: Selected truck type management
- **Booking Logic**: Book now/later functionality with loading states
- **Availability Tracking**: Real-time truck availability updates

### Repository (`repos/map_repository.dart`)
- **Backend Simulation**: Mock API calls for truck availability
- **Booking Service**: Simulated truck booking with confirmation
- **Location Service**: Mock current location fetching

## 🛠️ Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  # Maps & Location
  google_maps_flutter: ^2.6.1
  geolocator: ^11.0.0
  permission_handler: ^11.3.1
  
  # State Management
  provider: ^6.1.2
```

## 📱 Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Google Maps API Key Setup

#### Android Setup
1. Get your Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add the API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
</application>
```

#### iOS Setup
1. Add the API key to `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. Permissions Setup

#### Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS Permissions (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location when open and in the background.</string>
```

## 🎨 UI Design Features

### Color Scheme
- **Primary Black**: `Colors.black` for app bar and buttons
- **Accent Yellow**: `Colors.yellow` for highlights and selected states
- **Clean White**: `Colors.white` for backgrounds and unselected states

### Responsive Design
- **Stack Layout**: Overlays UI elements on top of Google Maps
- **Positioned Widgets**: Precise positioning for all UI components
- **Safe Area**: Proper handling of device notches and status bars

### Interactive Elements
- **Truck Type Selection**: Visual feedback with color changes
- **Loading States**: Progress indicators during booking operations
- **Booking Confirmation**: Dialog showing booking details

## 🔧 Usage

### Running the App
```bash
flutter run
```

### Key Functionality
1. **Location Tracking**: Automatically shows current location on map
2. **Truck Selection**: Tap truck types to select (Mini is pre-selected)
3. **Location Locking**: Tap "Lock location" to toggle location lock state
4. **Booking**: Tap "BOOK NOW" or "BOOK LATER" to simulate booking
5. **Confirmation**: Shows booking confirmation dialog with details

## 📋 Code Architecture

### Provider Pattern
- **MapProvider**: Manages all map-related state
- **Repository Pattern**: Separates data access from UI logic
- **Clean Architecture**: Clear separation of concerns

### Widget Organization
- **Reusable Components**: Helper methods for consistent UI elements
- **Modular Design**: Each UI section is a separate method
- **State Management**: Consumer widgets for reactive UI updates

## 🚀 Future Enhancements

1. **Real API Integration**: Replace mock repository with actual backend calls
2. **Location Services**: Implement real GPS location tracking
3. **Push Notifications**: Add notification handling for booking updates
4. **Payment Integration**: Add payment processing for bookings
5. **Driver Tracking**: Real-time driver location updates
6. **Booking History**: View past and current bookings

## 📝 Notes

- The app is currently set to launch directly to the MapScreen for testing
- All booking operations are simulated with mock data
- Location services require proper API key setup for full functionality
- The design closely matches the reference Uber-style interface

## 🔍 Troubleshooting

### Common Issues
1. **Maps not loading**: Ensure Google Maps API key is properly configured
2. **Location not showing**: Check location permissions in device settings
3. **Build errors**: Run `flutter clean && flutter pub get`

### Debug Mode
The app includes comprehensive error handling and loading states for debugging purposes.

