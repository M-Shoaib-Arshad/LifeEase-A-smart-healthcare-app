import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/appointment_provider.dart'; // New provider
import 'providers/health_record_provider.dart'; // New provider
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'LifeEase', // Updated to match your app name
      theme: appTheme,
      routerConfig: router,
    );
  }
}