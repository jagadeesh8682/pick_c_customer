# Quick Map Fix Guide - Step by Step

## Immediate Action Plan

### Step 1: Run Diagnostic Test

Add this to test if maps work at all:

```dart
// Temporarily change your home route in main.dart to:
home: MapDiagnosticWidget(), // Instead of MapScreen
```

Run the app and see if the diagnostic map loads. This will tell us if:
- ✅ API key works
- ✅ Maps SDK is configured correctly
- ❌ Or if there's a fundamental issue

### Step 2: Verify API Key Works

Test your API key with curl:

```bash
# Get your API key from .env
cat .env | grep GOOGLE_MAPS_API_KEY

# Test it (replace YOUR_KEY with actual key)
curl "https://maps.googleapis.com/maps/api/staticmap?center=37.4219983,-122.084&zoom=15&size=400x400&key=YOUR_KEY"
```

**Expected**: Returns a map image file
**If fails**: API key is invalid or restricted

### Step 3: Check Google Cloud Console

1. Go to https://console.cloud.google.com/
2. Select your project
3. **APIs & Services** → **Library**
4. Verify these are **ENABLED**:
   - ✅ Maps SDK for Android
   - ✅ Maps SDK for iOS (if testing iOS)
   - ✅ Places API
   - ✅ Directions API
   - ✅ Geocoding API

5. **APIs & Services** → **Credentials**
6. Click your API key
7. **Temporarily** set:
   - API restrictions: **"Don't restrict key"**
   - Application restrictions: **"None"**
8. Save and wait 5 minutes
9. Test again

### Step 4: Check Emulator/Device

**For Emulator:**
```bash
# Check Google Play Services
adb shell pm list packages | grep gms

# Should see packages like:
# com.google.android.gms
# com.google.android.gms.policy_maps_core_dynamite
```

**If no Google Play Services:**
- Your emulator needs Google APIs or Google Play system image
- Create new AVD with "Google Play" (not just "Google APIs")

**Best Solution: Test on Physical Device**
- Physical devices almost always work
- Emulators often have Google Play Services issues

### Step 5: Check Logs for Specific Errors

Run the app and look for these in console:

**Good signs:**
```
✅ Google Map created successfully!
🎛️ Map controller ready
```

**Bad signs:**
```
REQUEST_TIMEOUT
urls for epoch -1 not available
requestLegend unsuccessful
```

These errors usually mean:
1. Google Play Services can't connect (emulator issue)
2. API key restrictions too strict
3. Network/firewall blocking Google servers

### Step 6: Try Alternative Approach

If nothing works, try using `liteModeEnabled: true` temporarily:

```dart
GoogleMap(
  liteModeEnabled: true, // Static map that always loads
  // ... other options
)
```

If lite mode works, the issue is with dynamic map tile loading.

### Step 7: Clean Rebuild

```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

## Common Solutions

### Solution 1: API Key Format Issue

Check `AndroidManifest.xml`:
```xml
<!-- ✅ CORRECT -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy..." />

<!-- ❌ WRONG - Don't include "key=" prefix -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="key=AIzaSy..." />
```

### Solution 2: Emulator Google Play Services

1. Open Android Studio
2. **Tools** → **Device Manager**
3. Create new virtual device
4. Choose system image with **"Google Play"** icon (not just Google APIs)
5. Start new emulator
6. Test app

### Solution 3: Network/Firewall

```bash
# Test connectivity
adb shell ping -c 3 maps.googleapis.com

# If fails, check:
# - VPN settings
# - Firewall rules
# - Corporate network restrictions
```

### Solution 4: Billing Not Enabled

1. Google Cloud Console
2. **Billing**
3. Ensure billing account is linked
4. Maps API requires billing (even for free tier)

## Diagnostic Checklist

Run through this checklist:

- [ ] API key works with curl command
- [ ] Maps SDK for Android is enabled in Google Cloud
- [ ] Billing is enabled in Google Cloud
- [ ] API key restrictions temporarily removed
- [ ] Testing on physical device (not just emulator)
- [ ] Emulator has Google Play Services installed
- [ ] Internet connection is working
- [ ] No VPN/firewall blocking Google servers
- [ ] Clean rebuild performed
- [ ] Checked console logs for specific errors

## If Still Not Working

Share these details:

1. **Console logs** (especially any error messages)
2. **Device type** (emulator name/model or physical device)
3. **API key test result** (from curl command)
4. **Google Cloud Console status** (APIs enabled, billing, restrictions)

## Quick Test Commands

```bash
# Test API key
curl "https://maps.googleapis.com/maps/api/staticmap?center=37.4219983,-122.084&zoom=15&size=400x400&key=YOUR_KEY" -o test_map.png

# Check Google Play Services on device
adb shell pm list packages | grep gms

# Check internet connectivity
adb shell ping -c 3 maps.googleapis.com

# View app logs
flutter logs | grep -i map
```

## Most Likely Fix

**90% of cases are solved by:**
1. Testing on **physical device** instead of emulator
2. **Temporarily removing** all API key restrictions
3. Ensuring **billing is enabled** in Google Cloud Console


