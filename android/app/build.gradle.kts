    plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Plugin de Firebase Google Services
    }

    android {
    namespace = "com.example.maquetaappwellq"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.app_wellq"
        minSdk = 26
        targetSdk = 34
        multiDexEnabled = true
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

    flutter {
    source = "../.."
}

    dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("com.google.firebase:firebase-analytics-ktx:21.3.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.1.0")
    implementation("com.google.firebase:firebase-firestore-ktx:24.6.0")
    }

    apply(plugin = "com.google.gms.google-services")