#!/bin/bash

# Firebase Rules Deployment Script for LifeEase
# This script deploys Firestore and Storage security rules

echo "======================================"
echo "Firebase Rules Deployment"
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

# Check if Firebase CLI is installed
echo "Checking prerequisites..."
echo ""

if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI not installed"
    echo "  Install with: npm install -g firebase-tools"
    exit 1
fi

print_success "Firebase CLI is installed"

# Check if user is logged in
if ! firebase projects:list &> /dev/null 2>&1; then
    print_error "Not logged in to Firebase"
    echo "  Run: firebase login"
    exit 1
fi

print_success "Logged in to Firebase"
echo ""

# Check if required files exist
echo "Checking rule files..."
echo ""

if [ ! -f "firestore.rules" ]; then
    print_error "firestore.rules not found"
    exit 1
fi
print_success "firestore.rules found"

if [ ! -f "storage.rules" ]; then
    print_error "storage.rules not found"
    exit 1
fi
print_success "storage.rules found"

if [ ! -f "firestore.indexes.json" ]; then
    print_warning "firestore.indexes.json not found (optional)"
else
    print_success "firestore.indexes.json found"
fi

if [ ! -f "firebase.json" ]; then
    print_error "firebase.json not found"
    exit 1
fi
print_success "firebase.json found"

echo ""
echo "======================================"
echo "Ready to Deploy"
echo "======================================"
echo ""

# Show current Firebase project
CURRENT_PROJECT=$(firebase projects:list 2>&1 | grep "lifeease" | awk '{print $2}' | head -n 1)
if [ -z "$CURRENT_PROJECT" ]; then
    print_warning "Could not detect Firebase project"
    echo "  Make sure you have selected the correct project"
    echo "  Run: firebase use <project-id>"
else
    print_info "Deploying to project: $CURRENT_PROJECT"
fi

echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Deploy Firestore rules
echo "======================================"
echo "Step 1: Deploying Firestore Rules"
echo "======================================"
echo ""

firebase deploy --only firestore:rules

if [ $? -eq 0 ]; then
    print_success "Firestore rules deployed successfully"
else
    print_error "Failed to deploy Firestore rules"
    exit 1
fi

echo ""

# Deploy Firestore indexes
if [ -f "firestore.indexes.json" ]; then
    echo "======================================"
    echo "Step 2: Deploying Firestore Indexes"
    echo "======================================"
    echo ""
    
    firebase deploy --only firestore:indexes
    
    if [ $? -eq 0 ]; then
        print_success "Firestore indexes deployed successfully"
    else
        print_warning "Failed to deploy Firestore indexes (non-critical)"
    fi
    
    echo ""
fi

# Deploy Storage rules
echo "======================================"
echo "Step 3: Deploying Storage Rules"
echo "======================================"
echo ""

firebase deploy --only storage

if [ $? -eq 0 ]; then
    print_success "Storage rules deployed successfully"
else
    print_error "Failed to deploy Storage rules"
    exit 1
fi

echo ""
echo "======================================"
echo "✅ Deployment Complete!"
echo "======================================"
echo ""

print_info "Rules have been deployed to Firebase"
print_info "Changes may take 1-2 minutes to propagate"
echo ""

print_info "Next steps:"
echo "  1. Verify rules in Firebase Console"
echo "  2. Test with Firebase Rules Playground"
echo "  3. Test from your app"
echo ""

print_info "Verify deployment:"
echo "  • Firestore: https://console.firebase.google.com → Firestore → Rules"
echo "  • Storage: https://console.firebase.google.com → Storage → Rules"
echo ""

echo "Happy coding! 🚀"
