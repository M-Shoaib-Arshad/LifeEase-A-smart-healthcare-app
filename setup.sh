#!/bin/bash

# LifeEase Quick Setup Script
# This script helps you set up the LifeEase application

echo "======================================"
echo "LifeEase Configuration Setup"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "ℹ $1"
}

# Check prerequisites
echo "Checking prerequisites..."
echo ""

# Check Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    print_success "Flutter is installed: $FLUTTER_VERSION"
else
    print_error "Flutter is not installed"
    echo "  Install from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Firebase CLI
if command -v firebase &> /dev/null; then
    print_success "Firebase CLI is installed"
else
    print_warning "Firebase CLI is not installed (optional but recommended)"
    echo "  Install with: npm install -g firebase-tools"
fi

# Check Node.js and npm
if command -v node &> /dev/null; then
    print_success "Node.js is installed"
else
    print_warning "Node.js is not installed (needed for Firebase CLI)"
fi

echo ""
echo "======================================"
echo "Step 1: Flutter Dependencies"
echo "======================================"
echo ""

read -p "Install Flutter dependencies? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Running flutter pub get..."
    flutter pub get
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
fi

echo ""
echo "======================================"
echo "Step 2: Environment Configuration"
echo "======================================"
echo ""

if [ -f ".env" ]; then
    print_warning ".env file already exists"
    read -p "Overwrite with template? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp .env.example .env
        print_success "Created .env from template"
    fi
else
    cp .env.example .env
    print_success "Created .env from template"
fi

echo ""
print_info "Please edit .env file with your actual API keys:"
echo "  - AGORA_APP_ID (required for video calls)"
echo "  - OPENAI_API_KEY (optional, for AI features)"
echo ""

read -p "Do you want to edit .env now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v nano &> /dev/null; then
        nano .env
    elif command -v vim &> /dev/null; then
        vim .env
    elif command -v vi &> /dev/null; then
        vi .env
    else
        print_warning "No text editor found. Please edit .env manually"
        echo "  Run: nano .env"
    fi
fi

echo ""
echo "======================================"
echo "Step 3: Firebase Configuration"
echo "======================================"
echo ""

print_info "Firebase configuration files:"
if [ -f "android/app/google-services.json" ]; then
    print_success "android/app/google-services.json exists"
else
    print_error "android/app/google-services.json NOT found"
    echo "  Download from Firebase Console and place in android/app/"
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    print_success "ios/Runner/GoogleService-Info.plist exists"
else
    print_warning "ios/Runner/GoogleService-Info.plist NOT found"
    echo "  Download from Firebase Console and place in ios/Runner/"
fi

if [ -f "lib/firebase_options.dart" ]; then
    print_success "lib/firebase_options.dart exists"
else
    print_warning "lib/firebase_options.dart NOT found"
    read -p "Run 'flutterfire configure' now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v flutterfire &> /dev/null; then
            flutterfire configure
        else
            print_error "FlutterFire CLI not installed"
            echo "  Install with: dart pub global activate flutterfire_cli"
        fi
    fi
fi

echo ""
echo "======================================"
echo "Step 4: Platform Setup"
echo "======================================"
echo ""

# iOS setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "Install iOS pods? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing iOS pods..."
        cd ios
        pod install
        cd ..
        if [ $? -eq 0 ]; then
            print_success "iOS pods installed"
        else
            print_error "Failed to install iOS pods"
        fi
    fi
else
    print_info "Skipping iOS setup (not on macOS)"
fi

echo ""
echo "======================================"
echo "Step 5: Verify Configuration"
echo "======================================"
echo ""

print_info "Configuration checklist:"
echo ""

# Check .env file
if [ -f ".env" ]; then
    print_success ".env file exists"
    
    # Check if AGORA_APP_ID is set
    if grep -q "AGORA_APP_ID=your_agora_app_id_here" .env; then
        print_warning "AGORA_APP_ID not configured in .env"
    else
        print_success "AGORA_APP_ID is configured"
    fi
else
    print_error ".env file missing"
fi

# Check Firebase
if [ -f "lib/firebase_options.dart" ]; then
    print_success "Firebase configured"
else
    print_error "Firebase not configured"
fi

# Check pubspec
if [ -f "pubspec.yaml" ]; then
    print_success "pubspec.yaml exists"
else
    print_error "pubspec.yaml missing"
fi

echo ""
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""

print_info "Next steps:"
echo "  1. Edit .env file with your Agora App ID"
echo "  2. Verify Firebase configuration in Firebase Console"
echo "  3. Run: flutter run"
echo ""

print_info "Helpful commands:"
echo "  flutter run              - Run the app"
echo "  flutter doctor           - Check Flutter setup"
echo "  flutter clean            - Clean build files"
echo "  firebase login           - Login to Firebase"
echo "  flutterfire configure    - Configure Firebase"
echo ""

print_info "Documentation:"
echo "  CONFIGURATION_GUIDE.md   - Complete setup guide"
echo "  FIREBASE_SETUP.md        - Firebase-specific setup"
echo "  DEVELOPER_QUICK_START.md - Development guide"
echo ""

echo "Happy coding! 🚀"
