plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.unlock.demo_unlock"
    compileSdk = 36
    ndkVersion="30.0.14904198"
    buildToolsVersion = "35.0.0"  // ← thêm dòng này

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.unlock.demo_unlock"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

// Apple Silicon: some Android NDK installs only ship x86_64 host `llvm-strip`.
// Without Rosetta, `:app:stripReleaseDebugSymbols` fails and Flutter reports
// "Release app bundle failed to strip debug symbols from native libraries."
// Prefer: install Rosetta (`softwareupdate --install-rosetta --agree-to-license`)
// or an NDK with darwin-arm64 host tools. Disabling strip is a build fallback.

