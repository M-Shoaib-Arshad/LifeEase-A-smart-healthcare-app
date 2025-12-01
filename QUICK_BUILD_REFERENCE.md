# 🚀 Quick Build Commands

## First Time Setup (Do Once)
```powershell
# 1. Create keystore
cd android
New-Item -ItemType Directory -Force -Path keystore
keytool -genkey -v -keystore keystore\lifeease-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lifeease

# 2. Configure signing
Copy-Item key.properties.template key.properties
# Edit key.properties with your passwords

# 3. Add to .gitignore
# Add these lines:
# android/key.properties
# android/keystore/
```

## Build & Install (Every Time)
```powershell
# Clean build (recommended)
flutter clean
flutter pub get
flutter build apk --release

# Install on connected device
flutter install

# Or copy APK from:
# build/app/outputs/flutter-apk/app-release.apk
```

## Build Smaller APKs (Recommended)
```powershell
flutter build apk --release --split-per-abi
```

## For Play Store
```powershell
flutter build appbundle --release
```

---

## ⚠️ Common Issues & Quick Fixes

| Issue | Solution |
|-------|----------|
| "App not installed" | Create keystore first! See APK_BUILD_GUIDE.md Step 1 |
| Crashes on launch | Check Firebase config & google-services.json |
| Large APK size | Use `--split-per-abi` flag |
| Permission errors | Already fixed in AndroidManifest.xml |

---

## 📱 Your APK Location
After build: `build/app/outputs/flutter-apk/app-release.apk`

## 🔐 Keystore Location
After creation: `android/keystore/lifeease-release-key.jks`

**BACKUP YOUR KEYSTORE!** You can't update the app without it.
