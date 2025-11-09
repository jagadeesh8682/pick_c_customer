# Google Maps Troubleshooting Guide

## Issue: Map Not Showing

If the Google Map is still not showing after setting up the API key, follow these troubleshooting steps:

### Step 1: Verify API Key Setup

1. **Check .env file**:
   ```bash
   cat .env | grep GOOGLE_MAPS_API_KEY
   ```
   Should show: `GOOGLE_MAPS_API_KEY=AIza...` (not a placeholder)

2. **Verify API key is loaded in the app**:
   - Run the app and check console logs
   - Look for: `✅ Google Maps API Key loaded`
   - If you see `❌ Missing` or `⚠️ WARNING`, the key is not loaded

### Step 2: Check Platform-Specific Configuration

#### Android

1. **Verify AndroidManifest.xml**:
   - Open `android/app/src/main/AndroidManifest.xml`
   - Check that meta-data tag exists:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="${GOOGLE_MAPS_API_KEY}" />
     ```

2. **Check build.gradle.kts**:
   - Open `android/app/build.gradle.kts`
   - Verify it loads from .env file
   - Check build output for: `✅ Google Maps API Key loaded`

3. **Rebuild the app**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

#### iOS

1. **Verify AppDelegate.swift**:
   - Check that it loads the API key from .env or Info.plist
   - Look for console output: `✅ Google Maps SDK initialized successfully`

2. **Check Info.plist** (optional, for production):
   - Can set GMSApiKey directly in Info.plist if .env doesn't work

3. **Rebuild**:
   ```bash
   cd ios && pod install && cd ..
   flutter clean
   flutter run
   ```

### Step 3: Verify API Key Permissions

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Click on your API key
4. Check **API restrictions**:
   - For Android: Must include **Maps SDK for Android**
   - For iOS: Must include **Maps SDK for iOS**
5. Check **Application restrictions**:
   - **Android apps**: Add package name `com.pickc.pick_c_customer` and SHA-1 fingerprint
   - **iOS apps**: Add bundle identifier

### Step 4: Check Console Logs

Run the app and look for these log messages:

✅ **Good signs**:
```
🗺️ Building Google Map with location: ...
🔑 Google Maps API Key: Present (AIza...)
📍 Map target location: LatLng(...)
✅ Google Map created successfully!
🗺️ Map widget is rendering
```

❌ **Bad signs**:
```
❌ Invalid API key - map will not render
⚠️ WARNING: .env contains placeholder API key
❌ ERROR: GOOGLE_MAPS_API_KEY not found
```

### Step 5: Test API Key Directly

Test your API key with a simple HTTP request:

```bash
# Replace YOUR_API_KEY with your actual key
curl "https://maps.googleapis.com/maps/api/geocode/json?address=Hyderabad&key=YOUR_API_KEY"
```

If this returns an error, the API key is invalid or not properly configured.

### Step 6: Common Issues and Fixes

#### Issue: "Map shows grey/blank screen"
- **Cause**: API key not loaded or invalid
- **Fix**: Verify .env file and restart app

#### Issue: "Map shows but is all grey"
- **Cause**: API key restrictions are too strict
- **Fix**: Check API restrictions in Google Cloud Console

#### Issue: "Map doesn't load on Android"
- **Cause**: Manifest placeholder not replaced
- **Fix**: Rebuild the app: `flutter clean && flutter run`

#### Issue: "Map doesn't load on iOS"
- **Cause**: API key not in bundle or Info.plist
- **Fix**: Add to Info.plist or ensure .env is in bundle

#### Issue: "Console shows 'onMapCreated' but map is blank"
- **Cause**: Widget layout issue or map rendering problem
- **Fix**: Check if map widget has proper size constraints

### Step 7: Enable Debug Mode

The app now includes extensive debug logging. Check console for:
- API key loading status
- Map initialization status
- Location updates
- Camera movements

### Step 8: Verify Internet Connection

Google Maps requires an active internet connection. Check:
- Device has internet access
- No firewall blocking Google Maps API
- VPN is not interfering

### Step 9: Test with Different Locations

Try setting a known location (like Hyderabad coordinates):
- The map should center on that location
- If it does, the issue might be with location permissions

### Step 10: Check Location Permissions

1. **Android**: Check `AndroidManifest.xml` has location permissions
2. **iOS**: Check `Info.plist` has location permission descriptions
3. Grant location permissions when prompted by the app

## Still Not Working?

If none of the above work:

1. **Create a minimal test**:
   - Create a new Flutter project
   - Add only google_maps_flutter package
   - Test with your API key
   - If it works, the issue is specific to this project

2. **Check Google Cloud Console**:
   - Verify billing is enabled (required for Maps API)
   - Check API quotas haven't been exceeded
   - Review error logs in Google Cloud Console

3. **Try a different API key**:
   - Create a new API key in Google Cloud Console
   - Update .env file
   - Rebuild and test

4. **Check Flutter and plugin versions**:
   ```bash
   flutter --version
   flutter pub deps | grep google_maps
   ```

5. **Platform-specific debugging**:
   - Android: Check `adb logcat | grep -i maps`
   - iOS: Check Xcode console logs

## Quick Checklist

- [ ] API key is in .env file (not placeholder)
- [ ] .env file is in project root
- [ ] API key has correct restrictions in Google Cloud Console
- [ ] Maps SDK for Android/iOS is enabled
- [ ] App has internet permission
- [ ] App has location permissions (AndroidManifest.xml/Info.plist)
- [ ] Rebuilt app after changing API key (`flutter clean && flutter run`)
- [ ] Billing is enabled in Google Cloud Console
- [ ] API quotas haven't been exceeded
- [ ] Console logs show API key is loaded

## Contact Support

If you've tried all of the above and the map still doesn't show, provide:
1. Console log output (with API key redacted)
2. Platform (Android/iOS/Web)
3. Flutter version: `flutter --version`
4. google_maps_flutter version from `pubspec.yaml`
5. Error messages (if any)


