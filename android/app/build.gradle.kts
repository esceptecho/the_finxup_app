plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.the_finxup_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // Corregido: Usando compilerOptions para evitar el aviso de "deprecated"
    kotlinOptions {
        jvmTarget = "17" 
    }

    defaultConfig {
        applicationId = "com.example.the_finxup_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ESTE ES EL BLOQUE CORREGIDO PARA KOTLIN (.kts)
subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val androidExtension = project.extensions.getByName("android")
            if (androidExtension is com.android.build.gradle.BaseExtension) {
                if (androidExtension.namespace == null) {
                    androidExtension.namespace = project.group.toString()
                }
            }
        }
    }
}

flutter {
    source = "../.."
}