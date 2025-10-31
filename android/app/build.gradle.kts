plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase Google Services (solo aquí, no al final)
}

android {
    namespace = "com.example.app_wellq"

    // Usa un compileSdk soportado por tu AGP. 34 es seguro.
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.app_wellq"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Define signing antes de usarla en buildTypes
    signingConfigs {
        // Si no tienes keystore de release todavía, dejamos debug disponible
        getByName("debug")
        create("release") {
            // Cuando tengas tu keystore, descomenta y completa:
            // storeFile = file("keystore.jks")
            // storePassword = "xxxx"
            // keyAlias = "xxxx"
            // keyPassword = "xxxx"
        }
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            // TEMPORAL: firmar con debug para poder generar el APK
            // (cambia a signingConfigs.getByName("release") cuando tengas tu keystore)
            signingConfig = signingConfigs.getByName("debug")

            // Deja shrink apagado mientras depuramos los crashes de runtime
            isMinifyEnabled = false
            isShrinkResources = false

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.health.connect:connect-client:1.1.0-alpha10")
    // Si usas SDKs nativos de Firebase además de los plugins Flutter, puedes dejar estos:
    // (si no los necesitas explícitamente, puedes comentarlos para evitar duplicados)
    implementation("com.google.firebase:firebase-analytics-ktx:21.3.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.1.0")
    implementation("com.google.firebase:firebase-firestore-ktx:24.6.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.work:work-runtime-ktx:2.9.1")
}

// No pongas: apply(plugin = "com.google.gms.google-services") aquí abajo.
// En Kotlin DSL ya lo declaramos en `plugins { ... }` arriba.
