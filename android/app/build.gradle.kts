import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for release signing
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.shoaib.lifeease"

    // Flutter-managed SDK levels
    compileSdk = flutter.compileSdkVersion

    // Pin the NDK required by your native plugins
    ndkVersion = "27.0.12077973"

    // Use Java 17 (required by modern AGP/Flutter)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.shoaib.lifeease"

        // Support Android 8+ (API 26) for wider device compatibility
        minSdk = 26

        // Target Android 14 (API 34) for Play Store compliance
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Support all Android device architectures (ARM for physical devices)
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        }

        // Google Maps API key placeholder for manifest
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = project.findProperty("GOOGLE_MAPS_API_KEY") ?: "YOUR_GOOGLE_MAPS_API_KEY"
    }

    // Ensure C++ runtime is packaged (needed by some native plugins)
    packaging {
        jniLibs {
            pickFirsts += listOf("**/libc++_shared.so")
        }
    }

    // Signing configurations
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use debug signing for now (create keystore later for production)
            // Once you create keystore, change this to check keystorePropertiesFile.exists()
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable minification to avoid R8 issues (APK will be larger but stable)
            // Re-enable once you're ready to optimize for Play Store
            isMinifyEnabled = false
            isShrinkResources = false
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }
}

flutter {
    source = "../.."
}