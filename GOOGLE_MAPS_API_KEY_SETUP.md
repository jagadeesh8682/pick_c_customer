# Google Maps API Key Setup Guide

## Problem
The Google Map is not showing because the `.env` file contains placeholder values instead of actual API keys.

## Solution

### Step 1: Get Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - **Maps SDK for Android** (for Android builds)
   - **Maps SDK for iOS** (for iOS builds)
   - **Places API** (for place search)
   - **Directions API** (for route calculations)
   - **Geocoding API** (for address conversion)
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Restrict the API key:
   - **Android**: Add your package name (`com.pickc.pick_c_customer`) and SHA-1 fingerprint
   - **iOS**: Add your bundle identifier
   - **HTTP referrers**: Add your domain (if using web)

### Step 2: Update .env File

Open the `.env` file in the project root and replace the placeholder values:

```env
# Google Maps API Keys
GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_API_KEY_HERE
GOOGLE_PLACES_API_KEY=YOUR_ACTUAL_API_KEY_HERE
GOOGLE_DIRECTIONS_API_KEY=YOUR_ACTUAL_API_KEY_HERE

# Razorpay Configuration
RAZORPAY_KEY_ID=JHMu0RNKkhZT4ewpKIm2rc7w
RAZORPAY_KEY_SECRET=your_razorpay_key_secret_here

# Environment
ENVIRONMENT=development
```

**Important**: 
- Replace `YOUR_ACTUAL_API_KEY_HERE` with your actual API key from Google Cloud Console
- You can use the same API key for all three Google services, or create separate keys
- Never commit the `.env` file with real API keys to version control (it's already in `.gitignore`)

### Step 3: For Android Release Builds

The API key is automatically loaded from `.env` file during build. The `build.gradle.kts` file reads the key and injects it into `AndroidManifest.xml`.

### Step 4: For iOS Builds

#### Option A: Using .env file (Development)
The `AppDelegate.swift` will automatically load the API key from the `.env` file if it's included in the bundle.

#### Option B: Using Info.plist (Production - Recommended)
For production iOS builds, you should set the API key directly in `Info.plist`:

1. Open `ios/Runner/Info.plist` in Xcode
2. Find the `GMSApiKey` key
3. Replace `$(GOOGLE_MAPS_API_KEY)` with your actual API key

Or manually edit `ios/Runner/Info.plist`:
```xml
<key>GMSApiKey</key>
<string>YOUR_ACTUAL_API_KEY_HERE</string>
```

**Note**: Never commit API keys in `Info.plist` to version control for production apps. Use build configurations or CI/CD secrets instead.

### Step 5: Restart the App

After updating the `.env` file:
1. Stop the app completely
2. Rebuild the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Verification

After setting up the API key, you should see:
- ✅ Google Maps loads correctly
- ✅ Console shows: "✅ Google Maps API Key loaded"
- ✅ No error messages in the console
- ✅ Map displays with your location or default location (Hyderabad)

## Troubleshooting

### Map still not showing?

1. **Check the console logs** for API key loading messages
2. **Verify the API key** is correct and not a placeholder
3. **Check API restrictions** in Google Cloud Console - make sure your app's package name/bundle ID is allowed
4. **Verify API is enabled** - ensure Maps SDK for Android/iOS is enabled in Google Cloud Console
5. **Check internet connection** - Maps require an active internet connection
6. **Verify location permissions** - The app needs location permissions for showing current location

### Android-specific issues

- Ensure `GOOGLE_MAPS_API_KEY` is in your `.env` file
- Check `android/app/build.gradle.kts` logs during build for API key loading status
- Verify `AndroidManifest.xml` has the correct meta-data tag

### iOS-specific issues

- For development: Ensure `.env` file is accessible (it may not be bundled automatically)
- For production: Set the API key directly in `Info.plist`
- Check `AppDelegate.swift` console logs for API key initialization messages

## Security Best Practices

1. **Never commit `.env` file** to version control (already in `.gitignore`)
2. **Restrict your API keys** in Google Cloud Console to only your app's package/bundle ID
3. **Use separate API keys** for development and production
4. **Set billing alerts** in Google Cloud Console to avoid unexpected charges
5. **Rotate keys** if they're ever exposed or compromised

## Current Status

The app will now detect placeholder API keys and show a helpful error message with instructions on how to fix it. Once you add your actual API key, the map will load correctly.


