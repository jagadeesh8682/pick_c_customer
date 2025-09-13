# Pick C Customer - Flutter App

A Flutter application built with clean architecture principles and Provider state management.

## Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── constants/                  # App constants
│   │   └── app_url.dart           # API endpoints
│   ├── network/                    # Network layer
│   │   ├── network_service.dart   # Network service interface
│   │   ├── network_service_impl.dart # Network service implementation
│   │   └── response_model.dart    # API response model
│   ├── providers/                  # Global providers
│   │   └── app_providers.dart     # App-wide provider setup
│   ├── routes/                     # Navigation
│   │   ├── app_routes.dart        # Route definitions
│   │   └── routes_name.dart       # Route constants
│   ├── theme/                      # App theming
│   │   └── app_theme.dart         # Theme configuration
│   └── utils/                      # Utility functions
│       ├── app_initialization.dart # App initialization
│       └── navigation_service.dart # Navigation service
├── data/                          # Data layer
│   ├── models/                    # Data models
│   │   └── user_model.dart       # User model
│   └── repositories/              # Data repositories
│       └── auth_repository.dart  # Authentication repository
├── presentation/                  # Presentation layer
│   ├── pages/                     # App screens
│   │   └── login_page.dart       # Login screen
│   ├── providers/                 # State management
│   │   └── auth_provider.dart    # Authentication provider
│   └── widgets/                   # Reusable widgets
│       └── custom_button.dart    # Custom button widget
└── main.dart                     # App entry point
```

## Architecture

This project follows **Clean Architecture** principles with the following layers:

### 1. Core Layer
- **Constants**: App-wide constants and configuration
- **Network**: HTTP client and API communication
- **Providers**: Global state management setup
- **Routes**: Navigation and routing logic
- **Theme**: App theming and styling
- **Utils**: Utility functions and services

### 2. Data Layer
- **Models**: Data transfer objects and entities
- **Repositories**: Data access abstraction

### 3. Presentation Layer
- **Pages**: UI screens and pages
- **Providers**: State management for UI
- **Widgets**: Reusable UI components

## Features

- ✅ Clean Architecture
- ✅ Provider State Management
- ✅ HTTP Network Layer with retry logic
- ✅ Firebase Integration
- ✅ Custom Theme
- ✅ Navigation Service
- ✅ Error Handling
- ✅ Loading States

## Dependencies

- `provider`: State management
- `http`: HTTP client
- `firebase_core`: Firebase core
- `firebase_auth`: Firebase authentication
- `shared_preferences`: Local storage
- `connectivity_plus`: Network connectivity

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Firebase:
   - Add your Firebase configuration files
   - Update `firebase_options.dart` if needed

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Adding New Features

1. **Create Models** in `data/models/`
2. **Create Repositories** in `data/repositories/`
3. **Create Providers** in `presentation/providers/`
4. **Create Pages** in `presentation/pages/`
5. **Add Routes** in `core/routes/`

### Network Service Usage

```dart
// Authenticated request
final response = await networkService.getGetApiResponse(url);

// Unauthenticated request
final response = await networkService.getPostApiResponseUnauthenticated(url, data);
```

### Provider Usage

```dart
// In your widget
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.isLoading ? 'Loading...' : 'Ready');
  },
)
```

## API Configuration

Update `lib/core/constants/app_url.dart` with your API endpoints:

```dart
class AppUrl {
  static const String baseUrl = 'your-api-base-url';
  static const String userService = '$baseUrl/user-service';
  // ... other endpoints
}
```

## Theme Customization

Modify `lib/core/theme/app_theme.dart` to customize the app's appearance:

```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    // Your light theme configuration
  );
  
  static ThemeData get darkTheme => ThemeData(
    // Your dark theme configuration
  );
}
```