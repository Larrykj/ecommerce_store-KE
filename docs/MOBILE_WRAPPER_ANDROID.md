# Android Wrapper Stabilization Notes

## What was changed

- `android/settings.gradle.kts`
  - Android Gradle Plugin: `8.7.3`
  - Kotlin Android Plugin: `2.0.21`
- `android/gradle/wrapper/gradle-wrapper.properties`
  - Gradle wrapper pinned to `8.10.2`

These versions are selected for stable Flutter/Android compatibility and to avoid bleeding-edge tooling mismatch.

## Build Steps (from `ecommerce_android_wrapper`)

```powershell
flutter clean
flutter pub get
flutter doctor
flutter build apk --release
```

## If build still fails

1. Confirm Android SDK platform for your target SDK is installed.
2. Confirm command-line tools are up-to-date in Android Studio SDK Manager.
3. Run:

```powershell
flutter doctor -v
```

4. If you still see a Gradle phased action failure, share full stacktrace with:

```powershell
cd android
.\gradlew.bat assembleRelease --stacktrace --info
```

## Packaging

- Release signing config in `android/app/build.gradle.kts` uses `key.properties` when present.
- If missing, it falls back to debug signing for local testing.
