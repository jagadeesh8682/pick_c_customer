# Play Store Release Instructions - Pick-C Customer App

**Version**: 1.0.0  
**Date**: January 20, 2025  
**Status**: Ready for Release

---

## Overview

This document provides step-by-step instructions for building and releasing the Pick-C Customer app to Google Play Store.

---

## Prerequisites

### ✅ Already Configured

1. **Keystore**: `android/app/upload-keystore.jks`
2. **Properties File**: `android/key.properties`
3. **ProGuard Rules**: `android/app/proguard-rules.pro`
4. **Build Configuration**: Updated `build.gradle.kts`

### Keystore Details

- **Location**: `android/app/upload-keystore.jks`
- **Alias**: `upload`
- **Passwords**: `pick_c` (both store and key password)
- **Properties**: Already configured in `android/key.properties`

---

## Build Configuration Summary

### Files Modified

#### 1. `android/app/build.gradle.kts`
- ✅ Added keystore properties loading
- ✅ Created release signing configuration
- ✅ Configured ProGuard/R8 rules
- ✅ Enabled minification and resource shrinking

#### 2. `android/key.properties`
- ✅ Store password: `pick_c`
- ✅ Key password: `pick_c`
- ✅ Key alias: `upload`
- ✅ Store file: `app/upload-keystore.jks` (relative to android folder)

---

## Build Release APK

### Step 1: Clean Build

```bash
# Navigate to project root
cd ~/Documents/myprojects/pick_c_customer

# Clean previous builds
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
```

### Step 2: Verify Configuration

```bash
# Check keystore exists
ls -lh android/app/upload-keystore.jks

# Check key.properties
cat android/key.properties
```

### Step 3: Build Release APK

```bash
# Build release APK
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Step 4: Build App Bundle (Recommended for Play Store)

```bash
# Build release App Bundle (AAB format)
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

---

## Verify Build

### Check APK/Bundle

```bash
# Check APK file
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Check AAB file
ls -lh build/app/outputs/bundle/release/app-release.aab

# Verify signing
cd android
./gradlew signingReport
cd ..
```

### Expected Output

```
Store: app/upload-keystore.jks
Alias: upload
MD5: [MD5 hash]
SHA1: [SHA1 hash]
SHA-256: [SHA-256 hash]
Valid until: [Expiration date]
```

---

## Upload to Play Store

### Step 1: Create Play Store Listing

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details:
   - **App Name**: Pick-C Customer
   - **Category**: Transportation
   - **Package Name**: com.pickc.pick_c_customer
   - **Default Language**: English

### Step 2: Upload AAB

1. Go to **App Bundle** section
2. Upload: `build/app/outputs/bundle/release/app-release.aab`
3. Wait for processing (5-10 minutes)

### Step 3: Complete Store Listing

#### App Information
- **App Name**: Pick-C Customer
- **Short Description**: Convenient truck booking and logistics management
- **Full Description**: 
  ```
  Pick-C Customer app lets you book trucks for cargo transportation with ease. 
  Features include:
  - Quick truck booking
  - Real-time driver tracking
  - Multiple payment options
  - Booking history
  - Invoice management
  ```

#### Graphics
- App Icon (512x512 PNG)
- Feature Graphic (1024x500 PNG)
- Screenshots (at least 2, maximum 8)

#### Categorization
- **Category**: Transportation
- **Tags**: truck, booking, logistics, cargo, delivery

### Step 4: Pricing & Distribution

- **Price**: Free
- **Countries**: Select distribution countries
- **Content Rating**: Complete questionnaire
- **Data Safety**: Fill safety information

### Step 5: Release

1. Go to **Production** track
2. Review all sections completed
3. Click **Start rollout to Production**
4. App will be live within a few hours

---

## Version Management

### Current Version

```yaml
# In pubspec.yaml
version: 1.0.0+1
# Format: versionName+versionCode
```

### Updating Version for Updates

For each new release:

1. Update `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Increment both
   ```

2. Update version code in `android/app/build.gradle.kts`:
   ```kotlin
   versionCode = 2
   versionName = "1.0.1"
   ```

---

## Testing Before Release

### Pre-Release Checklist

- [ ] APK installs on test device
- [ ] App launches without crashes
- [ ] Login works
- [ ] Booking flow works
- [ ] Payment gateway opens
- [ ] Maps load correctly
- [ ] Push notifications work
- [ ] No console errors

### Test on Multiple Devices

```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Test on different devices
flutter install --release
```

---

## Troubleshooting

### Build Errors

#### Error: Keystore not found

**Solution**:
```bash
# Verify keystore location
ls android/app/upload-keystore.jks

# Check key.properties path
cat android/key.properties
```

#### Error: Invalid keystore password

**Solution**: Update passwords in `android/key.properties`

#### Error: ProGuard errors

**Solution**: Already fixed with `proguard-rules.pro` file

#### Error: Missing Google Maps API Key

**Solution**: Ensure `.env` file has `GOOGLE_MAPS_API_KEY` set

---

### Release Errors

#### Error: Unsigned APK

**Solution**: Ensure `signingConfig` is set in `build.gradle.kts`

#### Error: AAB too large

**Solution**: Already enabled resource shrinking in config

---

## Security Best Practices

### ✅ Already Implemented

1. **ProGuard Enabled**: Code obfuscation
2. **Resource Shrinking**: Reduces APK size
3. **API Keys Secured**: Stored in .env (not committed)
4. **Signed APK**: Using production keystore

### Important Notes

⚠️ **Keep Keystore Safe**
- Backup `upload-keystore.jks` securely
- Store passwords safely
- Never commit keystore to git

⚠️ **API Keys**
- Never expose in code
- Use .env file
- Don't commit .env to git

---

## Release Rollout

### Initial Release

1. **Internal Testing**: Test with internal team (1-2 days)
2. **Closed Beta**: Release to beta testers (3-5 days)
3. **Production**: Full rollout to all users

### Rollout Strategy

- **Phase 1**: 20% of users (monitor for issues)
- **Phase 2**: 50% of users (if no issues)
- **Phase 3**: 100% rollout

---

## Post-Release

### Monitor

- Crash reports in Play Console
- User ratings and reviews
- Support tickets
- Analytics data

### Quick Fixes

For critical bugs:
1. Fix issue
2. Increment version
3. Build new release
4. Upload hotfix
5. Staged rollout (100%)

---

## Build Commands Summary

```bash
# 1. Clean build
flutter clean && flutter pub get

# 2. Build release APK
flutter build apk --release

# 3. Build release App Bundle (for Play Store)
flutter build appbundle --release

# 4. Verify signing
cd android && ./gradlew signingReport && cd ..

# 5. Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Success Checklist

### Before Release
- [ ] All features tested
- [ ] No crashes in testing
- [ ] APK builds successfully
- [ ] App signed with production keystore
- [ ] ProGuard rules applied
- [ ] API keys configured
- [ ] Version updated

### After Upload
- [ ] AAB uploaded to Play Console
- [ ] Store listing completed
- [ ] Content rating obtained
- [ ] Screenshots added
- [ ] Description updated
- [ ] Ready for review

---

## Files Reference

### Configuration Files

| File | Purpose |
|------|---------|
| `android/app/build.gradle.kts` | Build configuration |
| `android/key.properties` | Keystore credentials |
| `android/app/proguard-rules.pro` | ProGuard rules |
| `android/app/upload-keystore.jks` | Signing keystore |
| `.env` | Environment variables |

### Build Output

| File | Location |
|------|----------|
| APK | `build/app/outputs/flutter-apk/app-release.apk` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` |

---

## Support

### If You Need Help

1. **Build Issues**: Check `BUILD_FIX_GUIDE.md`
2. **Testing**: See `RELEASE_BUILD_TESTING_GUIDE.md`
3. **Play Store**: Check [Google Play Help](https://support.google.com/googleplay/android-developer/)

---

## Conclusion

Your app is now ready for Play Store release! Follow the steps above to build and upload your release.

**Remember**:
- ✅ Use AAB format for Play Store
- ✅ Test thoroughly before release
- ✅ Keep keystore and passwords safe
- ✅ Monitor after release

**Good luck with your release!** 🚀

---

**Document Version**: 1.0  
**Last Updated**: January 20, 2025  
**Status**: ✅ Ready for Release



