import java.util.Properties
import java.io.FileInputStream

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

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    println("✅ Keystore properties loaded successfully")
} else {
    println("❌ Keystore properties file not found at: ${keystorePropertiesFile.absolutePath}")
}

android {
    namespace = "com.pickc.pick_c_customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pickc.pick_c_customer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Load API key from .env file
        val googleMapsApiKey = envVars["GOOGLE_MAPS_API_KEY"] ?: System.getenv("GOOGLE_MAPS_API_KEY") ?: ""
        
        // Set manifest placeholder for Google Maps API Key
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
        
        // Also add as build config field for runtime access if needed
        buildConfigField("String", "GOOGLE_MAPS_API_KEY", "\"$googleMapsApiKey\"")
        
        // Debug: Print API key status
        if (googleMapsApiKey.isNotEmpty()) {
            println("✅ Google Maps API Key loaded: ${googleMapsApiKey.take(10)}...")
        } else {
            println("❌ WARNING: GOOGLE_MAPS_API_KEY not found in .env file!")
            println("   Please ensure GOOGLE_MAPS_API_KEY is set in .env or gradle.properties")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            storeFile = file(keystoreProperties["storeFile"] as String? ?: "")
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
            
            if (keystoreProperties.isNotEmpty()) {
                println("✅ Release signing configured")
            } else {
                println("⚠️ Signing config not found, using debug keys")
            }
        }
    }

    buildTypes {
        release {
            // Use release signing for Play Store
            signingConfig = signingConfigs.getByName("release")
            
            // Enable ProGuard/R8
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
