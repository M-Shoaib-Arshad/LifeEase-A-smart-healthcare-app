import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:LifeEase/config/env_config.dart';

void main() {
  group('EnvConfig', () {
    setUp(() {
      // Reset dotenv before each test
      dotenv.loadFromString(envString: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=test_app_id
FIREBASE_MESSAGING_SENDER_ID=test_sender_id
FIREBASE_PROJECT_ID=test_project_id
FIREBASE_STORAGE_BUCKET=test_bucket
AGORA_APP_ID=test_agora_id
APP_ENV=development
APP_NAME=TestApp
API_BASE_URL=https://test.com
ENABLE_NOTIFICATIONS=true
''');
    });

    group('isLoaded', () {
      test('should return true after initialization', () {
        expect(EnvConfig.isLoaded, isTrue);
      });
    });

    group('get', () {
      test('should return value when environment variable exists', () {
        final value = EnvConfig.get('FIREBASE_API_KEY');
        expect(value, 'test_api_key');
      });

      test('should return default value when environment variable is missing', () {
        final value = EnvConfig.get('MISSING_VAR', defaultValue: 'default_value');
        expect(value, 'default_value');
      });

      test('should throw exception when required variable is missing and no default', () {
        expect(
          () => EnvConfig.get('MISSING_VAR'),
          throwsA(isA<EnvConfigException>()),
        );
      });
    });

    group('getOptional', () {
      test('should return value when environment variable exists', () {
        final value = EnvConfig.getOptional('FIREBASE_API_KEY');
        expect(value, 'test_api_key');
      });

      test('should return null when environment variable is missing', () {
        final value = EnvConfig.getOptional('MISSING_VAR');
        expect(value, isNull);
      });
    });

    group('getBool', () {
      test('should return true when value is "true"', () {
        final value = EnvConfig.getBool('ENABLE_NOTIFICATIONS');
        expect(value, isTrue);
      });

      test('should return default value when variable is missing', () {
        final value = EnvConfig.getBool('MISSING_VAR', defaultValue: true);
        expect(value, isTrue);
      });

      test('should return false as default when variable is missing', () {
        final value = EnvConfig.getBool('MISSING_VAR');
        expect(value, isFalse);
      });
    });

    group('Firebase Configuration', () {
      test('should return Firebase API key', () {
        expect(EnvConfig.firebaseApiKey, 'test_api_key');
      });

      test('should return Firebase App ID', () {
        expect(EnvConfig.firebaseAppId, 'test_app_id');
      });

      test('should return Firebase Messaging Sender ID', () {
        expect(EnvConfig.firebaseMessagingSenderId, 'test_sender_id');
      });

      test('should return Firebase Project ID', () {
        expect(EnvConfig.firebaseProjectId, 'test_project_id');
      });

      test('should return Firebase Storage Bucket', () {
        expect(EnvConfig.firebaseStorageBucket, 'test_bucket');
      });
    });

    group('Agora Configuration', () {
      test('should return Agora App ID', () {
        expect(EnvConfig.agoraAppId, 'test_agora_id');
      });
    });

    group('Environment Settings', () {
      test('should return app environment', () {
        expect(EnvConfig.appEnv, 'development');
      });

      test('should return true for isDevelopment when in development mode', () {
        expect(EnvConfig.isDevelopment, isTrue);
      });

      test('should return false for isProduction when in development mode', () {
        expect(EnvConfig.isProduction, isFalse);
      });

      test('should return false for isStaging when in development mode', () {
        expect(EnvConfig.isStaging, isFalse);
      });
    });

    group('App Settings', () {
      test('should return app name', () {
        expect(EnvConfig.appName, 'TestApp');
      });

      test('should return API base URL', () {
        expect(EnvConfig.apiBaseUrl, 'https://test.com');
      });

      test('should return notifications enabled', () {
        expect(EnvConfig.enableNotifications, isTrue);
      });
    });

    group('validate', () {
      test('should not throw when all required variables are set', () {
        expect(() => EnvConfig.validate(), returnsNormally);
      });

      test('should throw when required variable is missing', () {
        dotenv.loadFromString(envString: '''
FIREBASE_API_KEY=test_api_key
''');
        
        expect(
          () => EnvConfig.validate(),
          throwsA(isA<EnvConfigException>()),
        );
      });
    });

    group('Production environment', () {
      test('should detect production environment', () {
        dotenv.loadFromString(envString: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=test_app_id
FIREBASE_MESSAGING_SENDER_ID=test_sender_id
FIREBASE_PROJECT_ID=test_project_id
FIREBASE_STORAGE_BUCKET=test_bucket
AGORA_APP_ID=test_agora_id
APP_ENV=production
''');
        
        expect(EnvConfig.isProduction, isTrue);
        expect(EnvConfig.isDevelopment, isFalse);
        expect(EnvConfig.isStaging, isFalse);
      });
    });

    group('Staging environment', () {
      test('should detect staging environment', () {
        dotenv.loadFromString(envString: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=test_app_id
FIREBASE_MESSAGING_SENDER_ID=test_sender_id
FIREBASE_PROJECT_ID=test_project_id
FIREBASE_STORAGE_BUCKET=test_bucket
AGORA_APP_ID=test_agora_id
APP_ENV=staging
''');
        
        expect(EnvConfig.isStaging, isTrue);
        expect(EnvConfig.isDevelopment, isFalse);
        expect(EnvConfig.isProduction, isFalse);
      });
    });

    group('Optional API keys', () {
      test('should return null for missing OpenAI API key', () {
        expect(EnvConfig.openaiApiKey, isNull);
      });

      test('should return null for missing Google Maps API key', () {
        expect(EnvConfig.googleMapsApiKey, isNull);
      });

      test('should return null for missing Stripe keys', () {
        expect(EnvConfig.stripePublishableKey, isNull);
        expect(EnvConfig.stripeSecretKey, isNull);
      });

      test('should return null for missing iOS-specific Firebase keys', () {
        expect(EnvConfig.firebaseIosApiKey, isNull);
        expect(EnvConfig.firebaseIosAppId, isNull);
        expect(EnvConfig.firebaseIosClientId, isNull);
        expect(EnvConfig.firebaseIosBundleId, isNull);
      });

      test('should return OpenAI API key when set', () {
        dotenv.loadFromString(envString: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=test_app_id
FIREBASE_MESSAGING_SENDER_ID=test_sender_id
FIREBASE_PROJECT_ID=test_project_id
FIREBASE_STORAGE_BUCKET=test_bucket
AGORA_APP_ID=test_agora_id
OPENAI_API_KEY=sk-test123
''');
        
        expect(EnvConfig.openaiApiKey, 'sk-test123');
      });

      test('should return iOS Firebase keys when set', () {
        dotenv.loadFromString(envString: '''
FIREBASE_API_KEY=test_api_key
FIREBASE_APP_ID=test_app_id
FIREBASE_MESSAGING_SENDER_ID=test_sender_id
FIREBASE_PROJECT_ID=test_project_id
FIREBASE_STORAGE_BUCKET=test_bucket
AGORA_APP_ID=test_agora_id
FIREBASE_IOS_API_KEY=ios_api_key
FIREBASE_IOS_APP_ID=ios_app_id
FIREBASE_IOS_CLIENT_ID=ios_client_id
FIREBASE_IOS_BUNDLE_ID=com.example.app
''');
        
        expect(EnvConfig.firebaseIosApiKey, 'ios_api_key');
        expect(EnvConfig.firebaseIosAppId, 'ios_app_id');
        expect(EnvConfig.firebaseIosClientId, 'ios_client_id');
        expect(EnvConfig.firebaseIosBundleId, 'com.example.app');
      });
    });
  });

  group('EnvConfigException', () {
    test('should include message in toString', () {
      final exception = EnvConfigException('Test error message');
      expect(exception.toString(), contains('Test error message'));
      expect(exception.toString(), contains('EnvConfigException'));
    });
  });
}
