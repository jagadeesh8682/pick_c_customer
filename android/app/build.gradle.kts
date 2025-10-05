plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load environment variables from .env file
fun loadEnvFile(): Map<String, String> {
    val envFile = file("../../.env")  // Fixed path to .env file
    val env = mutableMapOf<String, String>()
    
    if (envFile.exists()) {
        println("Found .env file at: ${envFile.absolutePath}")
        envFile.readLines().forEach { line ->
            if (line.isNotBlank() && !line.startsWith("#")) {
                val parts = line.split("=", limit = 2)
                if (parts.size == 2) {
                    env[parts[0].trim()] = parts[1].trim()
                }
            }
        }
    } else {
        println("❌ .env file not found at: ${envFile.absolutePath}")
    }
    return env
}

val envVars = loadEnvFile()

android {
    namespace = "com.example.pick_c_customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.pick_c_customer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Load API key from .env file
        val googleMapsApiKey = envVars["GOOGLE_MAPS_API_KEY"] ?: ""
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
        
        // Debug: Print API key status
        println("Google Maps API Key loaded: ${if (googleMapsApiKey.isNotEmpty()) "✅ Yes (${googleMapsApiKey.take(10)}...)" else "❌ No"}")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
