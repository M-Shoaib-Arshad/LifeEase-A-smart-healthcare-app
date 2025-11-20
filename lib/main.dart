import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is ready
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Uses config from CLI
  );
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