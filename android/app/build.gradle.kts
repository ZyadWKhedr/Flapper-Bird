import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.flapperbird"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // Load signing properties if present
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.flapperbird"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias", "key0")
            keyPassword = keystoreProperties.getProperty("keyPassword", "")
            // Resolve storeFile: first try relative to module (android/app), then relative to android/ (keystoreProperties file parent)
            val configuredStoreFile = keystoreProperties.getProperty("storeFile", "key.jks")
            var resolvedStoreFile = file(configuredStoreFile)
            if (!resolvedStoreFile.exists()) {
                // try relative to the android/ folder (where key.properties usually lives)
                val parentDir = keystorePropertiesFile.parentFile
                resolvedStoreFile = parentDir?.let { File(it, configuredStoreFile) } ?: resolvedStoreFile
            }
            storeFile = resolvedStoreFile
            storePassword = keystoreProperties.getProperty("storePassword", "")
        }
    }

    buildTypes {
        release {
            // Use release signing config if provided in key.properties, otherwise fall back to debug
            signingConfig = try {
                signingConfigs.getByName("release")
            } catch (e: Exception) {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
