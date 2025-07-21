plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.example.com"
    compileSdk = flutter.compileSdkVersion
    // Use your existing NDK version instead of requiring a new one
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    signingConfigs {
        create("release") {
            storeFile = file("upload-keystore.jks")
            storePassword = "ak9oO)xYEh2M"
            keyAlias = "upload"
            keyPassword = "ak9oO)xYEh2M"
        }
    }
    
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.example.com"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    buildTypes {
        release {
            // Apply the signing configuration
            signingConfig = signingConfigs.getByName("release")
            
            // Enable minification and resource shrinking
            isMinifyEnabled = true
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

dependencies {
    // Add core library desugaring dependency for Java 8+ features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.3")
}