# Quick Start Guide for Contributors

## Getting Started with LifeEase Development

This guide helps you quickly understand the project structure and start contributing.

## 📁 Project Structure

```
LifeEase/
├── lib/
│   ├── config/           # App configuration
│   ├── models/           # Data models (6 models)
│   ├── providers/        # State management (4 providers)
│   ├── routes/           # Navigation routes
│   ├── screens/          # UI screens (28 screens)
│   │   ├── auth/         # Authentication (5 screens)
│   │   ├── patient/      # Patient features (14 screens)
│   │   ├── doctor/       # Doctor features (6 screens)
│   │   ├── admin/        # Admin features (3 screens)
│   │   └── common/       # Shared screens (2 screens)
│   ├── services/         # Business logic (7 services)
│   ├── utils/            # Utilities and constants
│   └── widgets/          # Reusable widgets
├── test/                 # Unit and widget tests
└── docs/                 # Documentation
```

## 🚀 Key Documentation Files

Start with these files to understand the project:

1. **README.md** - Project overview and setup instructions
2. **PR_ORGANIZATION_PLAN.md** - Development roadmap and PR strategy
3. **CURRENT_BRANCH_GUIDE.md** - Current branch specific information
4. **lib/services/README.md** - Services documentation with examples
5. **IMPLEMENTATION_SUMMARY.md** - Recent implementation details

## 🔧 Available Services

### Core Services (Already Implemented)
- **AuthService** - Firebase authentication
- **ApiService** - Firestore database operations
- **UserService** - User profile management
- **StorageService** - File uploads

### Infrastructure Services (Recently Added)
- **NotificationService** - In-app notifications and reminders
- **RealTimeService** - Firestore real-time data streams
- **SecurityService** - RBAC and data protection

### Future Services (To Be Implemented)
- TelemedicineService - Video calling (Agora)
- AIService - Health recommendations
- PrescriptionService - Prescription management
- AnalyticsService - Usage tracking
- CacheService - Offline support

## 🔄 State Management

Using Provider pattern:

```dart
// Available Providers
- UserProvider          // User state and authentication
- AppointmentProvider   // Appointment management
- HealthRecordProvider  // Health records
- NotificationProvider  // Notifications and alerts
```

## 🎨 User Roles & Permissions

### Three User Roles
1. **Patient** - Book appointments, track health, access records
2. **Doctor** - Manage appointments, view patient records, consultations
3. **Admin** - User management, content moderation, analytics

### Permission System
- 11 distinct permissions managed by SecurityService
- Role-based access control (RBAC)
- See `lib/services/security_service.dart` for details

## 📱 Screen Categories

### Authentication Screens (5)
- Splash Screen
- Login Screen (with role selection)
- Signup Screen
- OTP Verification
- Forgot Password

### Patient Screens (14)
- Patient Home Dashboard
- Profile Setup/View
- Doctor Search/List
- Doctor Profile View
- Appointment Booking/Confirmation/History
- Health Tracker Dashboard/Input
- Medical Records
- Medication Reminders
- Telemedicine Call

### Doctor Screens (6)
- Doctor Home Dashboard
- Doctor Profile Setup/View
- Appointment Management
- Patient Details View
- Telemedicine Consultation

### Admin Screens (3)
- Admin Dashboard
- User Management
- Content Management

## 🔨 Development Workflow

### 1. Setup Environment
```bash
# Install Flutter
flutter doctor

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 2. Create a New Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 3. Follow the Service Pattern
```dart
// 1. Create service class
class YourService {
  // Business logic here
}

// 2. Create provider if needed
class YourProvider with ChangeNotifier {
  final YourService _service = YourService();
  // State management here
}

// 3. Use in screens
final provider = Provider.of<YourProvider>(context);
```

### 4. Write Tests
```dart
// Unit test
test('service method works', () async {
  final service = YourService();
  final result = await service.someMethod();
  expect(result, expectedValue);
});
```

### 5. Update Documentation
- Update relevant README files
- Add code comments
- Update IMPLEMENTATION_SUMMARY.md if major changes

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/your_service_test.dart

# Run with coverage
flutter test --coverage
```

### Test Categories
- **Unit Tests** - Test individual functions/methods
- **Widget Tests** - Test UI components
- **Integration Tests** - Test complete user flows

## 🎯 Common Development Tasks

### Adding a New Screen
1. Create screen file in appropriate folder
2. Add route to `lib/routes/app_routes.dart`
3. Add navigation from existing screens
4. Add tests
5. Update documentation

### Adding a New Service
1. Create service file in `lib/services/`
2. Implement service methods
3. Add to `lib/services/README.md`
4. Create provider if state management needed
5. Add unit tests
6. Update IMPLEMENTATION_SUMMARY.md

### Adding a New Model
1. Create model file in `lib/models/`
2. Add `toMap()` and `fromMap()` methods
3. Add `copyWith()` method if needed
4. Document fields and usage

### Integrating Real-time Updates
```dart
// Use RealTimeService for live data
StreamBuilder<List<Appointment>>(
  stream: RealTimeService().getPatientAppointmentsStream(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return YourWidget(data: snapshot.data!);
    }
    return LoadingWidget();
  },
);
```

### Using Notifications
```dart
// Send notification
await NotificationService().createNotification(
  userId: 'user123',
  title: 'Title',
  message: 'Message',
  type: 'info',
);

// Subscribe to notifications
Provider.of<NotificationProvider>(context)
  .subscribeToNotifications();
```

### Implementing Security
```dart
// Check permissions
final security = SecurityService();
if (await security.hasPermission(Permission.viewPatientRecords)) {
  // Allow access
}

// Validate input
final sanitized = security.sanitizeInput(userInput);
```

## 📋 PR Checklist

Before submitting a PR:

- [ ] Code follows project conventions
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] Documentation updated
- [ ] No lint errors
- [ ] Security considerations addressed
- [ ] Performance implications considered
- [ ] PR description is clear and detailed

## 🐛 Common Issues & Solutions

### Issue: Firebase not initialized
**Solution:** Ensure `Firebase.initializeApp()` is called in `main.dart`

### Issue: Provider not found
**Solution:** Wrap your widget tree with the appropriate `Provider` or `MultiProvider`

### Issue: Stream not updating
**Solution:** Check Firestore security rules and ensure data is actually changing

### Issue: Permission denied
**Solution:** Check user role and permissions using `SecurityService`

## 📞 Getting Help

1. Check existing documentation first
2. Search closed issues on GitHub
3. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

## 🔗 Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 📚 Learning Resources

### For Flutter Beginners
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Provider State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt/simple)

### For Firebase
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)

### For Healthcare Apps
- HIPAA compliance considerations
- Medical data privacy best practices
- Healthcare UX/UI patterns

## 🎓 Code Style Guidelines

### Naming Conventions
- Classes: `PascalCase` (e.g., `UserService`)
- Variables/Methods: `camelCase` (e.g., `getUserProfile`)
- Constants: `camelCase` with const (e.g., `const maxRetries = 3`)
- Files: `snake_case.dart` (e.g., `user_service.dart`)

### Code Organization
- One class per file
- Group related functionality
- Keep methods focused and small
- Use meaningful names

### Comments
- Explain "why" not "what"
- Document public APIs
- Add TODO comments for future work

## 🚦 Development Stages

### Stage 1: Foundation (Current)
- ✅ Project setup
- ✅ Authentication screens
- ✅ Core services
- ✅ Basic providers

### Stage 2: Core Features (Next)
- Patient features integration
- Doctor features integration
- Real-time updates
- Notifications

### Stage 3: Advanced Features
- Telemedicine integration
- AI recommendations
- Analytics
- Offline support

### Stage 4: Polish
- Performance optimization
- Comprehensive testing
- Documentation completion
- Production deployment

## 🎯 Contributing Focus Areas

Currently accepting contributions for:

1. **Testing** - Unit tests for services
2. **Documentation** - API documentation, examples
3. **UI/UX** - Screen improvements, animations
4. **Integration** - Connect services to screens
5. **Performance** - Optimization opportunities

## 📝 Notes

- Always test on multiple screen sizes
- Consider accessibility (screen readers, contrast)
- Think mobile-first
- Keep security in mind
- Write clean, maintainable code

---

**Happy Coding! 🚀**

For detailed information, refer to the main documentation files in the repository.
