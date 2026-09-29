plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.yourwish.shougakukore.shinshin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ========================================
    // リリース署名設定
    // GitHub Actions では環境変数から、ローカルビルドでは key.properties から読み込み
    // ========================================
    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = java.util.Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH")
                ?: keystoreProperties["storeFile"]?.let { file(it.toString()).absolutePath }
                ?: file("${System.getProperty("user.home")}/.shougaku-kore-release.jks").absolutePath

            storeFile = file(keystorePath)
            storePassword = System.getenv("KEYSTORE_PASSWORD")
                ?: keystoreProperties["storePassword"] as String? ?: ""
            keyAlias = System.getenv("KEYSTORE_ALIAS")
                ?: keystoreProperties["keyAlias"] as String? ?: "shougaku-kore-key"
            keyPassword = System.getenv("KEYSTORE_KEY_PASSWORD")
                ?: keystoreProperties["keyPassword"] as String? ?: ""

            storeType = "jks"
        }
    }

    defaultConfig {
        // アプリケーション ID
        applicationId = "com.yourwish.shougakukore.shinshin"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true

        // Flutter v2 embedding
        // Required for compatibility with modern Flutter plugins
        manifestPlaceholders += mapOf(
            "flutterEmbedding" to "2"
        )
    }

    buildTypes {
        // ========================================
        // Debug ビルド設定
        // ========================================
        debug {
            // デバッグビルドは既存のデバッグ署名を使用
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }

        // ========================================
        // Release ビルド設定
        // ========================================
        release {
            // リリースビルドはリリース署名を使用
            // 本番環境に公開するビルドには必須
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true

            // ProGuard/R8 ルールファイル
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
