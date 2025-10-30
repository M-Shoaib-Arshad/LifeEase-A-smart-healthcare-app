# Firebase Setup Guide for LifeEase

## Overview

This document provides step-by-step instructions for setting up Firebase for the LifeEase healthcare application, including Authentication, Firestore Database, and Storage configuration.

---

## Prerequisites

- [ ] Firebase account (create at https://console.firebase.google.com)
- [ ] Flutter development environment set up
- [ ] Firebase CLI installed: `npm install -g firebase-tools`
- [ ] FlutterFire CLI installed: `dart pub global activate flutterfire_cli`

---

## Step 1: Create Firebase Project

1. **Go to Firebase Console**: https://console.firebase.google.com
2. **Click "Add Project"**
3. **Enter Project Details**:
   - Project Name: `LifeEase Healthcare` (or your preferred name)
   - Enable Google Analytics (recommended)
   - Choose or create Analytics account
4. **Click "Create Project"**
5. **Wait for project to be created**

---

## Step 2: Add Firebase to Flutter App

### For Android

1. **Click "Add app" → Select Android icon**
2. **Register Android app**:
   - Android package name: `com.lifeease.healthcare` (match your `android/app/build.gradle`)
   - App nickname: `LifeEase Android`
   - Debug signing certificate (optional for now)
3. **Download `google-services.json`**
4. **Place file**: `android/app/google-services.json`
5. **Update `android/build.gradle`**:
   ```gradle
   buildscript {
     dependencies {
       // Add this line
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```
6. **Update `android/app/build.gradle`**:
   ```gradle
   apply plugin: 'com.android.application'
   apply plugin: 'kotlin-android'
   // Add this line
   apply plugin: 'com.google.gms.google-services'
   
   dependencies {
     implementation platform('com.google.firebase:firebase-bom:32.7.0')
   }
   ```

### For iOS

1. **Click "Add app" → Select iOS icon**
2. **Register iOS app**:
   - iOS bundle ID: `com.lifeease.healthcare` (match your Xcode project)
   - App nickname: `LifeEase iOS`
3. **Download `GoogleService-Info.plist`**
4. **Place file**: `ios/Runner/GoogleService-Info.plist`
5. **Open `ios/Runner.xcworkspace` in Xcode**
6. **Drag `GoogleService-Info.plist` into Xcode project**
   - Make sure "Copy items if needed" is checked
   - Add to "Runner" target

### Use FlutterFire CLI (Recommended)

Or use FlutterFire CLI to automate configuration:

```bash
# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

This generates `lib/firebase_options.dart` automatically.

---

## Step 3: Enable Firebase Authentication

1. **Navigate to**: Firebase Console → Authentication
2. **Click "Get Started"**
3. **Enable Sign-in Methods**:

### Email/Password Authentication (Required)
- Click "Email/Password"
- Toggle "Enable"
- Click "Save"

### Phone Authentication (For OTP - Optional)
- Click "Phone"
- Toggle "Enable"
- Add test phone numbers (for development):
  - Phone: `+1 555-555-1234`
  - Code: `123456`
- Click "Save"

### Google Sign-In (Optional)
- Click "Google"
- Toggle "Enable"
- Select support email
- Click "Save"
- Download Web Client ID and add to app

### Facebook Sign-In (Optional)
- Click "Facebook"
- Toggle "Enable"
- Enter App ID and App Secret from Facebook Developer Console
- Click "Save"

---

## Step 4: Create Firestore Database

1. **Navigate to**: Firebase Console → Firestore Database
2. **Click "Create Database"**
3. **Select Starting Mode**:
   - **Production Mode** (for production)
   - **Test Mode** (for development - allows all reads/writes for 30 days)
4. **Choose Cloud Firestore Location**:
   - Select region closest to your users
   - **Note**: Location cannot be changed later
   - Recommended: `us-central1` (US) or `europe-west1` (Europe)
5. **Click "Enable"**

### Create Collections

Create the following collections with sample documents:

#### 1. Users Collection

**Collection**: `users`
**Document ID**: Auto-generated or User UID
**Fields**:
```json
{
  "id": "user123",
  "email": "patient@example.com",
  "name": "John Doe",
  "role": "patient",
  "phone": "+1234567890",
  "dateOfBirth": "1990-01-15",
  "address": "123 Main St, City",
  "photoURL": "https://example.com/photo.jpg",
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:00Z"
}
```

#### 2. Appointments Collection

**Collection**: `appointments`
**Fields**:
```json
{
  "id": "appt123",
  "patientId": "user123",
  "doctorId": "doc456",
  "date": "2024-02-01",
  "time": "10:00 AM",
  "status": "scheduled",
  "reason": "Checkup",
  "notes": "",
  "createdAt": "2024-01-15T10:00:00Z"
}
```

#### 3. Health Records Collection

**Collection**: `health_records`
**Fields**:
```json
{
  "id": "record123",
  "userId": "user123",
  "type": "blood_pressure",
  "value": {
    "systolic": 120,
    "diastolic": 80
  },
  "unit": "mmHg",
  "recordedAt": "2024-01-20T08:00:00Z",
  "notes": ""
}
```

#### 4. Notifications Collection

**Collection**: `notifications`
**Fields**:
```json
{
  "id": "notif123",
  "userId": "user123",
  "title": "Appointment Reminder",
  "body": "You have an appointment tomorrow at 10 AM",
  "type": "appointment",
  "read": false,
  "createdAt": "2024-01-31T18:00:00Z"
}
```

---

## Step 5: Set Up Firestore Security Rules

### Development Rules (Test Mode)

**Use for**: Initial development and testing

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2024, 12, 31);
    }
  }
}
```

⚠️ **Warning**: These rules allow anyone to read/write. Use only in development!

### Production Rules (Recommended)

**Use for**: Production deployment

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to get user data
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isSignedIn() && getUserData().role == 'admin';
    }
    
    // Helper function to check if user is doctor
    function isDoctor() {
      return isSignedIn() && getUserData().role == 'doctor';
    }
    
    // Helper function to check if user is patient
    function isPatient() {
      return isSignedIn() && getUserData().role == 'patient';
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone authenticated can read any user profile (for searching doctors)
      allow read: if isSignedIn();
      
      // Users can only create their own profile during signup
      allow create: if isSignedIn() && request.auth.uid == userId;
      
      // Users can update their own profile
      allow update: if isSignedIn() && request.auth.uid == userId;
      
      // Users cannot change their role (prevent privilege escalation)
      allow update: if isSignedIn() && 
                       request.auth.uid == userId &&
                       request.resource.data.role == resource.data.role;
      
      // Admins can update any user
      allow update: if isAdmin();
      
      // Only admins can delete users
      allow delete: if isAdmin();
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      // Patients can read their own appointments
      allow read: if isSignedIn() && (
        resource.data.patientId == request.auth.uid ||
        resource.data.doctorId == request.auth.uid
      );
      
      // Patients can create appointments
      allow create: if isPatient() && 
                       request.resource.data.patientId == request.auth.uid;
      
      // Patients can update their own appointments (cancel, reschedule)
      allow update: if isPatient() && 
                       resource.data.patientId == request.auth.uid;
      
      // Doctors can update appointments (confirm, complete)
      allow update: if isDoctor() && 
                       resource.data.doctorId == request.auth.uid;
      
      // Admins can do anything with appointments
      allow read, write: if isAdmin();
    }
    
    // Health records collection
    match /health_records/{recordId} {
      // Users can read their own health records
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Doctors can read patient health records (if they have an appointment)
      allow read: if isDoctor() && 
                     exists(/databases/$(database)/documents/appointments/$(appointmentId)) &&
                     get(/databases/$(database)/documents/appointments/$(appointmentId)).data.doctorId == request.auth.uid &&
                     get(/databases/$(database)/documents/appointments/$(appointmentId)).data.patientId == resource.data.userId;
      
      // Users can create their own health records
      allow create: if isPatient() && 
                       request.resource.data.userId == request.auth.uid;
      
      // Users can update their own health records
      allow update: if isPatient() && 
                       resource.data.userId == request.auth.uid;
      
      // Admins can read all health records
      allow read: if isAdmin();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      // Users can read their own notifications
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // System (admin) can create notifications
      allow create: if isAdmin();
      
      // Users can mark notifications as read
      allow update: if isSignedIn() && 
                       resource.data.userId == request.auth.uid &&
                       request.resource.data.diff(resource.data).affectedKeys().hasOnly(['read']);
      
      // Users can delete their own notifications
      allow delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Prescriptions collection
    match /prescriptions/{prescriptionId} {
      // Patients can read their own prescriptions
      allow read: if isSignedIn() && resource.data.patientId == request.auth.uid;
      
      // Doctors can read prescriptions they created
      allow read: if isDoctor() && resource.data.doctorId == request.auth.uid;
      
      // Doctors can create prescriptions
      allow create: if isDoctor() && 
                       request.resource.data.doctorId == request.auth.uid;
      
      // Doctors can update their own prescriptions
      allow update: if isDoctor() && 
                       resource.data.doctorId == request.auth.uid;
      
      // Admins can read all prescriptions
      allow read: if isAdmin();
    }
    
    // Medical documents/images
    match /medical_documents/{documentId} {
      // Users can read their own documents
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      
      // Doctors can read patient documents (with appointment)
      allow read: if isDoctor();
      
      // Users can upload their own documents
      allow create: if isPatient() && 
                       request.resource.data.userId == request.auth.uid;
      
      // Admins can read all documents
      allow read: if isAdmin();
    }
  }
}
```

### Deploy Security Rules

1. **Save rules in a file**: `firestore.rules`
2. **Deploy via Firebase CLI**:
   ```bash
   firebase deploy --only firestore:rules
   ```
3. **Or copy/paste directly** in Firebase Console → Firestore → Rules tab

---

## Step 6: Set Up Firebase Storage

1. **Navigate to**: Firebase Console → Storage
2. **Click "Get Started"**
3. **Choose Security Rules**:
   - Start in **Test Mode** for development
   - Use **Production Mode** for deployment
4. **Choose Cloud Storage Location** (same as Firestore recommended)
5. **Click "Done"**

### Create Storage Buckets

Organize storage with folders:
```
gs://your-project.appspot.com/
├── avatars/
│   └── {userId}/
│       └── profile.jpg
├── medical_records/
│   └── {userId}/
│       └── {documentId}.pdf
└── prescriptions/
    └── {prescriptionId}/
        └── prescription.jpg
```

### Storage Security Rules

**Development Rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Production Rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper function
    function isSignedIn() {
      return request.auth != null;
    }
    
    // User avatars
    match /avatars/{userId}/{fileName} {
      // Users can read any avatar (public)
      allow read: if true;
      
      // Users can only upload their own avatar
      allow write: if isSignedIn() && request.auth.uid == userId;
      
      // Validate file size and type
      allow write: if request.resource.size < 5 * 1024 * 1024 && // 5MB max
                      request.resource.contentType.matches('image/.*');
    }
    
    // Medical records
    match /medical_records/{userId}/{fileName} {
      // Users can read their own medical records
      allow read: if isSignedIn() && request.auth.uid == userId;
      
      // Doctors can read patient medical records (implement additional checks)
      allow read: if isSignedIn();
      
      // Users can upload their own medical records
      allow write: if isSignedIn() && request.auth.uid == userId;
      
      // Validate file size (10MB max)
      allow write: if request.resource.size < 10 * 1024 * 1024;
    }
    
    // Prescriptions
    match /prescriptions/{prescriptionId}/{fileName} {
      // Only authenticated users can read prescriptions
      allow read: if isSignedIn();
      
      // Only doctors can upload prescriptions (implement doctor verification)
      allow write: if isSignedIn();
      
      // Validate file size and type
      allow write: if request.resource.size < 5 * 1024 * 1024 &&
                      (request.resource.contentType.matches('image/.*') ||
                       request.resource.contentType == 'application/pdf');
    }
  }
}
```

---

## Step 7: Firebase Cloud Messaging (Push Notifications)

### Enable FCM

1. **Navigate to**: Firebase Console → Project Settings → Cloud Messaging
2. **Enable Cloud Messaging API** (if not already enabled)
3. **Get Server Key** (for backend if needed)

### For Android

1. FCM is automatically enabled with `google-services.json`
2. Add permissions to `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```

### For iOS

1. **Upload APNs Certificate**:
   - Create APNs certificate in Apple Developer Console
   - Upload to Firebase Console → Project Settings → Cloud Messaging → APNs Certificates
2. **Enable Push Notifications** in Xcode:
   - Select Runner → Signing & Capabilities
   - Click "+ Capability"
   - Add "Push Notifications"
   - Add "Background Modes" → Check "Remote notifications"

---

## Step 8: Firestore Indexes

### Create Composite Indexes

Some queries require composite indexes. Create them as needed:

1. **Navigate to**: Firebase Console → Firestore → Indexes
2. **Click "Create Index"**
3. **Add indexes for common queries**:

**Example: Query appointments by patient and date**
- Collection: `appointments`
- Fields:
  - `patientId`: Ascending
  - `date`: Descending
- Query scope: Collection

**Example: Query health records by user and date**
- Collection: `health_records`
- Fields:
  - `userId`: Ascending
  - `recordedAt`: Descending

**Note**: Firebase will prompt you to create indexes when you run queries that need them.

---

## Step 9: Firebase Extensions (Optional)

Consider installing these Firebase Extensions:

### 1. Resize Images
- Automatically resize uploaded images
- Useful for profile pictures
- Install from Firebase Console → Extensions

### 2. Trigger Email
- Send emails based on Firestore events
- Useful for appointment reminders
- Configure with email service (SendGrid, Mailgun)

### 3. Delete User Data
- Automatically delete user data when account is deleted
- GDPR compliance

---

## Step 10: Firebase Local Emulator Suite (Development)

### Install Emulators

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize emulators in project directory
firebase init emulators
```

Select:
- [x] Authentication Emulator
- [x] Firestore Emulator
- [x] Storage Emulator

### Start Emulators

```bash
# Start all emulators
firebase emulators:start

# Or start specific emulators
firebase emulators:start --only firestore,auth
```

### Connect Flutter App to Emulators

In `lib/main.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Use emulators in development
  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    } catch (e) {
      print('Emulator connection failed: $e');
    }
  }
  
  runApp(const MyApp());
}
```

---

## Step 11: Monitoring and Analytics

### Firebase Analytics

1. **Already enabled** if you selected Google Analytics during project creation
2. **View Analytics**: Firebase Console → Analytics
3. **Track custom events** in code:
   ```dart
   await FirebaseAnalytics.instance.logEvent(
     name: 'appointment_booked',
     parameters: {'doctor_id': doctorId, 'date': date},
   );
   ```

### Firebase Crashlytics

1. **Add dependency** to `pubspec.yaml`:
   ```yaml
   firebase_crashlytics: ^3.4.0
   ```
2. **Initialize** in `main.dart`:
   ```dart
   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
   ```
3. **Test crash** (remove after testing):
   ```dart
   FirebaseCrashlytics.instance.crash();
   ```

### Firebase Performance Monitoring

1. **Add dependency**:
   ```yaml
   firebase_performance: ^0.9.3
   ```
2. **Track custom traces**:
   ```dart
   final trace = FirebasePerformance.instance.newTrace('login_trace');
   await trace.start();
   // ... login code ...
   await trace.stop();
   ```

---

## Step 12: Environment Configuration

### Multiple Environments

Create separate Firebase projects for different environments:
- **Development**: `lifeease-dev`
- **Staging**: `lifeease-staging`
- **Production**: `lifeease-prod`

### Configure Flutter for Environments

1. **Create separate config files**:
   - `firebase_options_dev.dart`
   - `firebase_options_staging.dart`
   - `firebase_options_prod.dart`

2. **Use flavor-based initialization**:
   ```dart
   import 'firebase_options_dev.dart' as dev;
   import 'firebase_options_prod.dart' as prod;
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     final firebaseOptions = const String.fromEnvironment('FLAVOR') == 'prod'
         ? prod.DefaultFirebaseOptions.currentPlatform
         : dev.DefaultFirebaseOptions.currentPlatform;
     
     await Firebase.initializeApp(options: firebaseOptions);
     runApp(const MyApp());
   }
   ```

3. **Run with flavor**:
   ```bash
   flutter run --dart-define=FLAVOR=dev
   flutter run --dart-define=FLAVOR=prod
   ```

---

## Security Best Practices

### 1. API Key Security
- ✅ API keys in `firebase_options.dart` are safe (restricted by Firebase)
- ✅ Add API key restrictions in Firebase Console → Project Settings → API Keys
- ❌ Never commit sensitive keys to Git

### 2. Firestore Security
- ✅ Always use production-mode security rules
- ✅ Test rules with Firebase Emulator
- ✅ Validate data on both client and server
- ✅ Use Cloud Functions for sensitive operations

### 3. Authentication
- ✅ Enable email verification
- ✅ Implement rate limiting
- ✅ Use reCAPTCHA for sensitive actions
- ✅ Monitor authentication logs

### 4. Data Protection
- ✅ Encrypt sensitive data before storing
- ✅ Implement data retention policies
- ✅ Regular security audits
- ✅ GDPR/HIPAA compliance (if applicable)

---

## Troubleshooting

### Common Issues

**1. Firebase not initialized**
```
Error: Firebase has not been configured
```
**Solution**: Run `flutterfire configure` and restart app

**2. Firestore permission denied**
```
Error: Missing or insufficient permissions
```
**Solution**: Check Firestore security rules

**3. Storage upload failed**
```
Error: User does not have permission to access
```
**Solution**: Check Storage security rules

**4. iOS build fails**
```
Error: GoogleService-Info.plist not found
```
**Solution**: Ensure plist is added to Xcode project

**5. Android build fails**
```
Error: google-services.json not found
```
**Solution**: Place file in `android/app/` directory

---

## Testing Firebase Setup

### Verify Authentication
```dart
// Test signup
try {
  UserCredential cred = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'Test123!');
  print('Auth working: ${cred.user?.uid}');
} catch (e) {
  print('Auth error: $e');
}
```

### Verify Firestore
```dart
// Test write
try {
  await FirebaseFirestore.instance
      .collection('test')
      .add({'message': 'Hello Firebase!'});
  print('Firestore working!');
} catch (e) {
  print('Firestore error: $e');
}
```

### Verify Storage
```dart
// Test upload
try {
  final ref = FirebaseStorage.instance.ref().child('test/image.jpg');
  await ref.putFile(File('path/to/image.jpg'));
  print('Storage working!');
} catch (e) {
  print('Storage error: $e');
}
```

---

## Deployment Checklist

Before deploying to production:

- [ ] Switch from test mode to production mode security rules
- [ ] Deploy Firestore security rules
- [ ] Deploy Storage security rules
- [ ] Enable email verification in Authentication
- [ ] Set up proper indexes in Firestore
- [ ] Configure Firebase Analytics
- [ ] Enable Crashlytics
- [ ] Set up Performance Monitoring
- [ ] Configure proper API key restrictions
- [ ] Test all authentication flows
- [ ] Test all database operations
- [ ] Test file uploads
- [ ] Verify push notifications work
- [ ] Set up monitoring alerts
- [ ] Document Firebase configuration
- [ ] Backup security rules
- [ ] Review access logs

---

## Maintenance

### Regular Tasks

**Daily**:
- Monitor authentication logs
- Check error rates in Crashlytics

**Weekly**:
- Review Firestore usage and costs
- Check security rule violations
- Review Analytics data

**Monthly**:
- Update Firebase SDKs
- Review and optimize indexes
- Audit user permissions
- Review storage usage

**Quarterly**:
- Security audit
- Performance review
- Cost optimization
- Backup configuration

---

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

---

## Support

For Firebase-related issues:
1. Check [Firebase Status Dashboard](https://status.firebase.google.com/)
2. Search [StackOverflow](https://stackoverflow.com/questions/tagged/firebase)
3. Post in [Firebase Community](https://firebase.google.com/support)
4. Contact Firebase Support (paid plans only)

---

**Firebase setup is complete!** 🎉

Your LifeEase app is now ready for development and testing with Firebase backend services.
