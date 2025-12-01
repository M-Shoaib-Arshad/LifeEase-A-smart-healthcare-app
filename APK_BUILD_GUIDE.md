# APK Build & Release Configuration Guide

## ✅ Issues Fixed (November 12, 2025)

All critical issues preventing APK installation on Android 13+ have been resolved:

1. ✅ **ABI Architecture Support** - Added ARM support for physical devices
2. ✅ **Android Permissions** - Added all required permissions for app features
3. ✅ **Release Signing Configuration** - Set up proper keystore signing
4. ✅ **Target SDK Update** - Updated to Android 14 (API 34)
5. ✅ **ProGuard Rules** - Added obfuscation rules for Firebase, Agora, etc.

---

## 🔐 Step 1: Create Release Keystore (REQUIRED)

Before building a release APK, you MUST create a signing keystore:

### Windows (PowerShell):
```powershell
# Navigate to android directory
cd "c:\Flutter projects\LifeEase-A-smart-healthcare-app\android"

# Create keystore directory
New-Item -ItemType Directory -Force -Path keystore

# Generate keystore (requires Java/JDK)
keytool -genkey -v -keystore keystore\lifeease-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lifeease
```

### You will be prompted for:
- **Keystore password**: Choose a strong password (remember this!)
- **Key password**: Choose a strong password (remember this!)
- **First and Last Name**: Your name or company name
- **Organizational Unit**: Your department/unit
- **Organization**: Your company name
- **City**: Your city
- **State**: Your state/province
- **Country Code**: Two-letter country code (e.g., PK for Pakistan)

⚠️ **CRITICAL**: Save these passwords securely! You'll need them for every release.

---

## 📝 Step 2: Configure Signing Properties

1. Copy the template file:
```powershell
cd android
Copy-Item key.properties.template key.properties
```

2. Edit `android/key.properties` and replace with YOUR values:
```properties
storePassword=YOUR_ACTUAL_KEYSTORE_PASSWORD
keyPassword=YOUR_ACTUAL_KEY_PASSWORD
keyAlias=lifeease
storeFile=../keystore/lifeease-release-key.jks
```

3. Add to `.gitignore` (SECURITY):
```
# In your .gitignore file, add:
android/key.properties
android/keystore/
```

⚠️ **NEVER commit `key.properties` or keystore files to Git!**

---

## 🏗️ Step 3: Build Release APK

### Clean build (recommended first time):
```powershell
flutter clean
flutter pub get
flutter build apk --release
```

### Build specific architectures:
```powershell
# Build for all architectures (larger file, compatible with all devices)
flutter build apk --release

# Build split APKs (smaller files, one per architecture)
flutter build apk --release --split-per-abi

# This creates:
# - app-armeabi-v7a-release.apk (32-bit ARM - older devices)
# - app-arm64-v8a-release.apk (64-bit ARM - modern devices)
# - app-x86_64-release.apk (emulator only)
```

### Your APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Step 4: Install on Android Device

### Method 1: Direct Install via USB
```powershell
# Enable USB debugging on your phone first!
flutter install
```

### Method 2: Manual Install
1. Copy `app-release.apk` to your phone
2. Open file on phone
3. Allow installation from unknown sources (if prompted)
4. Install

---

## 🎯 What Was Fixed

### 1. ABI Filter (CRITICAL FIX)
**Before:**
```kotlin
ndk {
    abiFilters += listOf("x86_64")  // Emulator only!
}
```

**After:**
```kotlin
ndk {
    abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")  // Real devices!
}
```

### 2. Permissions Added
- ✅ Internet & Network State (Firebase, Agora)
- ✅ Camera (Image Picker)
- ✅ Storage/Media (Android 13 compliant)
- ✅ Audio Recording (Agora video calls)
- ✅ Phone State (Phone authentication)
- ✅ Bluetooth (Audio routing)

### 3. Release Signing
- ✅ Proper keystore configuration
- ✅ Fallback to debug for development
- ✅ Code shrinking enabled
- ✅ ProGuard obfuscation

### 4. Target SDK
- ✅ Updated to API 34 (Android 14)
- ✅ Play Store compliant
- ✅ Better compatibility

---

## 🔍 Troubleshooting

### Error: "App not installed"
**Solution:** 
- Make sure you created the keystore (Step 1)
- Check that `key.properties` exists with correct values
- Uninstall any existing debug version first

### Error: "Installation blocked"
**Solution:**
- Enable "Install from unknown sources" in Settings
- Check Android security settings
- Try: Settings → Security → Install unknown apps → Your File Manager → Allow

### Error: "App crashes on launch"
**Solution:**
- Check if Firebase is properly configured
- Ensure `google-services.json` is present
- Check `firebase_options.dart` exists

### Error: "Permission denied"
**Solution:**
- Permissions are now in AndroidManifest.xml
- Request runtime permissions in-app for Camera, Storage, etc.

---

## 📦 Play Store Preparation

When ready to publish:

1. **Build App Bundle (recommended for Play Store):**
```powershell
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

2. **Update version in `pubspec.yaml`:**
```yaml
version: 1.0.1+2  # Format: version+buildNumber
```

3. **Test thoroughly:**
- Install on multiple devices
- Test all features (camera, storage, calls)
- Check Firebase integration
- Verify Agora video calls work

---

## 📋 Pre-Release Checklist

- [ ] Keystore created and passwords saved securely
- [ ] `key.properties` configured (NOT in Git)
- [ ] All permissions tested on real device
- [ ] Firebase authentication works
- [ ] Agora video calls functional
- [ ] Image picker works (camera & gallery)
- [ ] App icon and name correct
- [ ] Version number updated in pubspec.yaml
- [ ] Tested on Android 13+ device
- [ ] Tested both debug and release builds

---

## 🆘 Need Help?

If you encounter issues:

1. **Check build logs:**
```powershell
flutter build apk --release --verbose
```

2. **Check device logs:**
```powershell
flutter logs
```

3. **Clean and rebuild:**
```powershell
flutter clean
rm -r android/app/build
flutter pub get
flutter build apk --release
```

---

## 📝 Important Notes

- **Debug builds** will still use debug signing (for development)
- **Release builds** will use your keystore (for production)
- **Split APKs** reduce file size but require multiple uploads
- **App Bundle (AAB)** is required for Play Store (Google's format)
- **Backup your keystore** - you can't publish updates without it!

---

**Last Updated:** November 12, 2025
**Status:** ✅ Ready for Production Builds
