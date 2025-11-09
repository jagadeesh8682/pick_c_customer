# Build Fix Guide - Android Release Build

## Problem

Building Android release APK failed with R8/ProGuard errors related to Razorpay and missing annotation classes.

## Error

```
ERROR: R8: Missing class proguard.annotation.Keep
ERROR: R8: Missing class proguard.annotation.KeepClassMembers
FAILURE: Build failed with an exception.
Execution failed for task ':app:minifyReleaseWithR8'.
```

## Solution Applied

### 1. Created ProGuard Rules File

Created `android/app/proguard-rules.pro` with comprehensive rules for:
- Flutter plugins
- Razorpay SDK
- Google Maps
- Missing annotation classes
- Data models
- Third-party libraries

### 2. Updated build.gradle.kts

Added ProGuard configuration to enable minification with proper rules:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        
        // Enable ProGuard/R8
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

## Build Instructions

### Clean Build

```bash
# Clean the project
cd android
./gradlew clean

# Or from project root
flutter clean
flutter pub get
```

### Build Release APK

```bash
flutter build apk --release
```

### Build Release App Bundle

```bash
flutter build appbundle --release
```

### Install on Device

```bash
flutter install --release
```

## Alternative: Build Without Minification (For Testing)

If you still face issues, you can build without minification temporarily:

Update `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        
        // Disable minification for testing
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
```

Then rebuild:

```bash
flutter build apk --release
```

## Verify Build

After successful build, verify the APK:

```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Check if it's signed
cd android
./gradlew signingReport
```

## Common Issues & Fixes

### Issue 1: Missing ProGuard Rules

**Error**: `Missing classes detected while running R8`

**Fix**: The `proguard-rules.pro` file has been created with all necessary rules.

### Issue 2: Razorpay Classes Missing

**Error**: `Missing class com.razorpay.**`

**Fix**: Added Razorpay keep rules in proguard-rules.pro:
```proguard
-keep class com.razorpay.** { *; }
```

### Issue 3: Annotation Classes Missing

**Error**: `Missing class proguard.annotation.Keep`

**Fix**: Added keep rules for annotation classes:
```proguard
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
```

### Issue 4: Build Still Failing

If build still fails after these fixes:

1. **Check build logs for specific missing classes**
   ```bash
   flutter build apk --release --verbose
   ```

2. **Review missing_rules.txt**
   Check file at: `build/app/outputs/mapping/release/missing_rules.txt`

3. **Add additional keep rules**
   Add missing classes to `proguard-rules.pro`

4. **Disable minification temporarily**
   Set `isMinifyEnabled = false` to test without R8

5. **Update dependencies**
   ```bash
   flutter pub upgrade
   cd android && ./gradlew --refresh-dependencies
   ```

## Production Build with Signing

When ready for production, configure proper signing:

### 1. Generate Keystore

```bash
keytool -genkey -v -keystore android/key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias pickc-customer
```

### 2. Create key.properties

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=pickc-customer
storeFile=key.jks
```

### 3. Update build.gradle.kts

```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

buildTypes {
    release {
        // Use production signing
        signingConfig = signingConfigs.create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
        
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

## Testing the Release Build

1. **Install APK**
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Test Critical Flows**
   - Login
   - Sign Up
   - Create booking
   - Payment
   - Invoice

3. **Check Logs**
   ```bash
   adb logcat | grep flutter
   ```

## Success Criteria

✅ APK builds without errors  
✅ APK installs on device  
✅ App launches successfully  
✅ Login works  
✅ API calls function properly  
✅ Payment gateway opens  
✅ No crashes in critical flows

## Next Steps

1. Test release build thoroughly
2. Update version numbers for release
3. Configure production signing
4. Upload to Play Store

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-20  
**Status**: Fixed ✅



