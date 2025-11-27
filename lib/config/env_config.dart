import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loader
/// Provides centralized access to environment variables loaded from .env file
class EnvConfig {
  /// Initialize the environment configuration
  /// Call this in main() before runApp()
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // If .env file is not found, show a helpful error
      throw EnvConfigException(
        'Failed to load .env file. Please ensure a .env file exists in the project root. '
        'You can copy .env.example to .env and fill in your values. '
        'Error: $e',
      );
    }
  }

  /// Check if environment is properly loaded
  static bool get isLoaded => dotenv.isInitialized;

  /// Get environment variable with optional default value
  static String get(String key, {String? defaultValue}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      if (defaultValue != null) {
        return defaultValue;
      }
      throw EnvConfigException(
        'Environment variable $key is not set. '
        'Please check your .env file.',
      );
    }
    return value;
  }

  /// Get environment variable, returns null if not set
  static String? getOptional(String key) {
    return dotenv.env[key];
  }

  /// Get boolean environment variable
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true';
  }

  // ===========================================
  // Firebase Configuration
  // ===========================================
  
  /// Firebase API Key
  static String get firebaseApiKey => 
      get('FIREBASE_API_KEY', defaultValue: '');

  /// Firebase App ID
  static String get firebaseAppId => 
      get('FIREBASE_APP_ID', defaultValue: '');

  /// Firebase Messaging Sender ID
  static String get firebaseMessagingSenderId => 
      get('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');

  /// Firebase Project ID
  static String get firebaseProjectId => 
      get('FIREBASE_PROJECT_ID', defaultValue: '');

  /// Firebase Storage Bucket
  static String get firebaseStorageBucket => 
      get('FIREBASE_STORAGE_BUCKET', defaultValue: '');

  // iOS-specific Firebase settings
  static String get firebaseIosApiKey => 
      get('FIREBASE_IOS_API_KEY', defaultValue: '');

  static String get firebaseIosAppId => 
      get('FIREBASE_IOS_APP_ID', defaultValue: '');

  static String get firebaseIosClientId => 
      get('FIREBASE_IOS_CLIENT_ID', defaultValue: '');

  static String get firebaseIosBundleId => 
      get('FIREBASE_IOS_BUNDLE_ID', defaultValue: '');

  // ===========================================
  // Agora Configuration
  // ===========================================
  
  /// Agora App ID for video calls
  static String get agoraAppId => 
      get('AGORA_APP_ID', defaultValue: '');

  // ===========================================
  // API Keys (for future integrations)
  // ===========================================
  
  /// OpenAI API Key
  static String? get openaiApiKey => getOptional('OPENAI_API_KEY');

  /// Google Maps API Key
  static String? get googleMapsApiKey => getOptional('GOOGLE_MAPS_API_KEY');

  /// Stripe Publishable Key
  static String? get stripePublishableKey => getOptional('STRIPE_PUBLISHABLE_KEY');

  /// Stripe Secret Key
  static String? get stripeSecretKey => getOptional('STRIPE_SECRET_KEY');

  // ===========================================
  // Environment Settings
  // ===========================================
  
  /// Current environment (development, staging, production)
  static String get appEnv => 
      get('APP_ENV', defaultValue: 'development');

  /// Check if running in development mode
  static bool get isDevelopment => appEnv == 'development';

  /// Check if running in staging mode
  static bool get isStaging => appEnv == 'staging';

  /// Check if running in production mode
  static bool get isProduction => appEnv == 'production';

  // ===========================================
  // App Settings
  // ===========================================
  
  /// App name
  static String get appName => 
      get('APP_NAME', defaultValue: 'LifeEase');

  /// API Base URL
  static String get apiBaseUrl => 
      get('API_BASE_URL', defaultValue: 'https://your-backend-url.com');

  /// Whether notifications are enabled
  static bool get enableNotifications => 
      getBool('ENABLE_NOTIFICATIONS', defaultValue: true);

  /// Validate that all required environment variables are set
  static void validate() {
    final requiredVars = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_MESSAGING_SENDER_ID',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_STORAGE_BUCKET',
      'AGORA_APP_ID',
    ];

    final missingVars = <String>[];
    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        missingVars.add(varName);
      }
    }

    if (missingVars.isNotEmpty) {
      throw EnvConfigException(
        'Missing required environment variables: ${missingVars.join(', ')}. '
        'Please check your .env file.',
      );
    }
  }
}

/// Exception thrown when environment configuration is invalid
class EnvConfigException implements Exception {
  final String message;

  EnvConfigException(this.message);

  @override
  String toString() => 'EnvConfigException: $message';
}
