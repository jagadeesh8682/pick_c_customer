# Secure API Key Management 🔐

## Overview
This document explains how API keys are securely managed in the Pick C Customer app, ensuring they are **ONLY** stored in the `.env` file and never hardcoded in source code.

## 🔑 Security Principles

### ✅ **What We Do (Secure)**
- Store API keys **ONLY** in `.env` file
- Load keys at runtime from environment variables
- Use build-time variable substitution for platform-specific configs
- Never commit API keys to version control

### ❌ **What We Don't Do (Insecure)**
- Hardcode API keys in source code
- Store keys in configuration files
- Commit keys to Git repository
- Use fallback hardcoded values

## 📁 File Structure

```
pick_c_customer/
├── .env                           # 🔐 API keys (NOT in version control)
├── lib/core/constants/
│   └── api_keys.dart              # 🔧 API key access layer
├── android/app/src/main/
│   └── AndroidManifest.xml        # 📱 Android config (uses env vars)
├── ios/Runner/
│   └── AppDelegate.swift          # 🍎 iOS config (uses env vars)
├── android/app/
│   └── build.gradle.kts           # 🔨 Android build config
├── build_app.sh                   # 🚀 Secure build script
└── setup_env.sh                   # ⚙️ Environment setup script
```

## 🔐 API Key Storage

### **Primary Storage: `.env` File**
```env
# Google Maps API Key
GOOGLE_MAPS_API_KEY=AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE

# Google Places API Key
GOOGLE_PLACES_API_KEY=AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE

# Google Directions API Key
GOOGLE_DIRECTIONS_API_KEY=AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE
```

### **Access Layer: `lib/core/constants/api_keys.dart`**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  /// Google Maps API Key from .env file
  static String get googleMapsApiKey => 
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Google Places API Key from .env file
  static String get googlePlacesApiKey => 
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Google Directions API Key from .env file
  static String get googleDirectionsApiKey => 
      dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';

  /// Check if API keys are properly loaded
  static bool get areApiKeysLoaded =>
      googleMapsApiKey.isNotEmpty && 
      googlePlacesApiKey.isNotEmpty && 
      googleDirectionsApiKey.isNotEmpty;
}
```

## 🏗️ Platform-Specific Configuration

### **Android Configuration**

#### **AndroidManifest.xml**
```xml
<!-- Google Maps API Key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}" />
```

#### **build.gradle.kts**
```kotlin
defaultConfig {
    // Load API key from environment variables
    val googleMapsApiKey = System.getenv("GOOGLE_MAPS_API_KEY") ?: ""
    manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
}
```

### **iOS Configuration**

#### **AppDelegate.swift**
```swift
override func application(
  _ application: UIApplication,
  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
  // Initialize Google Maps with API key from environment
  if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] {
    GMSServices.provideAPIKey(apiKey)
  } else {
    print("⚠️ Warning: GOOGLE_MAPS_API_KEY not found in environment variables")
  }
  
  GeneratedPluginRegistrant.register(with: self)
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

## 🚀 Secure Build Process

### **Using the Build Script**
```bash
# Make script executable
chmod +x build_app.sh

# Build debug version
./build_app.sh debug

# Build release version
./build_app.sh release
```

### **Manual Build Process**
```bash
# 1. Load environment variables
export $(grep -v '^#' .env | xargs)

# 2. Verify API keys are loaded
echo "Maps Key: ${GOOGLE_MAPS_API_KEY:0:20}..."

# 3. Build the app
flutter build apk --release
```

## 🔍 Verification Steps

### **1. Check .env File**
```bash
cat .env
```
Should show:
```
GOOGLE_MAPS_API_KEY=AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE
GOOGLE_PLACES_API_KEY=AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE
GOOGLE_DIRECTIONS_API_KEY=AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE
```

### **2. Verify No Hardcoded Keys**
```bash
# Search for hardcoded API keys in source code
grep -r "AIzaSyAcv7D6zbckc22vXM8fK1zmzZ2gObE5RWE" lib/ android/ ios/
```
Should return no results (except in .env file)

### **3. Test API Key Loading**
Run the app and check console output:
```
🔑 API Keys Debug Info:
Maps Key: ✅ Loaded
Places Key: ✅ Loaded
Directions Key: ✅ Loaded
All Keys Loaded: ✅ Yes
```

## 🛡️ Security Best Practices

### **1. Environment File Management**
- ✅ Keep `.env` in `.gitignore`
- ✅ Never commit API keys to version control
- ✅ Use different keys for development/production
- ✅ Rotate keys regularly

### **2. Build Process Security**
- ✅ Load keys from environment variables
- ✅ Use build-time substitution
- ✅ No hardcoded fallbacks
- ✅ Validate keys before build

### **3. Runtime Security**
- ✅ Check key availability before use
- ✅ Show user-friendly errors for missing keys
- ✅ Log key status for debugging
- ✅ Handle key validation gracefully

## 🔧 Development Workflow

### **1. Initial Setup**
```bash
# Create .env file with your API keys
echo "GOOGLE_MAPS_API_KEY=your_key_here" > .env
echo "GOOGLE_PLACES_API_KEY=your_key_here" >> .env
echo "GOOGLE_DIRECTIONS_API_KEY=your_key_here" >> .env

# Run setup script
./setup_env.sh
```

### **2. Development**
```bash
# Load environment and run
export $(grep -v '^#' .env | xargs)
flutter run
```

### **3. Building for Production**
```bash
# Use secure build script
./build_app.sh release
```

## 🚨 Troubleshooting

### **Common Issues**

#### **1. API Keys Not Loading**
**Error**: `API Key Configuration Required`

**Solution**:
```bash
# Check .env file exists
ls -la .env

# Verify file content
cat .env

# Check environment loading
export $(grep -v '^#' .env | xargs)
echo $GOOGLE_MAPS_API_KEY
```

#### **2. Build Failures**
**Error**: Build fails with missing API key

**Solution**:
```bash
# Use the secure build script
./build_app.sh debug
```

#### **3. Maps Not Loading**
**Error**: Blank map or error tiles

**Solution**:
- Verify API key is correct in `.env`
- Check Google Cloud Console API restrictions
- Ensure required APIs are enabled

## 📋 Security Checklist

- [ ] `.env` file exists with API keys
- [ ] `.env` file is in `.gitignore`
- [ ] No hardcoded API keys in source code
- [ ] Android build uses environment variables
- [ ] iOS build uses environment variables
- [ ] Flutter code loads keys from environment
- [ ] Build script validates key presence
- [ ] App shows proper error for missing keys
- [ ] Different keys for dev/prod environments
- [ ] API key restrictions configured in Google Cloud Console

## 🎯 Summary

✅ **API keys are ONLY stored in `.env` file**  
✅ **No hardcoded keys in source code**  
✅ **Secure build process with environment variables**  
✅ **Platform-specific configurations use env vars**  
✅ **Proper error handling for missing keys**  
✅ **Development and production key separation**  

This implementation ensures maximum security while maintaining ease of development and deployment.

