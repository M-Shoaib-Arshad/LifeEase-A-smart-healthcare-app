# LifeEase - Developer Quick Start Guide

## Project Overview

**LifeEase** is a comprehensive smart healthcare application built with Flutter that connects patients with healthcare providers. The app features role-based access for patients, doctors, and administrators, with a focus on appointment management, health tracking, and telemedicine capabilities.

## Technology Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider
- **Routing**: go_router
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Real-time Communication**: Agora RTC (for video calls)
- **Charts**: Syncfusion Flutter Charts
- **Local Storage**: SharedPreferences, Flutter Secure Storage

## Project Structure

```
lib/
├── config/              # App configuration
│   └── app_config.dart
├── models/              # Data models
│   ├── user.dart
│   ├── appointment.dart
│   ├── health_record.dart
│   ├── health_data.dart
│   ├── notification.dart
│   └── ai_recommendation.dart
├── providers/           # State management
│   ├── user_provider.dart
│   ├── appointment_provider.dart
│   └── health_record_provider.dart
├── routes/              # Navigation configuration
│   └── app_routes.dart
├── screens/             # UI screens
│   ├── auth/            # Authentication screens (5 files)
│   ├── patient/         # Patient screens (14 files)
│   ├── doctor/          # Doctor screens (6 files)
│   ├── admin/           # Admin screens (3 files)
│   └── common/          # Shared screens (2 files)
├── services/            # Business logic & API
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── api_service.dart
│   └── storage_service.dart
├── utils/               # Utilities
│   ├── constants.dart
│   └── theme.dart
├── widgets/             # Reusable widgets
├── firebase_options.dart # Firebase configuration
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.0 or higher
   ```bash
   flutter --version
   ```

2. **Firebase CLI**: Install for Firebase configuration
   ```bash
   npm install -g firebase-tools
   ```

3. **IDE**: VS Code or Android Studio with Flutter plugin

4. **Devices**: iOS Simulator, Android Emulator, or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/M-Shoaib-Arshad/LifeEase-A-smart-healthcare-app.git
   cd LifeEase-A-smart-healthcare-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at https://console.firebase.google.com
   - Add Android and iOS apps to your Firebase project
   - Download and place configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Run FlutterFire CLI to generate `firebase_options.dart`:
     ```bash
     flutterfire configure
     ```

4. **Enable Firebase services** in Firebase Console:
   - Authentication (Email/Password, Phone, Google, Facebook)
   - Firestore Database
   - Firebase Storage
   - Cloud Functions (optional)

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Setup

### 1. Authentication
Enable these sign-in methods in Firebase Console → Authentication:
- ✅ Email/Password
- ⚪ Phone (for OTP verification)
- ⚪ Google (optional)
- ⚪ Facebook (optional)

### 2. Firestore Database
Create these collections:
- `users` - User profiles
- `appointments` - Appointment records
- `health_records` - Medical records
- `notifications` - User notifications
- `doctors` - Doctor profiles
- `prescriptions` - Medical prescriptions

### 3. Security Rules
Deploy Firestore security rules (see PR1_IMPLEMENTATION_GUIDE.md for details)

### 4. Firebase Storage
Create storage buckets for:
- User avatars: `/avatars/{userId}`
- Medical documents: `/medical_records/{userId}`
- Prescription images: `/prescriptions/{prescriptionId}`

## Development Workflow

### 1. Feature Development

Follow the PR organization plan (see `PR_ORGANIZATION_PLAN.md`):
- PR #1: Authentication ✅ (Completed)
- PR #2: Patient Screens
- PR #3: Doctor Screens
- PR #4: Admin Screens
- PR #5: Common Screens
- PR #6: Additional Services
- PR #7: Additional Providers
- PR #8: Enhanced Configuration
- PR #9: Testing & Documentation

### 2. Branch Strategy

```
main                    # Production-ready code
  ├── develop           # Development branch
  │   ├── feature/auth-screens
  │   ├── feature/patient-screens
  │   ├── feature/doctor-screens
  │   └── ...
```

### 3. Coding Standards

**File Naming**:
- Screens: `screen_name_screen.dart` (e.g., `login_screen.dart`)
- Services: `service_name_service.dart` (e.g., `auth_service.dart`)
- Providers: `name_provider.dart` (e.g., `user_provider.dart`)
- Models: `model_name.dart` (e.g., `user.dart`)

**Code Style**:
```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

### 4. Adding a New Screen

Example: Adding a new patient screen

1. **Create the screen file**:
   ```dart
   // lib/screens/patient/new_feature_screen.dart
   import 'package:flutter/material.dart';
   import 'package:provider/provider.dart';
   
   class NewFeatureScreen extends StatefulWidget {
     const NewFeatureScreen({super.key});
   
     @override
     State<NewFeatureScreen> createState() => _NewFeatureScreenState();
   }
   
   class _NewFeatureScreenState extends State<NewFeatureScreen> {
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('New Feature')),
         body: const Center(child: Text('Content here')),
       );
     }
   }
   ```

2. **Add route in `app_routes.dart`**:
   ```dart
   GoRoute(
     path: '/patient/new-feature',
     builder: (context, state) => const NewFeatureScreen(),
   ),
   ```

3. **Navigate to the screen**:
   ```dart
   context.go('/patient/new-feature');
   ```

### 5. Adding a New Service

Example: Adding a notification service

1. **Create service file**:
   ```dart
   // lib/services/notification_service.dart
   import 'package:firebase_messaging/firebase_messaging.dart';
   
   class NotificationService {
     final FirebaseMessaging _messaging = FirebaseMessaging.instance;
     
     Future<void> initialize() async {
       // Request permissions
       await _messaging.requestPermission();
       
       // Get FCM token
       String? token = await _messaging.getToken();
       print('FCM Token: $token');
     }
     
     Future<void> sendNotification(String userId, String message) async {
       // Implementation
     }
   }
   ```

2. **Use the service**:
   ```dart
   final notificationService = NotificationService();
   await notificationService.initialize();
   ```

## Common Tasks

### Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# All connected devices
flutter run -d all
```

### Building Release Versions

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Debugging

```bash
# Run in debug mode (default)
flutter run

# Enable verbose logging
flutter run -v

# Profile mode (performance testing)
flutter run --profile

# View logs
flutter logs
```

### Clean Build

```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## User Roles

### Patient
- Can search and book appointments with doctors
- Can track health metrics (blood pressure, heart rate, etc.)
- Can view medical records
- Can join telemedicine video calls
- Can set medication reminders

### Doctor
- Can view and manage appointments
- Can access patient health records
- Can conduct video consultations
- Can create prescriptions
- Can view patient history

### Admin
- Can manage users (approve doctors, manage patients)
- Can view system statistics
- Can moderate content
- Can generate reports

## Testing

### Manual Testing
Follow the testing checklist in `PR1_IMPLEMENTATION_GUIDE.md`

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Generate coverage report
flutter test --coverage
```

### Widget Tests
```dart
testWidgets('Login screen displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  expect(find.text('Welcome Back'), findsOneWidget);
});
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   ```
   Error: Firebase has not been configured
   ```
   **Solution**: Run `flutterfire configure` and restart the app

2. **Dependencies conflict**
   ```
   Error: Version solving failed
   ```
   **Solution**: 
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build errors on iOS**
   ```bash
   cd ios
   pod install
   cd ..
   flutter run
   ```

4. **Emulator not detected**
   ```bash
   # Check available devices
   flutter devices
   
   # Start Android emulator
   flutter emulators --launch <emulator_id>
   ```

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [go_router Package](https://pub.dev/packages/go_router)

### Project Documentation
- `PR_ORGANIZATION_PLAN.md` - Development roadmap
- `PR1_IMPLEMENTATION_GUIDE.md` - Authentication implementation details
- `README.md` - Project overview

### Community
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: Tag `flutter`
- GitHub Issues: Project repository

## Environment Variables

Create a `.env` file (not committed to git):
```
FIREBASE_API_KEY=your_api_key
AGORA_APP_ID=your_agora_app_id
OPENAI_API_KEY=your_openai_key
```

Load with `flutter_dotenv`:
```dart
await dotenv.load(fileName: ".env");
String? apiKey = dotenv.env['FIREBASE_API_KEY'];
```

## Performance Tips

1. **Use const constructors** where possible
2. **Avoid rebuilding entire widget trees** - use Provider selectors
3. **Lazy load images** with `Image.network` or `CachedNetworkImage`
4. **Profile performance** with Flutter DevTools
5. **Optimize list rendering** with `ListView.builder`
6. **Cache network responses** where appropriate

## Code Review Checklist

Before submitting a PR:
- [ ] Code follows project structure and naming conventions
- [ ] No console.log or debug print statements
- [ ] Error handling is implemented
- [ ] Loading states are shown for async operations
- [ ] Code is formatted (`flutter format .`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Tests are passing (`flutter test`)
- [ ] Documentation is updated
- [ ] Screenshots are provided for UI changes

## Getting Help

1. **Check existing documentation** in this repository
2. **Search issues** on GitHub
3. **Ask the team** in project communication channels
4. **Create an issue** with detailed description and reproduction steps

---

## Quick Reference

### Important Files
- `main.dart` - App entry point
- `app_routes.dart` - All routes
- `firebase_options.dart` - Firebase config
- `pubspec.yaml` - Dependencies

### Key Dependencies
```yaml
# State Management
provider: ^6.0.5

# Routing
go_router: ^16.3.0

# Firebase
firebase_core: ^3.0.0
firebase_auth: ^5.7.0
cloud_firestore: ^5.6.12
firebase_storage: ^12.4.10

# Storage
shared_preferences: ^2.2.3
flutter_secure_storage: ^9.2.0

# UI Components
syncfusion_flutter_charts: ^26.2.9
flutter_spinkit: ^5.2.1
image_picker: ^1.1.2

# Real-time Communication
agora_rtc_engine: ^6.5.3
```

### Useful Commands
```bash
# Flutter
flutter doctor                # Check environment
flutter pub get              # Install dependencies
flutter run                  # Run app
flutter build apk            # Build Android APK
flutter test                 # Run tests
flutter analyze              # Analyze code
flutter format .             # Format code
flutter clean                # Clean build

# Firebase
firebase login               # Login to Firebase
firebase init                # Initialize Firebase
firebase deploy              # Deploy functions/rules
flutterfire configure        # Configure Firebase

# Git
git status                   # Check status
git add .                    # Stage all changes
git commit -m "message"      # Commit changes
git push                     # Push to remote
git pull                     # Pull from remote
```

---

**Happy Coding! 🚀**

For questions or issues, please refer to the project documentation or create an issue on GitHub.
