import 'env_config.dart';

class AppConfig {
  // Firebase Config - loaded from environment variables
  static String get apiKey => EnvConfig.firebaseApiKey;
  static String get authDomain => '${EnvConfig.firebaseProjectId}.firebaseapp.com';
  static String get projectId => EnvConfig.firebaseProjectId;
  static String get storageBucket => EnvConfig.firebaseStorageBucket;
  static String get messagingSenderId => EnvConfig.firebaseMessagingSenderId;
  static String get appId => EnvConfig.firebaseAppId;

  // Other app settings - loaded from environment variables
  static String get appName => EnvConfig.appName;
  static bool get enableNotifications => EnvConfig.enableNotifications;
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;

  // Agora configuration for video calls
  static String get agoraAppId => EnvConfig.agoraAppId;

  // API Keys for integrations
  static String? get openaiApiKey => EnvConfig.openaiApiKey;
  static String? get googleMapsApiKey => EnvConfig.googleMapsApiKey;
  static String? get stripePublishableKey => EnvConfig.stripePublishableKey;
  static String? get stripeSecretKey => EnvConfig.stripeSecretKey;

  // Environment checks
  static bool get isProduction => EnvConfig.isProduction;
  static bool get isDevelopment => EnvConfig.isDevelopment;
  static bool get isStaging => EnvConfig.isStaging;
  static String get environment => EnvConfig.appEnv;
}