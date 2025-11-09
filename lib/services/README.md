# LifeEase Services Documentation

This directory contains service classes that handle business logic, data access, and external integrations.

## Available Services

### 1. AuthService (`auth_service.dart`)
Handles Firebase Authentication operations.

**Features:**
- User registration with email/password
- User sign-in with email/password
- Password reset via email
- Sign out
- Auth state monitoring

**Usage:**
```dart
final authService = AuthService();

// Sign up
await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'securePassword123',
);

// Sign in
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'securePassword123',
);

// Password reset
await authService.sendPasswordResetEmail('user@example.com');

// Sign out
await authService.signOut();

// Monitor auth state
authService.authStateChanges.listen((user) {
  if (user != null) {
    print('User signed in: ${user.uid}');
  } else {
    print('User signed out');
  }
});
```

---

### 2. ApiService (`api_service.dart`)
Manages Firestore database operations for appointments and health records.

**Features:**
- CRUD operations for appointments
- CRUD operations for health records
- Query appointments by patient/doctor
- Query health records by patient

**Usage:**
```dart
final apiService = ApiService();

// Create appointment
final appointment = Appointment(
  id: '',
  patientId: 'patient123',
  doctorId: 'doctor456',
  dateTime: DateTime.now().add(Duration(days: 1)),
  status: 'pending',
  notes: 'Regular checkup',
);
final appointmentId = await apiService.createAppointment(appointment);

// Get patient appointments
final appointments = await apiService.getAppointmentsForPatient('patient123');

// Create health record
final record = HealthRecord(
  id: '',
  patientId: 'patient123',
  date: DateTime.now(),
  vitals: {'bp': '120/80', 'heartRate': 72},
  diagnosis: 'Healthy',
  prescriptions: 'None',
);
await apiService.createHealthRecord(record);
```

---

### 3. UserService (`user_service.dart`)
Manages user profile data in Firestore.

**Features:**
- Create user profiles
- Update user profiles
- Retrieve user data
- Manage user roles and metadata

**Usage:**
```dart
final userService = UserService();

// Create/update user profile
await userService.saveUserProfile(
  uid: 'user123',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'role': 'patient',
    'phone': '+1234567890',
  },
);

// Get user profile
final userProfile = await userService.getUserProfile('user123');
```

---

### 4. StorageService (`storage_service.dart`)
Handles file uploads to Firebase Storage.

**Features:**
- Upload user avatars
- Generate download URLs
- File management

**Usage:**
```dart
final storageService = StorageService();

// Upload avatar
final file = File('/path/to/image.jpg');
final downloadUrl = await storageService.uploadUserAvatar('user123', file);
```

---

### 5. NotificationService (`notification_service.dart`) ✨ NEW
Manages in-app notifications and notification reminders.

**Features:**
- Create notifications for users
- Get user notifications (all or unread only)
- Real-time notification streams
- Mark notifications as read
- Get unread count
- Specialized notification types (appointment, medication, etc.)

**Usage:**
```dart
final notificationService = NotificationService();

// Create a notification
await notificationService.createNotification(
  userId: 'user123',
  title: 'Appointment Reminder',
  message: 'You have an appointment tomorrow at 10 AM',
  type: 'appointment',
  data: {'appointmentId': 'appt123'},
);

// Get user notifications
final notifications = await notificationService.getUserNotifications(limit: 20);

// Stream notifications for real-time updates
notificationService.getUserNotificationsStream().listen((notifications) {
  print('Received ${notifications.length} notifications');
});

// Send appointment reminder
await notificationService.sendAppointmentReminder(
  userId: 'patient123',
  doctorName: 'Dr. Smith',
  appointmentTime: DateTime.now().add(Duration(hours: 24)),
  appointmentId: 'appt123',
);

// Send medication reminder
await notificationService.sendMedicationReminder(
  userId: 'patient123',
  medicationName: 'Aspirin',
  dosage: '100mg',
);

// Get unread count
final unreadCount = await notificationService.getUnreadCount();

// Mark as read
await notificationService.markAsRead('notification123');

// Mark all as read
await notificationService.markAllAsRead();
```

---

### 6. RealTimeService (`real_time_service.dart`) ✨ NEW
Provides real-time Firestore data streams for live updates.

**Features:**
- Real-time appointment streams
- Real-time health record streams
- Real-time health data streams
- Connection status checking
- Filtered and sorted streams

**Usage:**
```dart
final realTimeService = RealTimeService();

// Stream patient appointments
realTimeService.getPatientAppointmentsStream('patient123').listen((appointments) {
  print('Patient has ${appointments.length} appointments');
  // UI updates automatically when data changes in Firestore
});

// Stream doctor appointments
realTimeService.getDoctorAppointmentsStream('doctor456').listen((appointments) {
  print('Doctor has ${appointments.length} appointments');
});

// Stream specific appointment
realTimeService.getAppointmentStream('appt123').listen((appointment) {
  if (appointment != null) {
    print('Appointment status: ${appointment.status}');
  }
});

// Stream health records
realTimeService.getHealthRecordsStream('patient123').listen((records) {
  print('Patient has ${records.length} health records');
});

// Stream today's appointments for doctor
realTimeService.getTodayAppointmentsStream('doctor456').listen((appointments) {
  print('Doctor has ${appointments.length} appointments today');
});

// Stream upcoming appointments count
realTimeService.getUpcomingAppointmentsCount('patient123').listen((count) {
  print('Patient has $count upcoming appointments');
});

// Check connection
final isConnected = await realTimeService.checkConnection();
if (!isConnected) {
  print('No internet connection');
}
```

---

### 7. SecurityService (`security_service.dart`) ✨ NEW
Handles security, encryption, and role-based access control.

**Features:**
- Role-based access control (RBAC)
- Permission management
- Secure data storage
- Session validation
- Input sanitization
- Password validation
- Email and phone validation
- Data encoding/decoding

**Usage:**
```dart
final securityService = SecurityService();

// Set user role after authentication
await securityService.setUserRole(SecurityService.UserRole.patient);

// Check permissions
final canViewRecords = await securityService.hasPermission(
  SecurityService.Permission.viewPatientRecords,
);

if (canViewRecords) {
  // Allow access to patient records
}

// Check if user can access specific patient data
final canAccess = await securityService.canAccessPatientData('patient123');

// Validate password strength
final validation = securityService.validatePassword('MySecurePass123!');
if (validation['isValid']) {
  print('Password strength: ${validation['strength']}%');
}

// Validate email
if (securityService.isValidEmail('user@example.com')) {
  print('Email is valid');
}

// Sanitize user input
final safeInput = securityService.sanitizeInput(userInput);

// Store sensitive data
await securityService.storeSecureData('api_key', 'secret_key_value');

// Retrieve sensitive data
final apiKey = await securityService.getSecureData('api_key');

// Check authentication status
final isAuthenticated = await securityService.isAuthenticated();

// Check session expiration
final isExpired = await securityService.isSessionExpired();
if (isExpired) {
  await securityService.refreshAuthToken();
}

// Log security event
await securityService.logSecurityEvent(
  'login_attempt',
  {'email': 'user@example.com', 'success': true},
);

// Clear data on logout
await securityService.clearAllSecureData();
```

**Role Permissions:**

| Permission | Patient | Doctor | Admin |
|------------|---------|--------|-------|
| viewPatientRecords | ❌ | ✅ | ✅ |
| editPatientRecords | ❌ | ✅ | ✅ |
| createAppointments | ✅ | ❌ | ✅ |
| cancelAppointments | ✅ | ✅ | ✅ |
| viewDoctorSchedule | ❌ | ✅ | ✅ |
| manageDoctors | ❌ | ❌ | ✅ |
| managePatients | ❌ | ❌ | ✅ |
| viewAnalytics | ❌ | ❌ | ✅ |
| manageContent | ❌ | ❌ | ✅ |
| sendNotifications | ❌ | ✅ | ✅ |
| accessTelemedicine | ✅ | ✅ | ✅ |

---

## Service Integration Examples

### Example 1: Complete Authentication Flow with Security
```dart
// 1. Sign up user
final authService = AuthService();
final securityService = SecurityService();

// Validate inputs
if (!securityService.isValidEmail(email)) {
  throw Exception('Invalid email');
}

final passwordCheck = securityService.validatePassword(password);
if (!passwordCheck['isValid']) {
  throw Exception('Password too weak');
}

// Create account
final credential = await authService.signUpWithEmail(
  email: email,
  password: password,
);

// Set user role
await securityService.setUserRole(SecurityService.UserRole.patient);

// Create user profile
final userService = UserService();
await userService.saveUserProfile(
  uid: credential.user!.uid,
  data: {
    'email': email,
    'role': 'patient',
    'createdAt': DateTime.now().toIso8601String(),
  },
);

// Log event
await securityService.logSecurityEvent('user_registered', {
  'userId': credential.user!.uid,
  'role': 'patient',
});
```

### Example 2: Real-time Appointment Dashboard
```dart
// In your widget
final realTimeService = RealTimeService();
final notificationService = NotificationService();

// Stream appointments
StreamBuilder<List<Appointment>>(
  stream: realTimeService.getPatientAppointmentsStream(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final appointments = snapshot.data!;
      return ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(appointment: appointments[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
);

// Stream notifications
StreamBuilder<int>(
  stream: notificationService.getUnreadCountStream(),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Badge(
      label: Text('$count'),
      child: Icon(Icons.notifications),
    );
  },
);
```

### Example 3: Create Appointment with Notifications
```dart
final apiService = ApiService();
final notificationService = NotificationService();
final realTimeService = RealTimeService();

// Create appointment
final appointment = Appointment(
  id: '',
  patientId: patientId,
  doctorId: doctorId,
  dateTime: appointmentDateTime,
  status: 'pending',
  notes: notes,
);

final appointmentId = await apiService.createAppointment(appointment);

// Send notification to patient
await notificationService.sendAppointmentReminder(
  userId: patientId,
  doctorName: doctorName,
  appointmentTime: appointmentDateTime,
  appointmentId: appointmentId,
);

// Send notification to doctor
await notificationService.createNotification(
  userId: doctorId,
  title: 'New Appointment Request',
  message: 'You have a new appointment request from $patientName',
  type: 'appointment',
  data: {'appointmentId': appointmentId},
);
```

---

## Best Practices

1. **Error Handling**: Always wrap service calls in try-catch blocks
   ```dart
   try {
     await apiService.createAppointment(appointment);
   } catch (e) {
     print('Error creating appointment: $e');
     // Show error to user
   }
   ```

2. **Loading States**: Show loading indicators during async operations
   ```dart
   setState(() => isLoading = true);
   try {
     await service.someOperation();
   } finally {
     setState(() => isLoading = false);
   }
   ```

3. **Stream Management**: Always dispose of stream subscriptions
   ```dart
   StreamSubscription? _subscription;
   
   void initState() {
     _subscription = realTimeService.getStream().listen((data) {
       // Handle data
     });
   }
   
   void dispose() {
     _subscription?.cancel();
     super.dispose();
   }
   ```

4. **Security**: Always validate user permissions before sensitive operations
   ```dart
   final canAccess = await securityService.canAccessPatientData(patientId);
   if (!canAccess) {
     throw Exception('Access denied');
   }
   // Proceed with operation
   ```

5. **Offline Support**: Handle network errors gracefully
   ```dart
   final isConnected = await realTimeService.checkConnection();
   if (!isConnected) {
     // Show offline message
     // Use cached data if available
   }
   ```

---

## Testing

Each service should have corresponding unit tests. Example:

```dart
// test/services/notification_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService', () {
    test('creates notification successfully', () async {
      final service = NotificationService();
      final id = await service.createNotification(
        userId: 'test_user',
        title: 'Test',
        message: 'Test message',
      );
      expect(id, isNotEmpty);
    });
  });
}
```

---

## Future Services (To Be Implemented)

- **TelemedicineService**: Agora RTC video call integration
- **AIService**: Health recommendation and symptom analysis
- **PrescriptionService**: Prescription management
- **AnalyticsService**: App usage tracking and reporting
- **CacheService**: Offline data caching
- **SettingsService**: App settings management
- **SupportService**: Help and support ticket management

---

## Contributing

When adding new services:
1. Create service file in `lib/services/`
2. Add documentation to this README
3. Create corresponding tests
4. Update PR_ORGANIZATION_PLAN.md if applicable
5. Ensure service follows existing patterns and conventions
