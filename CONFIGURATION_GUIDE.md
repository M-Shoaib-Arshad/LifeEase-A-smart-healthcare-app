# LifeEase Configuration Guide

## Complete Step-by-Step Setup Instructions

This guide will help you configure all the services needed to run the LifeEase healthcare application.

---

## 📋 Prerequisites

Before starting, ensure you have:
- ✅ Flutter SDK installed (3.0+)
- ✅ Android Studio or Xcode installed
- ✅ Firebase account created
- ✅ Node.js and npm installed (for Firebase CLI)
- ✅ Git installed

---

## 🚀 Quick Start (TL;DR)

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure Firebase
firebase login
flutterfire configure

# 3. Set up environment variables
cp .env.example .env
# Edit .env with your API keys

# 4. Run the app
flutter run
```

---

## 📱 Part 1: Firebase Configuration

Firebase is already partially configured in your app. Here's what you need to do:

### Step 1.1: Verify Firebase Project

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Open your project**: `lifeease-smart-healthcare`
3. **Verify Project ID**: Should be `lifeease-smart-healthcare`

✅ **Status**: Firebase project files are already in place:
- `android/app/google-services.json` ✅
- `lib/firebase_options.dart` ✅

### Step 1.2: Enable Firebase Authentication

1. **Navigate to**: Firebase Console → Authentication → Sign-in method
2. **Enable the following providers**:

#### Email/Password (Required) ✅
- Click "Email/Password"
- Toggle "Enable"
- Save

#### Phone Authentication (For OTP Verification)
- Click "Phone"
- Toggle "Enable"  
- Add test phone numbers for development:
  - Phone: `+1 555-555-1234`, Code: `123456`
  - Phone: `+92 300 1234567`, Code: `123456`
- Save

#### Google Sign-In (Optional)
- Click "Google"
- Toggle "Enable"
- Select project support email
- Save

### Step 1.3: Set Up Firestore Database

1. **Navigate to**: Firebase Console → Firestore Database
2. **If not created**, click "Create Database"
3. **Select mode**:
   - **Test Mode** for development (allows all reads/writes for 30 days)
   - **Production Mode** for production (with proper security rules)
4. **Choose location**: `us-central1` or closest to your users
5. **Click "Enable"**

### Step 1.4: Deploy Firestore Security Rules

The app needs proper security rules to protect user data.

**Option A: Using Firebase Console**
1. Go to Firestore Database → Rules tab
2. Copy the rules from `FIREBASE_SETUP.md` (Production Rules section)
3. Paste and publish

**Option B: Using Firebase CLI (Recommended)**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init firestore

# Deploy rules (rules are in firebase.json)
firebase deploy --only firestore:rules
```

### Step 1.5: Set Up Firebase Storage

1. **Navigate to**: Firebase Console → Storage
2. **Click "Get Started"**
3. **Select security mode**: Test mode for now
4. **Choose location**: Same as Firestore
5. **Click "Done"**

**Deploy Storage Security Rules**:
```bash
firebase deploy --only storage
```

### Step 1.6: Enable Cloud Messaging (For Push Notifications)

1. **Navigate to**: Firebase Console → Project Settings → Cloud Messaging
2. **Verify FCM is enabled**
3. **For Android**: Already configured via `google-services.json`
4. **For iOS**: 
   - Upload APNs certificate (requires Apple Developer account)
   - See FIREBASE_SETUP.md for detailed iOS setup

---

## 🎥 Part 2: Agora Configuration (Video Calls)

LifeEase uses Agora for telemedicine video consultations.

### Step 2.1: Create Agora Account

1. **Visit**: https://www.agora.io/
2. **Sign up** for free account
3. **Verify your email**

### Step 2.2: Create Agora Project

1. **Log in** to Agora Console: https://console.agora.io/
2. **Click "Projects"** in left sidebar
3. **Click "Create"** button
4. **Fill in project details**:
   - Project Name: `LifeEase Healthcare`
   - Use Case: `Social` or `Healthcare`
   - Authentication: Select "APP ID + Token (Recommended)"
5. **Click "Submit"**

### Step 2.3: Get Agora App ID

1. **Find your project** in the Projects list
2. **Copy the App ID** (it looks like: `a1b2c3d4e5f6g7h8i9j0`)
3. **Keep it safe** - you'll need it in the next step

### Step 2.4: Configure Agora in App

You need to add your Agora App ID to the app configuration.

**Create environment file**:
```bash
# Create .env file in project root
touch .env
```

**Add to `.env`**:
```env
# Agora Configuration
AGORA_APP_ID=your_actual_app_id_here

# Optional: Agora Token Server (for production)
AGORA_TOKEN_SERVER_URL=https://your-backend.com/agora/token
```

**Update `.gitignore`** to protect secrets:
```bash
# Add to .gitignore if not already there
.env
*.env
```

### Step 2.5: Update Agora Service

Edit `lib/services/telemedicine_service.dart`:

**Before** (line 14):
```dart
static const String appId = 'YOUR_AGORA_APP_ID';
```

**After**:
```dart
static const String appId = String.fromEnvironment(
  'AGORA_APP_ID',
  defaultValue: 'YOUR_AGORA_APP_ID', // Fallback for development
);
```

### Step 2.6: Load Environment Variables

Install the flutter_dotenv package:

```bash
flutter pub add flutter_dotenv
```

Update `pubspec.yaml` to include .env:
```yaml
flutter:
  assets:
    - assets/
    - .env  # Add this line
```

Update `lib/main.dart` to load environment:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

Update `lib/services/telemedicine_service.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TelemedicineService {
  // Get App ID from environment
  static String get appId => dotenv.env['AGORA_APP_ID'] ?? 'YOUR_AGORA_APP_ID';
  
  // ... rest of the code
}
```

### Step 2.7: Test Agora Integration

Run this test to verify Agora is working:

```dart
// In a test screen or during app initialization
final telemedicineService = TelemedicineService();
await telemedicineService.initialize();
print('Agora initialized: ${telemedicineService.isInitialized}');
```

---

## 🔐 Part 3: Environment Variables & Security

### Step 3.1: Create Environment File

Create `.env` file in project root:

```env
# Firebase Configuration (Already in firebase_options.dart)
# These are for reference only, actual config is in firebase_options.dart

# Agora Configuration (Required for video calls)
AGORA_APP_ID=your_agora_app_id_here

# Optional: Backend API
API_BASE_URL=https://your-backend-api.com

# Optional: AI/ML Service
OPENAI_API_KEY=your_openai_key_here
GEMINI_API_KEY=your_gemini_key_here

# Environment
ENVIRONMENT=development
```

### Step 3.2: Secure Your Keys

1. **Never commit `.env` to Git**
```bash
# Verify .env is in .gitignore
cat .gitignore | grep .env
```

2. **Create `.env.example`** (safe to commit):
```env
# Agora Configuration
AGORA_APP_ID=your_agora_app_id_here

# Optional: Backend API
API_BASE_URL=https://your-backend-api.com

# Optional: AI Service
OPENAI_API_KEY=your_openai_key_here
```

3. **Document in README**:
```markdown
## Setup
1. Copy `.env.example` to `.env`
2. Fill in your actual API keys
3. Never commit `.env` to version control
```

---

## 📊 Part 4: Additional Services (Optional)

### 4.1: OpenAI/AI Service Configuration

If you want to use AI health recommendations:

1. **Get OpenAI API Key**: https://platform.openai.com/api-keys
2. **Add to `.env`**:
```env
OPENAI_API_KEY=sk-...your-key-here
```

3. **Update `lib/services/ai_service.dart`**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  // ... rest of the code
}
```

### 4.2: Google Sign-In Configuration

For Google authentication:

1. **Get OAuth Client ID** from Firebase Console
2. **Add to Android** (`android/app/build.gradle`):
```gradle
defaultConfig {
    resValue "string", "default_web_client_id", "YOUR_CLIENT_ID"
}
```

3. **Add to iOS** (`ios/Runner/Info.plist`):
```xml
<key>GIDClientID</key>
<string>YOUR_CLIENT_ID</string>
```

---

## 🧪 Part 5: Testing Configuration

### Step 5.1: Test Firebase Connection

Run this test in your app:

```dart
// Test Authentication
try {
  final auth = FirebaseAuth.instance;
  print('✅ Firebase Auth: Connected');
} catch (e) {
  print('❌ Firebase Auth: Failed - $e');
}

// Test Firestore
try {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('test').doc('test').set({'test': true});
  print('✅ Firestore: Connected');
} catch (e) {
  print('❌ Firestore: Failed - $e');
}

// Test Storage
try {
  final storage = FirebaseStorage.instance;
  print('✅ Firebase Storage: Connected');
} catch (e) {
  print('❌ Firebase Storage: Failed - $e');
}
```

### Step 5.2: Test Agora Connection

```dart
try {
  final telemedicine = TelemedicineService();
  await telemedicine.initialize();
  if (telemedicine.isInitialized) {
    print('✅ Agora: Initialized');
  } else {
    print('⚠️ Agora: Not initialized');
  }
} catch (e) {
  print('❌ Agora: Failed - $e');
}
```

### Step 5.3: Run Complete Test

Create a debug screen to test all services:

```dart
class ConfigTestScreen extends StatefulWidget {
  @override
  _ConfigTestScreenState createState() => _ConfigTestScreenState();
}

class _ConfigTestScreenState extends State<ConfigTestScreen> {
  Map<String, bool> testResults = {};

  Future<void> runTests() async {
    // Test Firebase Auth
    try {
      await FirebaseAuth.instance.signInAnonymously();
      testResults['Firebase Auth'] = true;
    } catch (e) {
      testResults['Firebase Auth'] = false;
    }

    // Test Firestore
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('test')
          .set({'timestamp': DateTime.now()});
      testResults['Firestore'] = true;
    } catch (e) {
      testResults['Firestore'] = false;
    }

    // Test Agora
    try {
      final service = TelemedicineService();
      await service.initialize();
      testResults['Agora'] = service.isInitialized;
    } catch (e) {
      testResults['Agora'] = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuration Test')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: runTests,
            child: Text('Run Tests'),
          ),
          ...testResults.entries.map((e) => ListTile(
            title: Text(e.key),
            trailing: Icon(
              e.value ? Icons.check_circle : Icons.error,
              color: e.value ? Colors.green : Colors.red,
            ),
          )),
        ],
      ),
    );
  }
}
```

---

## 🔧 Part 6: Platform-Specific Configuration

### Android Configuration

#### Step 6.1: Update AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

Add permissions:
```xml
<manifest>
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <!-- Required for Agora -->
    <uses-feature android:name="android.hardware.camera"/>
    <uses-feature android:name="android.hardware.camera.autofocus"/>
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

#### Step 6.2: Update build.gradle

File: `android/build.gradle`

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

File: `android/app/build.gradle`

```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 34
    }
}
```

### iOS Configuration

#### Step 6.3: Update Info.plist

File: `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access for video consultations</string>
    
    <!-- Microphone Permission -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access for video consultations</string>
    
    <!-- Photo Library Permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo access to upload medical documents</string>
</dict>
```

#### Step 6.4: Update Podfile

File: `ios/Podfile`

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

Run:
```bash
cd ios
pod install
cd ..
```

---

## ✅ Part 7: Verification Checklist

Use this checklist to verify everything is configured correctly:

### Firebase Setup
- [ ] Firebase project created
- [ ] `google-services.json` in `android/app/`
- [ ] `GoogleService-Info.plist` in `ios/Runner/`
- [ ] `firebase_options.dart` generated
- [ ] Email/Password authentication enabled
- [ ] Phone authentication enabled (optional)
- [ ] Firestore database created
- [ ] Firestore security rules deployed
- [ ] Firebase Storage enabled
- [ ] Storage security rules deployed
- [ ] Cloud Messaging enabled

### Agora Setup
- [ ] Agora account created
- [ ] Agora project created
- [ ] App ID obtained
- [ ] App ID added to `.env` file
- [ ] `flutter_dotenv` package installed
- [ ] Environment loading in `main.dart`
- [ ] Agora service updated to use environment

### Environment Configuration
- [ ] `.env` file created
- [ ] `.env` added to `.gitignore`
- [ ] `.env.example` created for reference
- [ ] All API keys added to `.env`

### Platform Configuration
- [ ] Android permissions in `AndroidManifest.xml`
- [ ] Android `build.gradle` configured
- [ ] iOS permissions in `Info.plist`
- [ ] iOS Podfile configured
- [ ] Pod dependencies installed

### Testing
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] App builds successfully
- [ ] Firebase connection tested
- [ ] Agora initialization tested
- [ ] All permissions work on device

---

## 🚀 Running the App

### Development Mode

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# iOS: Install pods
cd ios && pod install && cd ..

# Run on connected device
flutter run

# Or run with flavor
flutter run --dart-define=ENVIRONMENT=development
```

### Production Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac and Xcode)
flutter build ios --release
```

---

## 🐛 Troubleshooting

### Issue: Firebase not initialized
**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**:
```bash
flutterfire configure
flutter clean
flutter pub get
flutter run
```

### Issue: Agora not working
**Error**: `Agora App ID is invalid`

**Solutions**:
1. Verify App ID in `.env` is correct
2. Ensure `.env` is loaded in `main.dart`
3. Check Agora Console project is active
4. Verify `flutter_dotenv` is installed

### Issue: Permission denied on device
**Error**: Camera/Microphone not accessible

**Solutions**:
1. Check AndroidManifest.xml permissions
2. Check Info.plist permissions
3. Request runtime permissions in code
4. Test on real device (not emulator)

### Issue: Build fails on iOS
**Error**: Pod install failed

**Solutions**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter run
```

### Issue: Firestore permission denied
**Error**: `Missing or insufficient permissions`

**Solutions**:
1. Check Firestore security rules
2. Verify user is authenticated
3. Check user role in Firestore
4. Test with emulator (no rules)

---

## 📚 Next Steps

After configuration:

1. **Test all features**:
   - Sign up new user
   - Login existing user
   - Book appointment
   - Start video call
   - Upload health data

2. **Set up development workflow**:
   - Use Firebase Emulator for local testing
   - Set up CI/CD pipeline
   - Configure staging environment

3. **Production preparation**:
   - Switch to production security rules
   - Enable monitoring and analytics
   - Set up crash reporting
   - Configure backup strategy

---

## 📞 Support

If you encounter issues:

1. **Check documentation**:
   - `FIREBASE_SETUP.md` - Detailed Firebase guide
   - `DEVELOPER_QUICK_START.md` - Development guide
   - `PR_ORGANIZATION_PLAN.md` - Project structure

2. **Common resources**:
   - [Firebase Documentation](https://firebase.google.com/docs)
   - [Agora Documentation](https://docs.agora.io/)
   - [Flutter Documentation](https://docs.flutter.dev/)

3. **Get help**:
   - GitHub Issues
   - Stack Overflow
   - Firebase Support
   - Agora Support

---

## ✨ You're All Set!

Your LifeEase app is now fully configured and ready to use. Run `flutter run` to start the app!

**Key files to remember**:
- `.env` - Your API keys (never commit!)
- `firebase_options.dart` - Firebase config
- `lib/services/telemedicine_service.dart` - Agora config
- `lib/main.dart` - App initialization

Happy coding! 🚀
