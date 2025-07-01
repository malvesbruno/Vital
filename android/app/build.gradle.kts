import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Carrega as propriedades do keystore
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("keys.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
} else {
    throw GradleException("Arquivo keys.properties não encontrado.")
}

android {
    namespace = "com.malves.vital"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.malves.vital"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = 8
        versionName = "1.1.6"
    }

    signingConfigs {
        create("release") {
            val path = keystoreProperties["storeFile"] as String?
                ?: throw GradleException("Missing 'storeFile' in keys.properties")

            storeFile = file(path)
            storePassword = keystoreProperties["storePassword"] as String?
                ?: throw GradleException("Missing 'storePassword' in keys.properties")
            keyAlias = keystoreProperties["keyAlias"] as String?
                ?: throw GradleException("Missing 'keyAlias' in keys.properties")
            keyPassword = keystoreProperties["keyPassword"] as String?
                ?: throw GradleException("Missing 'keyPassword' in keys.properties")
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation(platform("com.google.firebase:firebase-bom:33.14.0"))
    implementation("com.android.billingclient:billing:6.1.0")
}

flutter {
    source = "../.."
}
