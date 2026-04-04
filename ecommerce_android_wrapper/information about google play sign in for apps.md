# 🚀 Android App Release & Publishing Guide

Since the application is securely pointing to your Rails backend, you are ready to compile.

## Step 1: Create a Keystore (For Code Signing)
Google requires all apps to be digitally signed before they accept them into the Play Store.

1. Open your terminal natively in Windows and run the following command to generate a new signing key:
   ```powershell
   keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ecommerce-key
   ```
2. You will be prompted to create a password and enter some information (Name, Organization, Country code). Remember the password!
3. Move the generated `release-key.jks` file into the `ecommerce_android_wrapper/android/app/` folder.

## Step 2: Configure `key.properties`
Flutter needs to know how to unlock that keystore during the build.

1. Navigate to the `ecommerce_android_wrapper/android` folder.
2. Create a new file called `key.properties`.
3. Add the following text to `key.properties` (replace the passwords with what you set in Step 1):
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEYSTORE_PASSWORD
   keyAlias=ecommerce-key
   storeFile=release-key.jks
   ```
*(Note: Don't commit this `key.properties` file or the `.jks` file to a public GitHub repository. Keep it locally safe!)*

## Step 3: Tell Gradle to Use Your Key
1. Open `ecommerce_android_wrapper/android/app/build.gradle`.
2. Find the `android {` block, and BEFORE the `buildTypes {` section, add the following text:

   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       // ... existing code ...

       signingConfigs {
           release {
               keyAlias = keystoreProperties['keyAlias']
               keyPassword = keystoreProperties['keyPassword']
               storeFile = keystorePropertiesFile.exists() ? file(keystoreProperties['storeFile']) : null
               storePassword = keystoreProperties['storePassword']
           }
       }

       buildTypes {
           release {
               signingConfig signingConfigs.release // <-- note this change
               minifyEnabled true
               shrinkResources true
           }
       }
   }
   ```

## Step 4: Finalize Your App Version
To tell Google Play that this is a new version:
1. Open `ecommerce_android_wrapper/pubspec.yaml`
2. At the top, locate the `version:` syntax.
3. Change it to: `version: 1.0.0+1` 
*(1.0.0 is your display version, the `+1` is the hidden build number. Every time you update the app on the Play Console later to push a new feature, you must manually increase this to `+2`, `+3`, etc. before building!)*

## Step 5: Build the Live Package 
It's time to compile everything! Open your terminal, navigate to the flutter app folder, and run:

### For Google Play Store submission (AAB Recommended):
```powershell
cd c:\Users\HomePC\Desktop\E-Commerce-Rails\ecommerce_android_wrapper
flutter build appbundle --release
```
**Output Location:** `build/app/outputs/bundle/release/app-release.aab`
*(Upload this exact `.aab` file directly into your Google Play Developer Console Release Track).*

### If you want a Direct Download File for testing on physical devices natively (APK):
```powershell
flutter build apk --release
```
**Output Location:** `build/app/outputs/flutter-apk/app-release.apk`
*(You can share this `.apk` to yourself right now to install it straight onto your Android Phone!).*

---
> **Important Final Check:** The app is configured with `https://ecommerce-rails-app.onrender.com`. Ensure your Rails app backend is actively deployed and running flawlessly at that exact URL before you submit it to the Play Store, or Google reviewers will see a blank connection error!
