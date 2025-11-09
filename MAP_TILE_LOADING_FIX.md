# Map Tile Loading Issue - Fix Guide

## Problem Analysis

Based on the console logs, the map controller is created successfully, but map tiles are not loading. The key error is:
- `W/m140.euz: urls for epoch -1 not available.`
- `I/m140.duy: requestLegend unsuccessful for epoch -1 legend ROADMAP`

## Root Cause

The map widget is initialized correctly, but Google Maps SDK cannot fetch map tiles. This is typically caused by:

1. **API Key Restrictions** - Most common issue
2. **Network/Firewall blocking** Google Maps servers
3. **Maps SDK not enabled** in Google Cloud Console
4. **Billing not enabled** for the Google Cloud project

## Solution Steps

### Step 1: Verify API Key Restrictions

Go to [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services** → **Credentials**

1. Click on your API key
2. Under **API restrictions**, ensure:
   - **Maps SDK for Android** is selected (or "Don't restrict key")
   - **Maps SDK for iOS** is selected (if testing on iOS)
   - **Maps JavaScript API** is NOT required (that's for web)

3. Under **Application restrictions**:
   - If using **Android apps**, add:
     - Package name: `com.pickc.pick_c_customer`
     - SHA-1 certificate fingerprint (get it using command below)
   
4. **Temporarily remove restrictions** for testing:
   - Set API restrictions to "Don't restrict key"
   - Set Application restrictions to "None"
   - Save and wait 5 minutes
   - Test if map loads
   - If it works, gradually add restrictions back

### Step 2: Get SHA-1 Fingerprint (Android)

For debug builds:
```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 fingerprint in the output under `Variant: debug`

Or use:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds (if testing release):
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias your_key_alias
```

### Step 3: Verify Maps SDK is Enabled

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Library**
3. Search for and enable:
   - ✅ **Maps SDK for Android**
   - ✅ **Maps SDK for iOS** (if testing on iOS)
   - ✅ **Places API** (for location search)
   - ✅ **Directions API** (for routes)
   - ✅ **Geocoding API** (for address conversion)

### Step 4: Verify Billing is Enabled

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Billing**
3. Ensure billing is enabled for your project
4. Google Maps requires billing to be enabled (even for free tier)

### Step 5: Test API Key Directly

Test your API key with a curl command:

```bash
# Replace YOUR_API_KEY with your actual key
curl "https://maps.googleapis.com/maps/api/staticmap?center=37.4219983,-122.084&zoom=15&size=400x400&key=YOUR_API_KEY"
```

If this returns an image, your API key works. If it returns an error, check the error message.

### Step 6: Check Network/Firewall

1. Ensure device/emulator has internet access
2. Test if you can access: `https://maps.googleapis.com`
3. Check if VPN or firewall is blocking Google Maps servers
4. Try on a different network

### Step 7: Clean and Rebuild

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter run
```

### Step 8: Test with Minimal Restrictions

Temporarily create a test API key with no restrictions:

1. In Google Cloud Console, create a new API key
2. Don't set any restrictions
3. Enable Maps SDK for Android
4. Update `.env` file with the new key
5. Rebuild and test

If this works, the issue is with your API key restrictions.

## Common API Key Restriction Mistakes

❌ **Wrong**: Restricting to only "Maps JavaScript API" (that's for web)
✅ **Correct**: Restrict to "Maps SDK for Android" (for Android apps)

❌ **Wrong**: Using web browser restrictions for Android app
✅ **Correct**: Using Android app restrictions with package name and SHA-1

❌ **Wrong**: Not adding SHA-1 fingerprint for release builds
✅ **Correct**: Add both debug and release SHA-1 fingerprints

## Debug Checklist

- [ ] API key has no restrictions (temporarily for testing)
- [ ] Maps SDK for Android is enabled
- [ ] Billing is enabled
- [ ] SHA-1 fingerprint added to API key restrictions
- [ ] Package name matches: `com.pickc.pick_c_customer`
- [ ] Test API key works with curl command
- [ ] Device/emulator has internet access
- [ ] No VPN/firewall blocking Google Maps servers
- [ ] Clean rebuild done
- [ ] Waiting 5 minutes after changing API key restrictions

## Expected Console Output

**Good signs:**
```
✅ Google Map created successfully!
🎛️ Map controller ready
🗺️ Map widget is rendering
```

**Bad signs:**
```
W/m140.euz: urls for epoch -1 not available.
I/m140.duy: requestLegend unsuccessful
```

The warnings might appear initially but should clear once tiles load. If they persist, it's likely an API key restriction issue.

## Still Not Working?

If tiles still don't load after trying all above:

1. **Check Google Cloud Console error logs**:
   - Go to **APIs & Services** → **Dashboard**
   - Check for any error messages related to your API key

2. **Test with a simple Flutter example**:
   - Create a new Flutter project
   - Add google_maps_flutter
   - Test with minimal code and your API key
   - If it works there, the issue is specific to this project

3. **Check Google Maps Platform status**:
   - Visit: https://status.cloud.google.com/
   - Check if Maps API has any outages

4. **Verify your API key quota**:
   - Go to **APIs & Services** → **Dashboard**
   - Check if you've exceeded free tier limits

5. **Contact Google Support** if you have a paid plan, or check Google Maps Platform documentation for troubleshooting.


