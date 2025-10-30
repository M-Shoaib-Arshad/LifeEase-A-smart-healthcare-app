class AppConfig {
  // Firebase Config (from google-services.json)
  static const String apiKey = 'AIzaSyAE2wuVwFjkjE37Y0qH96GH3mqbdaB0I_0';
  static const String authDomain = 'lifeease-smart-healthcare.firebaseapp.com'; // Not used on Android
  static const String projectId = 'lifeease-smart-healthcare';
  static const String storageBucket = 'lifeease-smart-healthcare.firebasestorage.app';
  static const String messagingSenderId = '188575701098';
  static const String appId = '1:188575701098:android:0d1aa7f5376919d5135213';

  // Other app settings
  static const String appName = 'LifeEase';
  static const bool enableNotifications = true;
  static const String apiBaseUrl = 'https://your-backend-url.com';

  // Environment check
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}