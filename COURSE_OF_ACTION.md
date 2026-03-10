# LifeEase – Course of Action to Complete the Project

**Prepared**: March 2026  
**Current state**: ~35% complete (UI shell + core services built; most integrations are stubs)  
**Goal**: Fully functional, production-ready healthcare app

> This document is the single authoritative implementation guide. It supersedes the scattered planning docs in the repo. Work through each sprint in order — later sprints depend on earlier ones.

---

## Table of Contents

1. [Prerequisites & One-Time Setup](#1-prerequisites--one-time-setup)
2. [Sprint 1 – Wire Up Settings & Fix Settings Persistence (2–3 days)](#2-sprint-1--wire-up-settings--fix-settings-persistence-23-days)
3. [Sprint 2 – Payment Integration (3–4 days)](#3-sprint-2--payment-integration-34-days)
4. [Sprint 3 – Push Notifications / FCM (2–3 days)](#4-sprint-3--push-notifications--fcm-23-days)
5. [Sprint 4 – Emergency SOS Feature (2–3 days)](#5-sprint-4--emergency-sos-feature-23-days)
6. [Sprint 5 – Offline Support & Caching (3–4 days)](#6-sprint-5--offline-support--caching-34-days)
7. [Sprint 6 – Google Maps (2–3 days)](#7-sprint-6--google-maps-23-days)
8. [Sprint 7 – Security Hardening (2–3 days)](#8-sprint-7--security-hardening-23-days)
9. [Sprint 8 – AI Symptom Checker (3–5 days)](#9-sprint-8--ai-symptom-checker-35-days)
10. [Sprint 9 – Prescription Management (3–4 days)](#10-sprint-9--prescription-management-34-days)
11. [Sprint 10 – Lab Results (2–3 days)](#11-sprint-10--lab-results-23-days)
12. [Sprint 11 – Ratings & Reviews (2–3 days)](#12-sprint-11--ratings--reviews-23-days)
13. [Sprint 12 – Support Ticketing (2–3 days)](#13-sprint-12--support-ticketing-23-days)
14. [Sprint 13 – Multi-language / i18n (5–7 days)](#14-sprint-13--multi-language--i18n-57-days)
15. [Sprint 14 – Analytics (1–2 days)](#15-sprint-14--analytics-12-days)
16. [Sprint 15 – Insurance Management (5–7 days)](#16-sprint-15--insurance-management-57-days)
17. [Sprint 16 – Social / Gamification (5–7 days)](#17-sprint-16--social--gamification-57-days)
18. [Sprint 17 – Accessibility (3–4 days)](#18-sprint-17--accessibility-34-days)
19. [Sprint 18 – Testing Infrastructure (ongoing)](#19-sprint-18--testing-infrastructure-ongoing)
20. [Sprint 19 – CI/CD Pipeline (2–3 days)](#20-sprint-19--cicd-pipeline-23-days)
21. [Sprint 20 – Performance Optimization (3–4 days)](#21-sprint-20--performance-optimization-34-days)
22. [Firestore Collections Summary](#22-firestore-collections-summary)
23. [Dependency Matrix](#23-dependency-matrix)
24. [Release Milestones](#24-release-milestones)

---

## 1. Prerequisites & One-Time Setup

Complete these steps before writing a single line of feature code.

### 1a. Create your `.env` file

```bash
cp .env.example .env
```

Open `.env` and fill in **all** values. The app will refuse to start without them:

```env
# Firebase (copy from Firebase Console > Project Settings)
FIREBASE_API_KEY=AIzaSy...
FIREBASE_APP_ID=1:188575701098:android:...
FIREBASE_MESSAGING_SENDER_ID=188575701098
FIREBASE_PROJECT_ID=lifeease-smart-healthcare
FIREBASE_STORAGE_BUCKET=lifeease-smart-healthcare.firebasestorage.app

# iOS Firebase (needed for iOS builds only)
FIREBASE_IOS_API_KEY=
FIREBASE_IOS_APP_ID=
FIREBASE_IOS_CLIENT_ID=
FIREBASE_IOS_BUNDLE_ID=

# Agora (telemedicine)
AGORA_APP_ID=d723eb9e...

# Fill these as you implement each sprint
OPENAI_API_KEY=sk-...
GOOGLE_MAPS_API_KEY=AIzaSy...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# Environment
APP_ENV=development
APP_NAME=LifeEase
API_BASE_URL=https://your-backend-url.com
ENABLE_NOTIFICATIONS=true
```

### 1b. Enable Firebase services

In the [Firebase Console](https://console.firebase.google.com/project/lifeease-smart-healthcare):

| Service | Required for |
|---|---|
| Authentication → Email/Password | Login / Signup |
| Authentication → Google | Google Sign-In |
| Authentication → Phone | OTP / 2FA |
| Firestore Database | All data |
| Cloud Storage | File uploads |
| Cloud Messaging (FCM) | Push notifications (Sprint 3) |

### 1c. Install Flutter dependencies

```bash
flutter pub get
flutter analyze        # should be 0 errors
flutter test           # run existing tests
```

### 1d. Add the packages you will need in the coming sprints

Add these to `pubspec.yaml` now so you only need one `flutter pub get`:

```yaml
dependencies:
  # Payment (Sprint 2)
  flutter_stripe: ^11.1.0

  # FCM Push Notifications (Sprint 3)
  firebase_messaging: ^15.1.5
  flutter_local_notifications: ^17.2.4

  # Offline support (Sprint 5)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.1.3
  cached_network_image: ^3.4.1

  # Security (Sprint 7)
  local_auth: ^2.3.0
  encrypt: ^5.0.3

  # Analytics (Sprint 14)
  firebase_analytics: ^11.4.4

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.15
  mockito: ^5.4.4
```

```bash
flutter pub get
```

---

## 2. Sprint 1 – Wire Up Settings & Fix Settings Persistence (2–3 days)

**Why first**: Settings (theme, language, notifications) must work before any other UX polish. The UI is already built; only the logic needs completing.

**What already exists** (do NOT recreate):
- `lib/screens/common/settings_screen.dart` ✅
- `lib/providers/settings_provider.dart` ✅
- `lib/services/settings_service.dart` ✅
- `lib/widgets/settings/` – all four widgets ✅
- `lib/providers/theme_provider.dart` ✅

**What is broken / incomplete**:

### Task 1.1 – Verify `SettingsService` persists to `SharedPreferences`

Open `lib/services/settings_service.dart` and confirm every `set*` method calls `prefs.setString/setBool`. If any just print or do nothing, implement the storage call.

### Task 1.2 – Connect `ThemeProvider` to the settings screen

The `ThemeSelectorWidget` must call `context.read<ThemeProvider>().setThemeMode(mode)`. Verify the toggle persists after an app restart (check `ThemeProvider` loads from `SharedPreferences` in its constructor).

### Task 1.3 – Sync settings to Firestore on login

In `UserProvider` (or `main.dart` auth listener), after the user signs in call:

```dart
await settingsProvider.syncSettings(user.uid);
```

This writes language + notification prefs to `users/{uid}/settings` so they roam across devices.

### Task 1.4 – Logout clears session properly

In `lib/screens/common/settings_screen.dart` the logout button must:

```dart
onTap: () async {
  await context.read<UserProvider>().signOut();   // clears local state
  await AuthService().signOut();                  // Firebase signOut + Google signOut
  await settingsProvider.clearSettings();         // wipe SharedPreferences
  context.go('/login');
},
```

### Acceptance criteria

- [ ] Theme toggle persists after cold restart
- [ ] Language selection persists after cold restart
- [ ] Notification toggles persist across restarts
- [ ] Logout lands on `/login` with all providers cleared
- [ ] Change-password dialog calls `AuthService().changePassword()` and shows success/failure snackbar

---

## 3. Sprint 2 – Payment Integration (3–4 days)

**Why now**: Appointment booking is the core revenue action. Without payment the app has no monetisation.

### 3a. Packages already added in Sprint 0

`flutter_stripe: ^11.1.0`

### 3b. Files to create

```
lib/
├── models/
│   ├── payment.dart               ← NEW
│   └── invoice.dart               ← NEW
├── services/
│   └── payment_service.dart       ← NEW
├── providers/
│   └── payment_provider.dart      ← NEW
├── screens/
│   ├── common/
│   │   └── payment_screen.dart    ← NEW
│   └── patient/
│       └── payment_history_screen.dart  ← NEW
└── widgets/
    └── payment/
        ├── payment_card_widget.dart      ← NEW
        └── payment_summary_widget.dart   ← NEW
```

### 3c. `lib/models/payment.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String userId;
  final String appointmentId;
  final double amount;
  final String currency;          // 'usd'
  final String status;            // 'pending' | 'completed' | 'failed' | 'refunded'
  final String paymentMethod;     // 'card'
  final String? stripePaymentIntentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    required this.appointmentId,
    required this.amount,
    this.currency = 'usd',
    required this.status,
    this.paymentMethod = 'card',
    this.stripePaymentIntentId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'appointmentId': appointmentId,
    'amount': amount,
    'currency': currency,
    'status': status,
    'paymentMethod': paymentMethod,
    'stripePaymentIntentId': stripePaymentIntentId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'usd',
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'card',
      stripePaymentIntentId: map['stripePaymentIntentId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
```

### 3d. `lib/services/payment_service.dart` (key methods)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../config/env_config.dart';
import '../models/payment.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _col = 'payments';

  static void init() {
    Stripe.publishableKey = EnvConfig.stripePublishableKey ?? '';
  }

  /// Creates a PaymentIntent on your backend and presents the Stripe payment sheet.
  /// Returns true if payment succeeded.
  Future<bool> payForAppointment({
    required String userId,
    required String appointmentId,
    required double amountInDollars,
  }) async {
    // 1. Create payment record (pending)
    final docRef = _db.collection(_col).doc();
    final payment = Payment(
      id: docRef.id,
      userId: userId,
      appointmentId: appointmentId,
      amount: amountInDollars,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await docRef.set(payment.toMap());

    try {
      // 2. Create PaymentIntent via your backend / Firebase Cloud Function
      //    The backend returns { clientSecret: 'pi_xxx_secret_xxx' }
      final clientSecret = await _createPaymentIntent(
        amount: (amountInDollars * 100).toInt(),   // Stripe uses cents
        currency: 'usd',
      );

      // 3. Present Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LifeEase',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 4. Mark as completed in Firestore
      await docRef.update({
        'status': 'completed',
        'stripePaymentIntentId': clientSecret.split('_secret').first,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      await docRef.update({'status': 'failed', 'updatedAt': Timestamp.now()});
      return false;
    }
  }

  /// Call your Firebase Cloud Function or backend to create a PaymentIntent.
  /// See: https://stripe.com/docs/payments/accept-a-payment
  Future<String> _createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    // TODO: Replace with actual HTTP call to your backend
    // Example using Firebase callable function:
    // final callable = FirebaseFunctions.instance.httpsCallable('createPaymentIntent');
    // final result = await callable({'amount': amount, 'currency': currency});
    // return result.data['clientSecret'];
    throw UnimplementedError(
      'Connect _createPaymentIntent to your backend / Firebase Cloud Function.',
    );
  }

  /// Fetch payment history for a user
  Future<List<Payment>> getUserPayments(String userId) async {
    final snap = await _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Payment.fromMap(d.data())).toList();
  }
}
```

### 3e. Integrate into appointment booking

In `lib/screens/patient/appointment_booking_screen.dart`, after the user confirms the slot, add a "Pay & Book" button that calls `PaymentService().payForAppointment(...)`. Only write the Firestore appointment document after `payForAppointment` returns `true`.

### 3f. Firestore rules – add `payments` collection

In `firestore.rules` add:

```
match /payments/{paymentId} {
  allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
  allow create: if isPatient() && request.resource.data.userId == request.auth.uid;
  allow update: if isAdmin();
  allow read, write: if isAdmin();
}
```

### 3g. Add route

In `lib/routes/app_routes.dart`:
```dart
GoRoute(path: '/payment', builder: (_, __) => const PaymentScreen()),
GoRoute(path: '/patient/payment-history', builder: (_, __) => const PaymentHistoryScreen()),
```

### Acceptance criteria

- [ ] User can pay for an appointment with a test Stripe card (`4242 4242 4242 4242`)
- [ ] Failed payment shows error, appointment not created
- [ ] Payment history screen shows all payments
- [ ] Payment status stored in Firestore

---

## 4. Sprint 3 – Push Notifications / FCM (2–3 days)

**Why now**: Appointment and medication reminders are core healthcare features.

### 4a. Files to create

```
lib/services/
├── fcm_service.dart                    ← NEW
└── local_notification_service.dart    ← NEW
```

### 4b. `lib/services/fcm_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalNotificationService.showFromRemote(message);
}

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    // Register background handler FIRST
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS + Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Foreground message display
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService.showFromRemote(message);
    });

    // Save token to Firestore
    final token = await _fcm.getToken();
    if (token != null) await _saveToken(token);

    // Refresh token
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  /// Subscribe to a Firestore-triggered notification topic.
  Future<void> subscribeToTopic(String topic) =>
      _fcm.subscribeToTopic(topic);
}
```

### 4c. Initialize in `lib/main.dart`

```dart
// After Firebase.initializeApp(...)
await LocalNotificationService.init();
await FcmService().init();
```

### 4d. Notification channels for Android

In `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="lifeease_default_channel" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
```

### 4e. iOS permissions in `ios/Runner/Info.plist`

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 4f. Send appointment reminders

In `PaymentService` (after payment success) or via a Firebase Cloud Function triggered on appointment creation, call:

```
POST https://fcm.googleapis.com/v1/projects/{project}/messages:send
```

with the patient's `fcmToken` stored in Firestore.

### Acceptance criteria

- [ ] Notification received when app is in foreground
- [ ] Notification received when app is in background / closed
- [ ] Tapping notification navigates to relevant screen
- [ ] FCM token saved to Firestore `users/{uid}.fcmToken`

---

## 5. Sprint 4 – Emergency SOS Feature (2–3 days)

**Why now**: A healthcare app without emergency access is unsafe.

### 5a. Files to create

```
lib/
├── models/
│   └── emergency_contact.dart          ← NEW
├── services/
│   └── emergency_service.dart          ← NEW
├── screens/patient/
│   ├── emergency_screen.dart            ← NEW
│   └── emergency_contacts_screen.dart   ← NEW
└── widgets/
    └── sos_button.dart                  ← NEW
```

### 5b. `lib/models/emergency_contact.dart`

```dart
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;   // 'spouse', 'parent', 'sibling', 'friend', 'other'

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone, 'relationship': relationship,
  };
  factory EmergencyContact.fromMap(Map<String, dynamic> m) => EmergencyContact(
    id: m['id'] ?? '', name: m['name'] ?? '',
    phone: m['phone'] ?? '', relationship: m['relationship'] ?? 'other',
  );
}
```

### 5c. `lib/services/emergency_service.dart` (key methods)

```dart
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/emergency_contact.dart';

class EmergencyService {
  final _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Dial emergency services (112 international, 911 USA)
  Future<void> callEmergencyServices() async {
    final uri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Dial a saved emergency contact
  Future<void> callContact(EmergencyContact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  /// Send SMS with current location to all emergency contacts
  Future<void> sendSOSWithLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final contacts = await getEmergencyContacts();
    final mapsUrl =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    final body = 'EMERGENCY: I need help. My location: $mapsUrl';

    for (final c in contacts) {
      final uri = Uri(scheme: 'sms', path: c.phone,
          queryParameters: {'body': body});
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    final snap = await _db
        .collection('users').doc(_uid)
        .collection('emergency_contacts').get();
    return snap.docs
        .map((d) => EmergencyContact.fromMap(d.data()))
        .toList();
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    final ref = _db.collection('users').doc(_uid)
        .collection('emergency_contacts').doc();
    await ref.set({...contact.toMap(), 'id': ref.id});
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    await _db.collection('users').doc(_uid)
        .collection('emergency_contacts').doc(contactId).delete();
  }
}
```

> **Note**: `url_launcher` must be in `pubspec.yaml`. Add `url_launcher: ^6.3.1`.

### 5d. Add SOS button to patient home

In `lib/screens/patient/patient_home_screen.dart`, add a `FloatingActionButton` with a red background:

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => context.go('/patient/emergency'),
  backgroundColor: Colors.red,
  icon: const Icon(Icons.emergency, color: Colors.white),
  label: const Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
),
```

### 5e. Add routes

```dart
GoRoute(path: '/patient/emergency', builder: (_, __) => const EmergencyScreen()),
GoRoute(path: '/patient/emergency-contacts', builder: (_, __) => const EmergencyContactsScreen()),
```

### Acceptance criteria

- [ ] SOS button visible on patient home screen
- [ ] Tapping SOS opens emergency screen with one-tap 112 dial
- [ ] Can add / remove emergency contacts
- [ ] "Send SOS" fires SMS with Google Maps link to all contacts

---

## 6. Sprint 5 – Offline Support & Caching (3–4 days)

**Why now**: The app is unusable without internet. Healthcare data must be accessible anywhere.

### 6a. Packages already added in Sprint 0

`hive`, `hive_flutter`, `connectivity_plus`, `cached_network_image`

### 6b. Files to create

```
lib/services/
├── cache_service.dart         ← NEW
├── connectivity_service.dart  ← NEW
└── sync_service.dart          ← NEW
lib/widgets/common/
└── offline_banner.dart        ← NEW
```

### 6c. Initialize Hive in `lib/main.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
// ...
await Hive.initFlutter();
await Hive.openBox('appointments');
await Hive.openBox('health_records');
await Hive.openBox('user_profile');
await Hive.openBox('sync_queue');
```

### 6d. `lib/services/cache_service.dart` (pattern)

```dart
import 'package:hive/hive.dart';

class CacheService {
  static const _appointments = 'appointments';
  static const _profile = 'user_profile';

  Future<void> cacheAppointments(List<Map<String, dynamic>> appointments) async {
    final box = Hive.box(_appointments);
    await box.put('list', appointments);
  }

  List<Map<String, dynamic>> getCachedAppointments() {
    final box = Hive.box(_appointments);
    final raw = box.get('list');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw as List);
  }

  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    final box = Hive.box(_profile);
    await box.put('data', profile);
  }

  Map<String, dynamic>? getCachedUserProfile() {
    return Hive.box(_profile).get('data') as Map<String, dynamic>?;
  }

  Future<void> clearAll() async {
    for (final name in [_appointments, _profile, 'health_records', 'sync_queue']) {
      await Hive.box(name).clear();
    }
  }
}
```

### 6e. `lib/services/connectivity_service.dart`

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
```

### 6f. Add offline banner to every scaffold

In `lib/widgets/common/offline_banner.dart`:

```dart
class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().onlineStream,
      builder: (ctx, snap) {
        final offline = snap.data == false;
        return Column(children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text('No internet connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          Expanded(child: child),
        ]);
      },
    );
  }
}
```

Wrap each `Scaffold` body or use this as a wrapper in `MyApp`.

### 6g. Fallback reads in providers

In `AppointmentProvider`, `HealthRecordProvider` etc., when the Firestore call fails (or `isOnline()` returns false) fall back to `CacheService`:

```dart
try {
  final data = await _db.collection('appointments')...get();
  final list = data.docs.map(...).toList();
  await CacheService().cacheAppointments(list.map((a) => a.toMap()).toList());
  _appointments = list;
} catch (_) {
  final cached = CacheService().getCachedAppointments();
  _appointments = cached.map(Appointment.fromMap).toList();
}
```

### Acceptance criteria

- [ ] Appointments visible in airplane mode
- [ ] Offline banner shown when disconnected
- [ ] Data syncs automatically when connectivity restored
- [ ] Cache cleared on logout

---

## 7. Sprint 6 – Google Maps (2–3 days)

**Why now**: Finding nearby doctors is a core feature; the package is already in `pubspec.yaml`.

### 7a. Files to create / modify

- `lib/screens/patient/doctor_map_search_screen.dart` – already exists, needs implementation
- `lib/widgets/map/doctor_map_marker.dart` – already exists, needs implementation
- `lib/services/location_service.dart` – exists, needs completing

### 7b. `lib/services/location_service.dart` (complete it)

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String?> getAddressFromCoords(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      return '${p.street}, ${p.locality}, ${p.country}';
    } catch (_) {
      return null;
    }
  }

  double distanceInKm(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}
```

### 7c. Implement `DoctorMapSearchScreen`

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ...
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(userLat, userLng),
    zoom: 13,
  ),
  markers: _buildDoctorMarkers(doctors),
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
)
```

For each doctor that has `latitude` and `longitude` stored in Firestore, add a `Marker`. Tapping a marker opens the `DoctorProfileScreen`.

### 7d. Android manifest

In `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${GOOGLE_MAPS_API_KEY}"/>
```

In `android/app/build.gradle.kts` add:

```kotlin
defaultConfig {
    manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = System.getenv("GOOGLE_MAPS_API_KEY") ?: ""
}
```

### 7e. iOS `Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>LifeEase needs your location to find nearby doctors.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>LifeEase uses your location to find nearby doctors.</string>
```

### Acceptance criteria

- [ ] Map loads with user's current location centred
- [ ] Doctors shown as markers (requires lat/lng in their Firestore profiles)
- [ ] Tapping a marker navigates to doctor profile
- [ ] Distance to each doctor displayed in doctor list
- [ ] Location permission dialog shows before first use

---

## 8. Sprint 7 – Security Hardening (2–3 days)

**Why now**: HIPAA-like compliance requires encryption, biometric auth, and audit logs.

### 8a. Files to create

```
lib/services/
├── biometric_service.dart        ← NEW
└── encryption_service.dart       ← NEW
lib/screens/common/
└── security_settings_screen.dart ← NEW
```

### 8b. `lib/services/biometric_service.dart`

```dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() => _auth.canCheckBiometrics;

  Future<bool> authenticate({String reason = 'Authenticate to access LifeEase'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,   // fall back to PIN
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
```

### 8c. `lib/services/encryption_service.dart`

```dart
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _storage = FlutterSecureStorage();
  static const _keyAlias = 'lifeease_enc_key';

  Future<Encrypter> _getEncrypter() async {
    String? keyStr = await _storage.read(key: _keyAlias);
    if (keyStr == null) {
      final key = Key.fromSecureRandom(32);
      keyStr = key.base64;
      await _storage.write(key: _keyAlias, value: keyStr);
    }
    final key = Key.fromBase64(keyStr);
    return Encrypter(AES(key, mode: AESMode.cbc));
  }

  Future<String> encrypt(String plaintext) async {
    final enc = await _getEncrypter();
    final iv = IV.fromSecureRandom(16);
    final encrypted = enc.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  Future<String> decrypt(String ciphertext) async {
    final parts = ciphertext.split(':');
    if (parts.length != 2) throw Exception('Invalid ciphertext');
    final enc = await _getEncrypter();
    final iv = IV.fromBase64(parts[0]);
    return enc.decrypt64(parts[1], iv: iv);
  }
}
```

### 8d. Biometric login option

In `lib/screens/auth/login_screen.dart`, after the form, add:

```dart
if (await BiometricService().isAvailable())
  ElevatedButton.icon(
    onPressed: () async {
      final ok = await BiometricService().authenticate();
      if (ok) _loginWithSavedCredentials();
    },
    icon: const Icon(Icons.fingerprint),
    label: const Text('Use Biometrics'),
  ),
```

### 8e. Auto-logout on inactivity

Wrap `MyApp` with an `InactivityDetector` that calls `AuthService().signOut()` after 30 minutes of no user interaction. Use `GestureDetector` at the app root that resets a timer on any pointer event.

### 8f. Security audit log

Log security events to Firestore collection `security_logs`:

```dart
await FirebaseFirestore.instance.collection('security_logs').add({
  'userId': uid,
  'event': 'login_success',   // or 'login_failed', 'password_changed', etc.
  'timestamp': FieldValue.serverTimestamp(),
  'deviceInfo': await _getDeviceInfo(),
});
```

### Acceptance criteria

- [ ] Biometric login works on physical device
- [ ] Auto-logout fires after 30 minutes of inactivity
- [ ] Sensitive health notes encrypted before writing to Firestore
- [ ] Security events logged to Firestore

---

## 9. Sprint 8 – AI Symptom Checker (3–5 days)

**Why now**: This is the key differentiating feature.  
**`AiService` already has**: Firestore logging, prompt builder, disclaimer text. The `_callAiApi()` method is an empty stub.

### 9a. Files to create

```
lib/screens/patient/
└── ai_symptom_checker_screen.dart    ← NEW
lib/widgets/ai/
└── disclaimer_widget.dart            ← NEW
```

### 9b. Implement `_callAiApi()` in `lib/services/ai_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

Future<String> _callAiApi(String prompt) async {
  final apiKey = EnvConfig.openaiApiKey;
  if (apiKey == null || apiKey.isEmpty) {
    return 'AI service is not configured. Please set OPENAI_API_KEY in .env';
  }

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': EnvConfig.getOptional('OPENAI_MODEL') ?? 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a medical triage assistant. Always include a '
              'disclaimer that users should consult a real doctor. '
              'Never diagnose; only suggest possibilities and urgency.',
        },
        {'role': 'user', 'content': prompt},
      ],
      'max_tokens': int.tryParse(
            EnvConfig.getOptional('OPENAI_MAX_TOKENS') ?? '500') ?? 500,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return data['choices'][0]['message']['content'] as String;
}
```

> **Cost management**: Cache responses in Firestore for 24 h using the symptom list as the cache key. See `AiService.querySymptoms()` – it already logs to Firestore; add a cache-lookup step before calling the API.

### 9c. Add route

```dart
GoRoute(path: '/patient/ai-checker', builder: (_, __) => const AiSymptomCheckerScreen()),
```

Link from the patient home screen quick-action grid.

### Acceptance criteria

- [ ] Entering symptoms returns a plain-English analysis
- [ ] Medical disclaimer always displayed
- [ ] Response cached to avoid duplicate API calls
- [ ] Graceful error shown when OpenAI key not set

---

## 10. Sprint 9 – Prescription Management (3–4 days)

### 10a. Files to create

```
lib/
├── models/
│   ├── prescription.dart                  ← NEW
│   └── medication.dart                    ← NEW
├── services/
│   └── prescription_service.dart          ← NEW
├── providers/
│   └── prescription_provider.dart         ← NEW
├── screens/
│   ├── patient/
│   │   ├── prescription_list_screen.dart  ← NEW
│   │   └── prescription_detail_screen.dart ← NEW
│   └── doctor/
│       └── create_prescription_screen.dart ← NEW
└── widgets/prescription/
    ├── prescription_card.dart             ← NEW
    └── medication_item_widget.dart        ← NEW
```

### 10b. `lib/models/prescription.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'medication.dart';

class Prescription {
  final String id;
  final String doctorId;
  final String patientId;
  final String? appointmentId;
  final List<Medication> medications;
  final String? diagnosis;
  final String? notes;
  final String status;        // 'active' | 'completed' | 'cancelled'
  final DateTime createdAt;
  final DateTime? expiresAt;

  Prescription({
    required this.id,
    required this.doctorId,
    required this.patientId,
    this.appointmentId,
    required this.medications,
    this.diagnosis,
    this.notes,
    this.status = 'active',
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'doctorId': doctorId, 'patientId': patientId,
    'appointmentId': appointmentId,
    'medications': medications.map((m) => m.toMap()).toList(),
    'diagnosis': diagnosis, 'notes': notes, 'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
  };

  factory Prescription.fromMap(Map<String, dynamic> m) => Prescription(
    id: m['id'] ?? '',
    doctorId: m['doctorId'] ?? '',
    patientId: m['patientId'] ?? '',
    appointmentId: m['appointmentId'],
    medications: (m['medications'] as List? ?? [])
        .map((x) => Medication.fromMap(x as Map<String, dynamic>))
        .toList(),
    diagnosis: m['diagnosis'],
    notes: m['notes'],
    status: m['status'] ?? 'active',
    createdAt: (m['createdAt'] as Timestamp).toDate(),
    expiresAt: m['expiresAt'] != null
        ? (m['expiresAt'] as Timestamp).toDate() : null,
  );
}
```

### 10c. `lib/models/medication.dart`

```dart
class Medication {
  final String name;
  final String dosage;     // e.g. '500mg'
  final String frequency;  // e.g. 'twice daily'
  final String duration;   // e.g. '7 days'
  final String? instructions;

  Medication({required this.name, required this.dosage,
    required this.frequency, required this.duration, this.instructions});

  Map<String, dynamic> toMap() => {
    'name': name, 'dosage': dosage, 'frequency': frequency,
    'duration': duration, 'instructions': instructions,
  };
  factory Medication.fromMap(Map<String, dynamic> m) => Medication(
    name: m['name'] ?? '', dosage: m['dosage'] ?? '',
    frequency: m['frequency'] ?? '', duration: m['duration'] ?? '',
    instructions: m['instructions'],
  );
}
```

### 10d. Add routes

```dart
GoRoute(path: '/patient/prescriptions', builder: (_, __) => const PrescriptionListScreen()),
GoRoute(path: '/patient/prescription-detail', builder: (_, s) =>
    PrescriptionDetailScreen(prescriptionId: s.uri.queryParameters['id']!)),
GoRoute(path: '/doctor/create-prescription', builder: (_, s) =>
    CreatePrescriptionScreen(patientId: s.uri.queryParameters['patientId']!)),
```

### Acceptance criteria

- [ ] Doctor can create prescription with 1+ medications
- [ ] Patient sees all active prescriptions on home screen
- [ ] Prescription detail shows medication dosage and instructions
- [ ] Medication reminders auto-created via `NotificationService`

---

## 11. Sprint 10 – Lab Results (2–3 days)

### 11a. Files to create

```
lib/
├── models/lab_result.dart               ← NEW
├── services/lab_result_service.dart     ← NEW
├── providers/lab_result_provider.dart   ← NEW
└── screens/patient/
    ├── lab_results_screen.dart          ← NEW
    ├── lab_result_detail_screen.dart    ← NEW
    └── upload_lab_result_screen.dart    ← NEW
```

### 11b. Key pattern: upload PDF / image

```dart
// In UploadLabResultScreen
final picker = ImagePicker();
final file = await picker.pickImage(source: ImageSource.gallery);
if (file == null) return;

// Upload to Firebase Storage
final ref = FirebaseStorage.instance
    .ref('lab_results/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
await ref.putFile(File(file.path));
final url = await ref.getDownloadURL();

// Save metadata to Firestore
await FirebaseFirestore.instance.collection('lab_results').add({
  'patientId': userId,
  'testName': testNameController.text,
  'fileUrl': url,
  'fileType': 'image',
  'testDate': Timestamp.fromDate(selectedDate),
  'uploadedAt': FieldValue.serverTimestamp(),
  'sharedWith': [],
});
```

### Acceptance criteria

- [ ] Patient can upload PDF or image lab result
- [ ] Results displayed in chronological list
- [ ] Can share result with specific doctor (adds doctorId to `sharedWith` array)
- [ ] Doctor can view results shared with them

---

## 12. Sprint 11 – Ratings & Reviews (2–3 days)

### 12a. Files to create

```
lib/
├── models/review.dart                        ← NEW
├── services/review_service.dart              ← NEW
├── screens/patient/leave_review_screen.dart  ← NEW
├── screens/doctor/reviews_list_screen.dart   ← NEW
└── widgets/
    ├── star_rating_widget.dart               ← NEW
    └── review_card.dart                      ← NEW
```

### 12b. Firestore structure

```
reviews/{reviewId}/
  doctorId, patientId, appointmentId,
  rating (1-5), title, comment,
  createdAt, helpfulCount, doctorReply
```

### 12c. Show average rating on doctor profile

In `lib/screens/patient/doctor_profile_screen.dart`:

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('reviews')
      .where('doctorId', isEqualTo: doctorId)
      .snapshots(),
  builder: (ctx, snap) {
    if (!snap.hasData) return const SizedBox.shrink();
    final reviews = snap.data!.docs;
    final avg = reviews.isEmpty ? 0.0
        : reviews.map((d) => (d['rating'] as num).toDouble())
            .reduce((a, b) => a + b) / reviews.length;
    return Row(children: [
      StarRatingWidget(rating: avg, size: 20),
      Text(' ${avg.toStringAsFixed(1)} (${reviews.length} reviews)'),
    ]);
  },
)
```

### Acceptance criteria

- [ ] "Leave a review" button appears in appointment history after appointment is completed
- [ ] Rating and comment saved to Firestore
- [ ] Average rating visible on doctor profile
- [ ] Doctor can reply to a review

---

## 13. Sprint 12 – Support Ticketing (2–3 days)

### 13a. Files to create

```
lib/
├── models/support_ticket.dart             ← NEW
├── services/support_service.dart          ← NEW
└── screens/common/
    ├── faq_screen.dart                    ← NEW
    └── ticket_details_screen.dart         ← NEW
```

### 13b. Enhance `support_screen.dart`

Replace the local-only save with a Firestore write:

```dart
await FirebaseFirestore.instance.collection('support_tickets').add({
  'userId': uid,
  'subject': subjectController.text,
  'description': descriptionController.text,
  'category': selectedCategory,
  'status': 'open',
  'priority': 'normal',
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
  'messages': [],
});
```

### Acceptance criteria

- [ ] Ticket saved to Firestore
- [ ] User can view ticket status (open / in progress / resolved)
- [ ] FAQ screen searchable
- [ ] Admin can respond to tickets via Firestore update

---

## 14. Sprint 13 – Multi-language / i18n (5–7 days)

### 14a. Package already in `pubspec.yaml`

`intl: ^0.18.1` ✅. Add Flutter localization:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

### 14b. File structure

```
lib/l10n/
├── app_en.arb    ← English (base)
├── app_es.arb    ← Spanish
├── app_ar.arb    ← Arabic (RTL)
├── app_ur.arb    ← Urdu (RTL)
└── app_hi.arb    ← Hindi
```

### 14c. `pubspec.yaml` flutter section

```yaml
flutter:
  generate: true
  # ... existing entries
```

Add `l10n.yaml` at project root:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 14d. Sample `lib/l10n/app_en.arb`

```json
{
  "@@locale": "en",
  "appTitle": "LifeEase",
  "@appTitle": { "description": "The application title" },
  "loginTitle": "Welcome Back",
  "signIn": "Sign In",
  "signUp": "Sign Up",
  "email": "Email",
  "password": "Password",
  "forgotPassword": "Forgot Password?",
  "settingsTitle": "Settings",
  "logout": "Logout",
  "language": "Language",
  "theme": "Theme"
}
```

### 14e. In `lib/main.dart`

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp.router(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'), Locale('es'),
    Locale('ar'), Locale('ur'), Locale('hi'),
  ],
  locale: settingsProvider.locale,   // driven by SettingsProvider
  // ...
);
```

### 14f. Replace hardcoded strings

Run this shell command to find all hardcoded English strings and replace with `AppLocalizations.of(context)!.key`:

```bash
grep -rn '"[A-Z][a-z]' lib/screens/ | grep -v '.arb'
```

This is time-consuming but necessary. Work screen by screen.

### Acceptance criteria

- [ ] Complete English translation exists
- [ ] Language can be changed from Settings
- [ ] Spanish translations complete
- [ ] Arabic/Urdu render RTL correctly
- [ ] Date/number formatting follows locale

---

## 15. Sprint 14 – Analytics (1–2 days)

### 15a. Package already added in Sprint 0

`firebase_analytics: ^11.4.4`

### 15b. `lib/services/analytics_service.dart`

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final _analytics = FirebaseAnalytics.instance;

  Future<void> logAppointmentBooked({required String doctorId, required double amount}) =>
      _analytics.logEvent(name: 'appointment_booked',
          parameters: {'doctor_id': doctorId, 'amount': amount});

  Future<void> logSearch(String query) =>
      _analytics.logSearch(searchTerm: query);

  Future<void> logPaymentCompleted(double amount) =>
      _analytics.logPurchase(value: amount, currency: 'USD');

  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);
}
```

Call `AnalyticsService().logScreenView(name)` in each screen's `initState`.

### Acceptance criteria

- [ ] Key events appear in Firebase Analytics DebugView
- [ ] Screen views tracked for all main screens

---

## 16. Sprint 15 – Insurance Management (5–7 days)

### 16a. Files to create

```
lib/
├── models/
│   ├── insurance.dart               ← NEW
│   └── insurance_claim.dart         ← NEW
├── services/insurance_service.dart  ← NEW
└── screens/patient/
    ├── insurance_screen.dart        ← NEW
    ├── add_insurance_screen.dart    ← NEW
    └── insurance_claim_screen.dart  ← NEW
```

### 16b. Firestore structure

```
insurance/{insuranceId}/
  userId, provider, policyNumber, groupNumber,
  cardFrontUrl, cardBackUrl, coverageType, expiryDate

insurance_claims/{claimId}/
  insuranceId, appointmentId, amount,
  status (submitted | under_review | approved | rejected),
  submittedAt, documents[]
```

### Acceptance criteria

- [ ] User can photograph and store insurance card
- [ ] Multiple insurance cards supported
- [ ] Claims submittable with document attachments
- [ ] Claim status trackable

---

## 17. Sprint 16 – Social / Gamification (5–7 days)

### 17a. Files to create

```
lib/
├── models/
│   ├── challenge.dart              ← NEW
│   └── achievement.dart           ← NEW
├── services/gamification_service.dart ← NEW
└── screens/patient/
    ├── health_challenges_screen.dart  ← NEW
    ├── achievements_screen.dart       ← NEW
    └── referral_screen.dart           ← NEW
```

### 17b. Achievement unlock logic

In `GamificationService`, after each health-record entry:

```dart
Future<void> checkAchievements(String userId) async {
  final records = await _db.collection('health_records')
      .where('userId', isEqualTo: userId).get();
  if (records.docs.length >= 7) {
    await _unlockAchievement(userId, 'week_streak');
  }
}
```

### Acceptance criteria

- [ ] Users can join health challenges
- [ ] Achievements unlock automatically based on activity
- [ ] Points / level displayed on profile

---

## 18. Sprint 17 – Accessibility (3–4 days)

### 18a. Work through every screen and add

```dart
Semantics(
  label: 'Book appointment with Dr. Smith',
  child: ElevatedButton(...),
)
```

### 18b. High-contrast mode

Add `highContrast` theme to `lib/utils/theme.dart` and expose a toggle in `ThemeProvider`.

### 18c. Font scaling

All text must use `TextScaler` or set `textScaleFactor` to respect the system font size. Avoid hardcoded pixel sizes in `TextStyle`.

### Acceptance criteria

- [ ] TalkBack (Android) navigates all interactive elements
- [ ] VoiceOver (iOS) navigates all interactive elements
- [ ] No text is clipped at 200% font scale
- [ ] High-contrast mode available in Settings

---

## 19. Sprint 18 – Testing Infrastructure (ongoing)

**Goal**: ≥ 80% service coverage, ≥ 60% widget coverage.

### 19a. Packages (already in `pubspec.yaml`)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

### 19b. Test file map

| Feature | Unit test | Widget test | Integration test |
|---|---|---|---|
| AuthService | `test/services/auth_service_test.dart` | – | `integration_test/auth_flow_test.dart` |
| PaymentService | `test/services/payment_service_test.dart` | `test/widgets/payment_screen_test.dart` | `integration_test/payment_flow_test.dart` |
| FcmService | `test/services/fcm_service_test.dart` | – | – |
| EmergencyService | `test/services/emergency_service_test.dart` | `test/widgets/sos_button_test.dart` | – |
| SettingsProvider | `test/providers/settings_provider_test.dart` | `test/widgets/settings_screen_test.dart` | `integration_test/settings_integration_test.dart` |
| ReviewService | `test/services/review_service_test.dart` | `test/widgets/star_rating_widget_test.dart` | – |

### 19c. Example unit test with Mockito

```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:LifeEase/services/auth_service.dart';

@GenerateMocks([FirebaseAuth, UserCredential])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockAuth;

    setUp(() => mockAuth = MockFirebaseAuth());

    test('signInWithEmail returns UserCredential on success', () async {
      final mockCred = MockUserCredential();
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com', password: 'pass'))
          .thenAnswer((_) async => mockCred);
      // Test your service with the injected mock
    });
  });
}
```

### 19d. Run tests

```bash
flutter test                               # unit + widget tests
flutter test integration_test/             # integration tests (requires device/emulator)
flutter test --coverage                    # generate coverage report
genhtml coverage/lcov.info -o coverage/html  # HTML report
```

---

## 20. Sprint 19 – CI/CD Pipeline (2–3 days)

### 20a. Files to create

```
.github/workflows/
├── flutter_ci.yml         ← runs on every PR
├── android_release.yml    ← runs on tag push
└── ios_release.yml        ← runs on tag push
```

### 20b. `.github/workflows/flutter_ci.yml`

```yaml
name: Flutter CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Create .env
        run: |
          cat > .env << 'EOF'
          FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }}
          FIREBASE_APP_ID=${{ secrets.FIREBASE_APP_ID }}
          FIREBASE_MESSAGING_SENDER_ID=${{ secrets.FIREBASE_MESSAGING_SENDER_ID }}
          FIREBASE_PROJECT_ID=${{ secrets.FIREBASE_PROJECT_ID }}
          FIREBASE_STORAGE_BUCKET=${{ secrets.FIREBASE_STORAGE_BUCKET }}
          AGORA_APP_ID=${{ secrets.AGORA_APP_ID }}
          APP_ENV=test
          EOF

      - run: flutter pub get
      - run: flutter analyze --no-fatal-warnings
      - run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: 'stable' }
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 20c. Secrets to add in GitHub

Go to **Settings → Secrets → Actions** and add:

```
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET
AGORA_APP_ID
STRIPE_PUBLISHABLE_KEY    (for payment tests)
GOOGLE_MAPS_API_KEY
```

### Acceptance criteria

- [ ] Every PR runs tests automatically
- [ ] Merge blocked if tests fail
- [ ] APK artifact uploaded on successful build

---

## 21. Sprint 20 – Performance Optimization (3–4 days)

Do this **last**, after all features are implemented.

### 21a. Image caching

Replace all `Image.network(url)` with:

```dart
CachedNetworkImage(
  imageUrl: url,
  placeholder: (ctx, url) => const CircularProgressIndicator(),
  errorWidget: (ctx, url, err) => const Icon(Icons.person),
)
```

### 21b. Pagination

Replace unbounded Firestore queries with paginated ones:

```dart
Query query = _db.collection('appointments')
    .where('patientId', isEqualTo: uid)
    .orderBy('dateTime', descending: true)
    .limit(20);

// Load next page
query = query.startAfterDocument(lastDocument);
```

### 21c. Lazy loading lists

Replace `ListView` with `ListView.builder` and add `const` constructors to all stateless widgets.

### 21d. Bundle size

```bash
flutter build apk --analyze-size
flutter build appbundle --analyze-size
```

Remove unused assets and check for duplicate packages.

### 21e. Performance goals

| Metric | Target |
|---|---|
| Cold start | < 2 s |
| Screen transition | < 100 ms |
| Firestore query | < 1 s |
| APK size | < 50 MB |
| Memory usage | < 200 MB |

---

## 22. Firestore Collections Summary

All collections that must exist in Firestore by the end of the project:

| Collection | Created in |
|---|---|
| `users` | Existing |
| `appointments` | Existing |
| `health_records` | Existing |
| `notifications` | Existing |
| `prescriptions` | Sprint 9 |
| `payments` | Sprint 2 |
| `reviews` | Sprint 11 |
| `support_tickets` | Sprint 12 |
| `faqs` | Sprint 12 |
| `lab_results` | Sprint 10 |
| `security_logs` | Sprint 7 |
| `insurance` | Sprint 15 |
| `insurance_claims` | Sprint 15 |
| `challenges` | Sprint 16 |
| `achievements` | Sprint 16 |
| `user_achievements` | Sprint 16 |
| `users/{uid}/emergency_contacts` | Sprint 4 |

Deploy updated `firestore.rules` after adding each new collection.

---

## 23. Dependency Matrix

```
Sprint 1 (Settings)       ──► no external dependencies
Sprint 2 (Payment)        ──► Sprint 1 complete (clean UX before adding payment)
Sprint 3 (FCM)            ──► Sprint 1 complete (notification prefs must persist)
Sprint 4 (Emergency SOS)  ──► Sprint 6 (Maps) useful but not strictly required
Sprint 5 (Offline)        ──► no dependencies
Sprint 6 (Maps)           ──► .env GOOGLE_MAPS_API_KEY
Sprint 7 (Security)       ──► Sprint 1 (settings screen for security toggle)
Sprint 8 (AI)             ──► .env OPENAI_API_KEY
Sprint 9 (Prescriptions)  ──► Sprint 3 (reminders via FCM)
Sprint 10 (Lab Results)   ──► no strict dependencies
Sprint 11 (Reviews)       ──► Sprint 2 (appointments must be completed/paid)
Sprint 12 (Support)       ──► Sprint 3 (FCM for ticket update notifications)
Sprint 13 (i18n)          ──► Sprint 1 (language setting)
Sprint 14 (Analytics)     ──► no dependencies
Sprint 15 (Insurance)     ──► Sprint 2 (payment integration)
Sprint 16 (Social)        ──► Sprint 3 (FCM for challenge notifications)
Sprint 17 (Accessibility) ──► all UI screens stable
Sprint 18 (Testing)       ──► all features implemented
Sprint 19 (CI/CD)         ──► Sprint 18 (tests must exist)
Sprint 20 (Performance)   ──► all features implemented
```

---

## 24. Release Milestones

| Version | Requires | Status |
|---|---|---|
| **v0.9 – Internal Alpha** | Sprints 0–1 | Current state |
| **v1.0 – MVP** | Sprints 1–4 | ~3 weeks |
| **v1.1 – Beta** | + Sprints 5–7 | ~5 weeks |
| **v1.2 – Production** | + Sprints 8–12 | ~8 weeks |
| **v2.0 – Global Launch** | + Sprints 13–17 | ~12 weeks |
| **v2.1 – Hardened** | + Sprints 18–20 | ~14 weeks |

---

## Quick-Reference Commands

```bash
# Install / update dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test
flutter test --coverage

# Generate Hive adapters (after adding @HiveType annotations)
flutter pub run build_runner build --delete-conflicting-outputs

# Build
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle (Play Store)
flutter build ios --release        # iOS (requires macOS + Xcode)
flutter build web                  # Web

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firebase Storage rules
firebase deploy --only storage
```

---

*This document will be updated at the end of each sprint to check off completed items.*
