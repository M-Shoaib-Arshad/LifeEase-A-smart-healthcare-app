# LifeEase Environment Configuration & API Integration Guide

This guide provides step-by-step instructions for setting up environment configuration and integrating with external APIs and services in the LifeEase healthcare application.

## Table of Contents

1. [Environment Setup](#environment-setup)
2. [Firebase Integration](#firebase-integration)
3. [Agora Video Calling Integration](#agora-video-calling-integration)
4. [OpenAI Integration (AI Features)](#openai-integration-ai-features)
5. [Google Maps Integration](#google-maps-integration)
6. [Stripe Payment Integration](#stripe-payment-integration)
7. [Troubleshooting](#troubleshooting)

---

## Environment Setup

### Step 1: Create Your .env File

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` in your editor and fill in the required values (see sections below for each service).

3. **Important**: Never commit your `.env` file to version control. It's already in `.gitignore`.

### Step 2: Environment Configuration Structure

The app uses `flutter_dotenv` to load environment variables. The configuration is loaded in `main.dart` before the app starts:

```dart
// In main.dart
await EnvConfig.init();
```

Configuration values are accessed through:
- `EnvConfig` class (`lib/config/env_config.dart`) - Direct access to environment variables
- `AppConfig` class (`lib/config/app_config.dart`) - Application-level configuration

### Step 3: Available Environments

Set `APP_ENV` to one of:
- `development` - For local development
- `staging` - For staging/testing environment
- `production` - For production deployment

---

## Firebase Integration

Firebase is used for authentication, database (Firestore), and storage.

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Enable Google Analytics (optional but recommended)

### Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android
2. Enter your Android package name: `com.shoaib.lifeease`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### Step 3: Add iOS App

1. In Firebase Console, click "Add app" → iOS
2. Enter your iOS bundle ID: `com.shoaib.lifeease`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### Step 4: Enable Authentication

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable the following providers:
   - Email/Password
   - Google Sign-In

### Step 5: Set Up Firestore

1. Go to Firebase Console → Firestore Database
2. Create database in production or test mode
3. Set up security rules in `firestore.rules`

### Step 6: Update .env File

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_from_google_services_json
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project_id.appspot.com

# iOS-specific (from GoogleService-Info.plist)
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_IOS_CLIENT_ID=your_ios_client_id
FIREBASE_IOS_BUNDLE_ID=com.shoaib.lifeease
```

### Where to Find Firebase Values

| Value | Location |
|-------|----------|
| `FIREBASE_API_KEY` | `google-services.json` → `client.api_key.current_key` |
| `FIREBASE_APP_ID` | `google-services.json` → `client.client_info.mobilesdk_app_id` |
| `FIREBASE_MESSAGING_SENDER_ID` | `google-services.json` → `project_info.project_number` |
| `FIREBASE_PROJECT_ID` | `google-services.json` → `project_info.project_id` |
| `FIREBASE_STORAGE_BUCKET` | `google-services.json` → `project_info.storage_bucket` |

---

## Agora Video Calling Integration

Agora is used for telemedicine video consultations.

### Step 1: Create Agora Account

1. Go to [Agora Console](https://console.agora.io/)
2. Sign up for a free account
3. Verify your email

### Step 2: Create Agora Project

1. In Agora Console, click "Create New Project"
2. Enter project name: `LifeEase`
3. Choose "Secured mode: APP ID + Token"
4. Click "Submit"

### Step 3: Get Your App ID

1. In your project, find the "App ID" field
2. Copy the App ID (32 character string)

### Step 4: Update .env File

```env
AGORA_APP_ID=your_32_character_agora_app_id
```

### Step 5: Token Generation (Production)

For production, you need to generate tokens server-side:

1. Set up a backend server
2. Install Agora token generation library
3. Generate tokens with channel name and user ID
4. Pass tokens to the app for each video call

Example token generation (Node.js):
```javascript
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

function generateToken(channelName, uid) {
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;
  const expirationTimeInSeconds = 3600;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
  
  return RtcTokenBuilder.buildTokenWithUid(
    appId, appCertificate, channelName, uid, RtcRole.PUBLISHER, privilegeExpiredTs
  );
}
```

### Step 6: Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video consultations</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video consultations</string>
```

---

## OpenAI Integration (AI Features)

OpenAI is used for symptom analysis and health recommendations.

### Step 1: Create OpenAI Account

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in
3. Navigate to API Keys section

### Step 2: Generate API Key

1. Click "Create new secret key"
2. Give it a name: `LifeEase-App`
3. Copy the key immediately (it won't be shown again)

### Step 3: Update .env File

```env
OPENAI_API_KEY=sk-your_openai_api_key_here
```

### Step 4: Usage in App

The AI service (`lib/services/ai_service.dart`) uses the OpenAI API for:
- Symptom triage
- Doctor recommendations
- Health chatbot responses

Example API call structure:
```dart
// Get OpenAI API key from environment
final apiKey = EnvConfig.openaiApiKey;

// Make API request
final response = await http.post(
  Uri.parse('https://api.openai.com/v1/chat/completions'),
  headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'model': 'gpt-3.5-turbo',
    'messages': [
      {'role': 'system', 'content': 'You are a medical AI assistant.'},
      {'role': 'user', 'content': prompt},
    ],
    'max_tokens': 500,
  }),
);
```

### Step 5: Rate Limiting and Cost Management

- Implement request caching to reduce API calls
- Set up usage limits in OpenAI dashboard
- Monitor usage and costs regularly

---

## Google Maps Integration

Google Maps is used for finding nearby doctors and navigation.

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable billing (required for Maps API)

### Step 2: Enable Maps APIs

Enable the following APIs in your project:
1. Maps SDK for Android
2. Maps SDK for iOS
3. Geocoding API
4. Places API

### Step 3: Create API Key

1. Go to APIs & Services → Credentials
2. Click "Create Credentials" → "API Key"
3. Restrict the key to your app package/bundle ID

### Step 4: Update .env File

```env
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

### Step 5: Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="${GOOGLE_MAPS_API_KEY}" />
    </application>
</manifest>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## Stripe Payment Integration

Stripe is used for processing appointment payments.

### Step 1: Create Stripe Account

1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Sign up for an account
3. Complete business verification

### Step 2: Get API Keys

1. Go to Developers → API Keys
2. Copy both keys:
   - Publishable key (starts with `pk_`)
   - Secret key (starts with `sk_`)

### Step 3: Update .env File

```env
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key
```

### Step 4: Backend Setup (Required)

Stripe requires a backend server for secure payment processing:

1. **Create Payment Intent** (Backend endpoint):
```javascript
// Node.js example
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/create-payment-intent', async (req, res) => {
  const { amount, currency } = req.body;
  
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount, // in cents
    currency: currency || 'usd',
  });
  
  res.json({ clientSecret: paymentIntent.client_secret });
});
```

2. **Flutter App** (Client-side):
```dart
// Initialize Stripe
Stripe.publishableKey = EnvConfig.stripePublishableKey!;

// Get client secret from your backend
final response = await http.post('/create-payment-intent', body: {...});
final clientSecret = jsonDecode(response.body)['clientSecret'];

// Present payment sheet
await Stripe.instance.initPaymentSheet(
  paymentSheetParameters: SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    merchantDisplayName: 'LifeEase',
  ),
);
await Stripe.instance.presentPaymentSheet();
```

### Step 5: Test vs Production

- Use `pk_test_` and `sk_test_` keys for testing
- Use `pk_live_` and `sk_live_` keys for production
- Test with [Stripe test card numbers](https://stripe.com/docs/testing)

---

## Troubleshooting

### Environment Configuration Issues

**Problem**: App crashes on startup with "EnvConfigException"
- **Solution**: Ensure `.env` file exists and contains all required variables

**Problem**: Environment variables are empty
- **Solution**: Check that `.env` is listed in `pubspec.yaml` assets

### Firebase Issues

**Problem**: Firebase initialization fails
- **Solution**: Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations

**Problem**: Authentication not working
- **Solution**: Enable the sign-in methods in Firebase Console

### Agora Issues

**Problem**: Video call not connecting
- **Solution**: 
  1. Verify App ID is correct
  2. Check camera/microphone permissions
  3. Ensure both users are on the same channel

**Problem**: Token errors
- **Solution**: Generate fresh tokens server-side (tokens expire)

### OpenAI Issues

**Problem**: API returns 401 Unauthorized
- **Solution**: Check API key is valid and has credits

**Problem**: Rate limit exceeded
- **Solution**: Implement request caching and rate limiting

### Google Maps Issues

**Problem**: Map shows blank or grey tiles
- **Solution**: 
  1. Verify API key is correct
  2. Enable billing on Google Cloud
  3. Enable required APIs

### Stripe Issues

**Problem**: Payment fails with "Invalid API Key"
- **Solution**: Ensure you're using correct test/production keys

**Problem**: Payment sheet doesn't appear
- **Solution**: Check client secret is being fetched correctly from backend

---

## Security Best Practices

1. **Never commit `.env` to version control**
2. **Use different API keys for development and production**
3. **Implement server-side token generation for Agora**
4. **Process payments server-side, never expose secret keys in app**
5. **Rotate API keys periodically**
6. **Monitor API usage for unusual activity**
7. **Use API key restrictions where possible**

---

## Quick Reference: Required Environment Variables

| Variable | Required | Service |
|----------|----------|---------|
| `FIREBASE_API_KEY` | Yes | Firebase |
| `FIREBASE_APP_ID` | Yes | Firebase |
| `FIREBASE_MESSAGING_SENDER_ID` | Yes | Firebase |
| `FIREBASE_PROJECT_ID` | Yes | Firebase |
| `FIREBASE_STORAGE_BUCKET` | Yes | Firebase |
| `AGORA_APP_ID` | Yes | Agora Video |
| `APP_ENV` | Yes | App Config |
| `OPENAI_API_KEY` | No | AI Features |
| `GOOGLE_MAPS_API_KEY` | No | Maps |
| `STRIPE_PUBLISHABLE_KEY` | No | Payments |
| `STRIPE_SECRET_KEY` | No | Payments |

---

## Support

For issues with:
- **Firebase**: [Firebase Documentation](https://firebase.google.com/docs)
- **Agora**: [Agora Documentation](https://docs.agora.io/)
- **OpenAI**: [OpenAI API Docs](https://platform.openai.com/docs)
- **Google Maps**: [Google Maps Platform](https://developers.google.com/maps)
- **Stripe**: [Stripe Documentation](https://stripe.com/docs)
