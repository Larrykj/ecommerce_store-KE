# Signing Instructions — E-Commerce KE Android App

## Overview
A release keystore is required to sign your APK/AAB for uploading to the Google Play Store.
**Keep this keystore file and passwords in a safe place forever** — if you lose it, you cannot update your app on Play Store.

## Step 1: Generate the Release Keystore

Open a terminal (Command Prompt or PowerShell) and run:

```powershell
keytool -genkey -v `
  -keystore android/app/ecommerce-ke-release.jks `
  -alias ecommerce_ke `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000
```

You will be prompted to enter:
- **Keystore password** (choose a strong password and save it securely)
- **Key password** (can be the same as keystore password)
- **Your name, organization, city, state, country** (for certificate)

## Step 2: Create key.properties

Create the file `android/key.properties` (already gitignored) with:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=ecommerce_ke
storeFile=ecommerce-ke-release.jks
```

> **Important:** Never commit `key.properties` or `*.jks` to git. They are already in `.gitignore`.

## Step 3: Build the Release App Bundle (AAB)

```powershell
cd c:\Users\HomePC\Desktop\E-Commerce-Rails\ecommerce_android_wrapper
flutter build appbundle --release
```

The output will be at:
`build/app/outputs/bundle/release/app-release.aab`

## Step 4: Build a Release APK (optional, for direct install testing)

```powershell
flutter build apk --release --split-per-abi
```

## Step 5: Upload to Google Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app → "E-Commerce KE"
3. Go to **Release** → **Internal testing** → Create new release
4. Upload the `app-release.aab` file
5. Run the **Pre-launch Report** to catch device compatibility issues
6. Fill in the store listing:
   - Short description: "Shop smarter with E-Commerce KE"
   - Full description: (paste from README.md)
   - Screenshots: at least 2 phone screenshots
   - Feature graphic: 1024×500 banner
   - Privacy Policy URL: `https://ecommerce-rails-app.onrender.com/privacy` (needs to be created in Rails app)
   - App category: Shopping
   - Content rating: Everyone
