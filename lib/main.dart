import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'config/env_config.dart';
import 'providers/user_provider.dart';
import 'providers/appointment_provider.dart'; // New provider
import 'providers/health_record_provider.dart'; // New provider
import 'providers/notification_provider.dart'; // Notification provider
import 'providers/theme_provider.dart'; // Theme provider
import 'providers/settings_provider.dart'; // Settings provider
import 'routes/app_routes.dart';
import 'utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

/// Background message handler for FCM - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background handling
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Handling background message: ${message.messageId}');
  // Background messages are automatically displayed by FCM
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is ready
  
  // Initialize environment configuration
  try {
    await EnvConfig.init();
  } catch (e) {
    // Show error if .env file is missing or invalid
    runApp(EnvConfigErrorApp(error: e.toString()));
    return;
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Uses config from CLI
  );

  // Set up background message handler for FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()), // Added
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()), // Added
        ChangeNotifierProvider(create: (_) => NotificationProvider()), // Added
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Added
        ChangeNotifierProvider(create: (_) => SettingsProvider()), // Added
      ],
      child: const MyApp(),
    ),
  );
}

/// Error app shown when environment configuration fails
class EnvConfigErrorApp extends StatelessWidget {
  final String error;
  
  const EnvConfigErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 24),
                Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load environment configuration.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please ensure a .env file exists in the project root with all required values. '
                  'You can copy .env.example to .env and fill in your configuration.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'LifeEase', // Updated to match your app name
          theme: appTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}