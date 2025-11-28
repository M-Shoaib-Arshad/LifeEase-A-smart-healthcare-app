import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loader
/// Provides centralized access to environment variables loaded from .env file
class EnvConfig {
  /// Initialize the environment configuration
  /// Call this in main() before runApp()
  /// Validates required environment variables after loading
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      // Validate required environment variables
      validate();
    } catch (e) {
      if (e is EnvConfigException) {
        rethrow;
      }
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
  // Firebase Configuration (Required)
  // ===========================================
  
  /// Firebase API Key (required)
  static String get firebaseApiKey => get('FIREBASE_API_KEY');

  /// Firebase App ID (required)
  static String get firebaseAppId => get('FIREBASE_APP_ID');

  /// Firebase Messaging Sender ID (required)
  static String get firebaseMessagingSenderId => get('FIREBASE_MESSAGING_SENDER_ID');

  /// Firebase Project ID (required)
  static String get firebaseProjectId => get('FIREBASE_PROJECT_ID');

  /// Firebase Storage Bucket (required)
  static String get firebaseStorageBucket => get('FIREBASE_STORAGE_BUCKET');

  // iOS-specific Firebase settings (optional - only needed for iOS builds)
  static String? get firebaseIosApiKey => getOptional('FIREBASE_IOS_API_KEY');

  static String? get firebaseIosAppId => getOptional('FIREBASE_IOS_APP_ID');

  static String? get firebaseIosClientId => getOptional('FIREBASE_IOS_CLIENT_ID');

  static String? get firebaseIosBundleId => getOptional('FIREBASE_IOS_BUNDLE_ID');

  // ===========================================
  // Agora Configuration (Required)
  // ===========================================
  
  /// Agora App ID for video calls (required)
  static String get agoraAppId => get('AGORA_APP_ID');

  // ===========================================
  // API Keys (Optional - for future integrations)
  // ===========================================
  
  /// OpenAI API Key (optional)
  static String? get openaiApiKey => getOptional('OPENAI_API_KEY');

  /// Google Maps API Key (optional)
  static String? get googleMapsApiKey => getOptional('GOOGLE_MAPS_API_KEY');

  /// Stripe Publishable Key (optional)
  static String? get stripePublishableKey => getOptional('STRIPE_PUBLISHABLE_KEY');

  /// Stripe Secret Key (optional)
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
  /// Called automatically during init()
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
