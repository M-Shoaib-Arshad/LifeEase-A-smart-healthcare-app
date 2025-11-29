plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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

        // IMPORTANT: Raise minSdk to satisfy Firebase Auth (requires 23)
        minSdk = 23

        // Keep Flutter’s target/versions
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Build only the emulator ABI for faster builds
        ndk {
            abiFilters += listOf("x86_64")
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

    buildTypes {
        release {
            // TODO: Replace with your release signing config
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}