# 🚀 Quick Configuration Steps

Follow these steps to configure the LifeEase app:

## Option 1: Automated Setup (Recommended)

Run the setup script:

```bash
chmod +x setup.sh
./setup.sh
```

The script will:
- Check prerequisites
- Install Flutter dependencies
- Create .env file from template
- Verify Firebase configuration
- Install iOS pods (on macOS)

## Option 2: Manual Setup

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Configure Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit with your API keys
nano .env
```

Add your Agora App ID:
```env
AGORA_APP_ID=your_actual_agora_app_id
```

### Step 3: Configure Firebase

**Option A: Using FlutterFire CLI (Recommended)**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase
flutterfire configure
```

**Option B: Manual Configuration**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Download `google-services.json` → place in `android/app/`
3. Download `GoogleService-Info.plist` → place in `ios/Runner/`

### Step 4: Enable Firebase Services

In Firebase Console:
1. **Authentication** → Enable Email/Password
2. **Firestore Database** → Create database (test mode)
3. **Storage** → Enable storage
4. **Cloud Messaging** → Enable FCM

### Step 5: Get Agora App ID

1. Sign up at [Agora.io](https://www.agora.io/)
2. Create a new project
3. Copy your App ID
4. Add to `.env` file

### Step 6: Platform-Specific Setup

**For iOS (on macOS only):**
```bash
cd ios
pod install
cd ..
```

**For Android:**
Already configured via `google-services.json`

### Step 7: Run the App

```bash
flutter run
```

## 📚 Complete Documentation

For detailed instructions, see:
- [`CONFIGURATION_GUIDE.md`](CONFIGURATION_GUIDE.md) - Complete setup guide
- [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) - Firebase-specific setup
- [`DEVELOPER_QUICK_START.md`](DEVELOPER_QUICK_START.md) - Development guide

## ✅ Configuration Checklist

- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] `.env` file created and configured
- [ ] Agora App ID added to `.env`
- [ ] Firebase project created
- [ ] Firebase config files in place
- [ ] Firebase Authentication enabled
- [ ] Firestore Database created
- [ ] Firebase Storage enabled
- [ ] iOS pods installed (if on macOS)
- [ ] App runs successfully (`flutter run`)

## 🔑 Required Services

### Firebase (Required)
- **Cost**: Free tier available
- **Setup**: ~15 minutes
- **Get started**: https://console.firebase.google.com

### Agora (Required for video calls)
- **Cost**: 10,000 free minutes/month
- **Setup**: ~5 minutes
- **Get started**: https://console.agora.io

### OpenAI (Optional - for AI features)
- **Cost**: Pay per use
- **Setup**: ~2 minutes
- **Get started**: https://platform.openai.com

## 🐛 Common Issues

### Issue: Firebase not initialized
**Solution**: Run `flutterfire configure`

### Issue: Agora not working
**Solution**: Check `.env` file has correct App ID

### Issue: Build fails
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Permission denied
**Solution**: Check AndroidManifest.xml and Info.plist have required permissions

## 📞 Need Help?

- Check the [CONFIGURATION_GUIDE.md](CONFIGURATION_GUIDE.md) for detailed instructions
- Review [Troubleshooting section](CONFIGURATION_GUIDE.md#-troubleshooting)
- Open an issue on GitHub

## 🎯 Next Steps

After configuration:
1. Test authentication (sign up, login)
2. Test appointment booking
3. Test video call feature
4. Review security rules
5. Deploy to Firebase

---

**Ready to start?** Run `./setup.sh` or follow the manual steps above! 🚀
