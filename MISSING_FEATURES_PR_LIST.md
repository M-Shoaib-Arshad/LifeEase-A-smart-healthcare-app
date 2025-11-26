# LifeEase Healthcare App - Missing Features PR Implementation Plan

**Document Created**: November 20, 2024  
**Last Updated**: November 26, 2024  
**Based On**: Missing Features Analysis Document  
**Current Completion**: ~35% (Updated after PR #4)
  - Base completion: ~29% (PRs #1, #2, #3)
  - PR #4 Patient Screens: +6% (major screens and 3 core services implemented)
  - Note: Percentage is estimated based on features completed vs. total planned features in this document

## Recent Updates

**Important Note on PR Numbering**: The GitHub PR #4 (Patient Screens Implementation) differs from the "PR #4" described in this planning document (Environment Configuration & Security). The actual GitHub PR sequence has been: PR #1 (Auth), PR #2 (Doctor Screens), PR #3 (Settings), and PR #4 (Patient Screens). The features described as "PR #4" and beyond in this document are still pending implementation.

### PR #4 - Patient Screens Implementation (Completed ✅)
**Merged**: November 8, 2024  
**Implemented**:
- ✅ NotificationService - In-app notifications, push notification infrastructure, appointment/medication reminders
- ✅ RealTimeService - Firestore real-time data streams for appointments, health records, and user profiles
- ✅ TelemedicineService - Agora RTC video call integration with audio/video controls
- ✅ NotificationProvider - Notification state management with real-time subscriptions
- ✅ 14 Patient Screens - All patient-facing screens made fully functional
- ✅ Enhanced Notification Model - Added title, type, and data fields

**Note**: While this PR implemented core notification and telemedicine infrastructure, full FCM (Firebase Cloud Messaging) push notifications and advanced features outlined in PR #7 below still need:
- Firebase Cloud Messaging SDK integration
- Background message handling for iOS and Android
- APNs (Apple Push Notification service) configuration for iOS
- FCM token management and device registration
- Rich notification support (images, actions)
- Notification click handling and deep linking

---

## Table of Contents

1. [Critical Priority PRs (Weeks 1-2)](#critical-priority-prs-weeks-1-2)
2. [High Priority PRs (Weeks 3-4)](#high-priority-prs-weeks-3-4)
3. [Medium Priority PRs (Month 2)](#medium-priority-prs-month-2)
4. [Low Priority PRs (Month 3+)](#low-priority-prs-month-3)
5. [Infrastructure & Quality PRs (Ongoing)](#infrastructure--quality-prs-ongoing)
6. [Implementation Timeline](#implementation-timeline)
7. [Dependencies Matrix](#dependencies-matrix)

---

## Critical Priority PRs (Weeks 1-2)

### PR #3: Complete Settings Functionality ⚠️ CRITICAL
**Branch**: `feature/settings-implementation`  
**Priority**: CRITICAL  
**Estimated Effort**: 2-3 days  
**Dependencies**: None (PR #1, #2 already complete)

#### Scope
Implement all placeholder functions in `lib/screens/common/settings_screen.dart`

#### Files to Modify
1. `lib/screens/common/settings_screen.dart` - Implement all TODO functions
2. `lib/services/auth_service.dart` - Add password change method
3. `lib/providers/user_provider.dart` - Add profile update methods

#### Files to Create
1. `lib/providers/settings_provider.dart` - Settings state management
2. `lib/providers/theme_provider.dart` - Theme management (dark mode)
3. `lib/services/settings_service.dart` - Settings persistence
4. `lib/widgets/settings/change_password_dialog.dart` - Password change UI
5. `lib/widgets/settings/notification_settings_widget.dart` - Notification preferences UI
6. `lib/widgets/settings/theme_selector_widget.dart` - Theme selection UI
7. `lib/widgets/settings/language_selector_widget.dart` - Language selection UI

#### Features to Implement
- [x] Change Password functionality
- [x] Profile Settings editing
- [x] Notification Preferences management
- [x] Language Selection (basic, full i18n in later PR)
- [x] Theme Settings (Dark mode toggle)
- [x] Proper Logout with session cleanup

#### Acceptance Criteria
- User can change password via Firebase Auth
- User can update profile information
- User can toggle notification preferences (saved to SharedPreferences/Firestore)
- User can switch between light and dark themes
- Logout properly clears session and Firebase auth
- All settings persist across app restarts

#### Testing Requirements
- Unit tests for settings service
- Widget tests for settings screen
- Integration test for password change flow

---

### PR #4: Environment Configuration & Security ⚠️ CRITICAL
**Branch**: `feature/environment-config`  
**Priority**: CRITICAL  
**Estimated Effort**: 1-2 days  
**Dependencies**: None

#### Scope
Move all hardcoded secrets to environment variables and implement proper configuration management.

#### Files to Create
1. `.env` - Environment variables (not committed)
2. `.env.example` - Template for developers
3. `lib/config/env_config.dart` - Environment variable loader
4. `.gitignore` updates - Ensure .env is ignored

#### Files to Modify
1. `lib/services/telemedicine_service.dart` - Use env vars for Agora App ID
2. `lib/config/app_config.dart` - Load from environment
3. `pubspec.yaml` - Ensure flutter_dotenv is properly configured

#### Environment Variables Needed
```env
# Firebase
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=

# Agora
AGORA_APP_ID=

# API Keys (for future)
OPENAI_API_KEY=
GOOGLE_MAPS_API_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_SECRET_KEY=

# Environment
APP_ENV=development # or staging, production
```

#### Acceptance Criteria
- No secrets in source code
- All sensitive data in .env file
- .env.example template exists
- Environment-specific configs work (dev, staging, prod)
- App fails gracefully with helpful error if .env missing

#### Testing Requirements
- Unit tests for env_config.dart
- Manual verification with different .env files

---

### PR #5: Google Sign-In Integration ⚠️ CRITICAL
**Branch**: `feature/google-signin`  
**Priority**: CRITICAL  
**Estimated Effort**: 1-2 days  
**Dependencies**: PR #4 (environment config)

#### Scope
Implement Google OAuth authentication for easier user onboarding.

#### Files to Modify
1. `lib/screens/auth/login_screen.dart` - Add Google sign-in button
2. `lib/screens/auth/signup_screen.dart` - Add Google sign-up option
3. `lib/services/auth_service.dart` - Implement Google authentication

#### Files to Create
1. `lib/widgets/auth/google_signin_button.dart` - Reusable Google button
2. `lib/widgets/auth/social_auth_divider.dart` - "Or continue with" divider

#### Features to Implement
- Google Sign-In integration
- Automatic profile creation from Google account
- Link Google account to existing email/password account
- Handle Google sign-in errors gracefully

#### Configuration Required
- Android: Update `android/app/src/main/AndroidManifest.xml`
- iOS: Update `ios/Runner/Info.plist`
- Firebase Console: Enable Google Sign-In provider

#### Acceptance Criteria
- Users can sign in with Google
- New users auto-create profile with Google info
- Existing users can link Google account
- Profile picture from Google account imported
- Works on both Android and iOS

#### Testing Requirements
- Manual testing on Android
- Manual testing on iOS
- Unit tests for auth_service Google methods

---

### PR #6: Payment Integration (Stripe) ⚠️ CRITICAL
**Branch**: `feature/payment-stripe`  
**Priority**: CRITICAL  
**Estimated Effort**: 3-4 days  
**Dependencies**: PR #4 (environment config)

#### Scope
Implement payment processing for appointment bookings using Stripe.

#### Packages to Add
```yaml
dependencies:
  stripe_payment: ^1.1.5
  # OR
  flutter_stripe: ^10.1.1  # Newer, better maintained
```

#### Files to Create
1. `lib/services/payment_service.dart` - Stripe integration
2. `lib/models/payment.dart` - Payment data model
3. `lib/models/invoice.dart` - Invoice/receipt model
4. `lib/screens/common/payment_screen.dart` - Payment UI
5. `lib/screens/patient/payment_history_screen.dart` - Payment history
6. `lib/widgets/payment/payment_card_widget.dart` - Payment method selector
7. `lib/widgets/payment/payment_summary_widget.dart` - Payment summary
8. `lib/providers/payment_provider.dart` - Payment state management

#### Files to Modify
1. `lib/screens/patient/appointment_booking_screen.dart` - Add payment step
2. `lib/screens/patient/appointment_confirmation_screen.dart` - Show payment receipt
3. `lib/models/appointment.dart` - Add payment info fields

#### Features to Implement
- Stripe payment initialization
- Payment intent creation
- Credit/debit card payment
- Payment confirmation
- Payment history viewing
- Receipt generation (PDF)
- Refund handling (basic)

#### Firestore Collections to Add
```
payments/
  {paymentId}/
    - userId
    - appointmentId
    - amount
    - currency
    - status (pending, completed, failed, refunded)
    - paymentMethod
    - stripePaymentIntentId
    - createdAt
    - updatedAt
```

#### Acceptance Criteria
- Users can pay for appointments with credit/debit card
- Payment confirmation shown immediately
- Payment stored in Firestore
- Payment history accessible to users
- Failed payments handled gracefully
- Stripe webhooks handle async events

#### Testing Requirements
- Unit tests for payment_service
- Widget tests for payment screens
- Manual testing with Stripe test cards
- Test webhook handling

---

## High Priority PRs (Weeks 3-4)

### PR #7: Push Notifications (FCM) ⚠️ HIGH
**Branch**: `feature/push-notifications`  
**Priority**: HIGH  
**Estimated Effort**: 2-3 days  
**Dependencies**: PR #4 (environment config)

**Status Update**: ⚠️ Partially implemented in PR #4 (Nov 2024)
- ✅ NotificationService created with in-app notification support
- ✅ Real-time notification streams implemented
- ✅ Appointment and medication reminder infrastructure
- ⏳ FCM (Firebase Cloud Messaging) integration needed
- ⏳ Background notification handling needed
- ⏳ iOS APNs configuration needed

#### Scope
Complete Firebase Cloud Messaging integration for background push notifications.

#### Packages to Add
```yaml
dependencies:
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

#### Files to Create
1. `lib/services/fcm_service.dart` - Firebase Cloud Messaging service
2. `lib/services/local_notification_service.dart` - Local notifications
3. `lib/models/push_notification.dart` - Push notification model
4. `lib/widgets/notification/notification_permission_dialog.dart` - Permission request

#### Files to Modify
1. `lib/services/notification_service.dart` - Integrate FCM
2. `lib/main.dart` - Initialize FCM on app start
3. `android/app/src/main/AndroidManifest.xml` - FCM permissions
4. `ios/Runner/Info.plist` - iOS notification permissions

#### Features to Implement
- FCM device token registration
- Background notification handling
- Foreground notification display
- Notification tap handling (deep linking)
- Notification channels (Android)
- Rich notifications with images
- Notification scheduling
- Badge count updates (iOS)

#### Notification Types to Support
1. Appointment reminders (1 hour before, 1 day before)
2. Appointment confirmations
3. Appointment cancellations
4. New messages from doctor
5. Prescription ready
6. Health tips (weekly)

#### Acceptance Criteria
- Notifications received when app is closed
- Notifications work on both Android and iOS
- Tapping notification opens relevant screen
- User can manage notification preferences
- Notifications respect quiet hours setting

#### Testing Requirements
- Test on Android device
- Test on iOS device
- Test background notification handling
- Test notification tap navigation

---

### PR #8: Google Maps Integration ⚠️ HIGH
**Branch**: `feature/google-maps`  
**Priority**: HIGH  
**Estimated Effort**: 2-3 days  
**Dependencies**: PR #4 (environment config)

#### Packages to Add
```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

#### Files to Create
1. `lib/screens/patient/doctor_map_search_screen.dart` - Map view for doctors
2. `lib/widgets/map/doctor_map_marker.dart` - Custom map markers
3. `lib/widgets/map/location_permission_dialog.dart` - Location permission request
4. `lib/services/location_service.dart` - Location handling

#### Files to Modify
1. `lib/screens/patient/doctor_search_screen.dart` - Add map view toggle
2. `lib/screens/patient/doctor_list_screen.dart` - Add distance filtering
3. `lib/screens/patient/doctor_profile_screen.dart` - Add "Navigate" button
4. `lib/models/user.dart` - Add location fields (lat, lng, address)

#### Features to Implement
- Display doctors on map
- Current location detection
- Distance calculation to doctors
- Filter doctors by distance radius
- Navigate to clinic/hospital
- Search location autocomplete
- Clinic address geocoding

#### Configuration Required
- Google Maps API key (added to .env)
- Android: Update `android/app/src/main/AndroidManifest.xml`
- iOS: Update `ios/Runner/Info.plist`
- Enable Maps SDK in Google Cloud Console

#### Acceptance Criteria
- Map shows nearby doctors with custom markers
- User can see their current location
- Distance to each doctor displayed
- Can navigate to doctor's clinic
- Location permission handled properly
- Works offline with cached map tiles

#### Testing Requirements
- Manual testing on Android
- Manual testing on iOS
- Test location permission flows
- Test without location permission

---

### PR #9: Offline Support & Data Caching ⚠️ HIGH
**Branch**: `feature/offline-support`  
**Priority**: HIGH  
**Estimated Effort**: 3-4 days  
**Dependencies**: None

**Status Update**: ⚠️ Real-time services implemented in PR #4 (Nov 2024)
- ✅ RealTimeService created for live Firestore streams
- ✅ Real-time appointment, health record, and user profile synchronization
- ⏳ Local caching with Hive needed
- ⏳ Offline action queuing needed
- ⏳ Sync service for offline-to-online transitions needed

#### Scope
Implement local data caching and offline support with synchronization.

#### Packages to Add
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^5.0.2
  cached_network_image: ^3.3.1

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

#### Files to Create
1. `lib/services/cache_service.dart` - Local caching service
2. `lib/services/sync_service.dart` - Data synchronization
3. `lib/models/sync_queue.dart` - Offline action queue
4. `lib/widgets/common/offline_indicator.dart` - Offline mode banner
5. `lib/services/connectivity_service.dart` - Network status monitoring

#### Files to Modify
1. `lib/services/api_service.dart` - Add offline support
2. `lib/main.dart` - Initialize Hive
3. Multiple screens - Add offline indicators

#### Features to Implement
- Hive local database setup
- Cache user profile data
- Cache appointments
- Cache health records
- Queue offline actions (appointments, updates)
- Sync when online
- Conflict resolution
- Network status indicator
- Cached image loading

#### Data to Cache
1. User profile
2. Appointments (upcoming and recent)
3. Health records
4. Doctor profiles (viewed)
5. Medications
6. Settings

#### Acceptance Criteria
- App functional without internet for viewing data
- Offline actions queued and synced when online
- User sees offline indicator when disconnected
- Images cached for offline viewing
- Conflicts resolved intelligently
- Cache cleared on logout

#### Testing Requirements
- Test with airplane mode on
- Test sync after going online
- Test conflict resolution
- Unit tests for cache and sync services

---

### PR #10: Emergency Features ⚠️ HIGH
**Branch**: `feature/emergency-sos`  
**Priority**: HIGH  
**Estimated Effort**: 2-3 days  
**Dependencies**: PR #8 (Google Maps for location sharing)

#### Files to Create
1. `lib/screens/patient/emergency_screen.dart` - Emergency features
2. `lib/screens/patient/emergency_contacts_screen.dart` - Manage emergency contacts
3. `lib/services/emergency_service.dart` - Emergency handling
4. `lib/widgets/sos_button.dart` - Emergency SOS button
5. `lib/widgets/emergency/ice_card_widget.dart` - In Case of Emergency card
6. `lib/models/emergency_contact.dart` - Emergency contact model

#### Files to Modify
1. `lib/screens/patient/patient_home_screen.dart` - Add SOS button
2. `lib/screens/patient/profile_view_screen.dart` - Add emergency info section

#### Features to Implement
- Emergency SOS button (quick access)
- Emergency contact management (name, phone, relation)
- Quick call to emergency services
- Quick call to saved emergency contacts
- Share location with emergency contacts (SMS)
- ICE card with medical info (allergies, blood type, conditions)
- Medical alert badge on profile

#### Emergency Information to Display
1. Blood type
2. Allergies
3. Current medications
4. Chronic conditions
5. Emergency contacts
6. Doctor contact

#### Acceptance Criteria
- SOS button accessible from home screen
- Can call emergency number (911, 112, etc.)
- Can call saved emergency contacts
- Location shared via SMS when SOS triggered
- ICE card accessible even when phone locked (future)
- Emergency info editable by user

#### Testing Requirements
- Test SOS button functionality
- Test emergency call flow
- Test location sharing
- Manual testing on different devices

---

### PR #11: Security Enhancements ⚠️ HIGH
**Branch**: `feature/security-enhancements`  
**Priority**: HIGH  
**Estimated Effort**: 2-3 days  
**Dependencies**: PR #4 (environment config)

#### Packages to Add
```yaml
dependencies:
  local_auth: ^2.1.8
  encrypt: ^5.0.3
  flutter_secure_storage: ^9.2.0  # Already exists
```

#### Files to Create
1. `lib/services/biometric_service.dart` - Biometric authentication
2. `lib/services/encryption_service.dart` - Data encryption
3. `lib/screens/common/security_settings_screen.dart` - Security settings
4. `lib/widgets/security/biometric_prompt_widget.dart` - Biometric prompt
5. `lib/models/security_event.dart` - Security audit log model

#### Files to Modify
1. `lib/services/security_service.dart` - Enhance with proper encryption
2. `lib/screens/auth/login_screen.dart` - Add biometric option
3. `lib/screens/common/settings_screen.dart` - Add security settings link

#### Features to Implement
- Biometric authentication (fingerprint, face ID)
- Two-factor authentication (2FA) via SMS
- Proper data encryption (AES)
- Security audit logging to Firestore
- Session management improvements
- Auto-logout after inactivity
- Active sessions viewing
- Rate limiting for API calls

#### Security Events to Log
1. Login attempts (success/failure)
2. Password changes
3. Profile updates
4. Medical record access
5. Failed biometric attempts
6. 2FA events

#### Firestore Collection to Add
```
security_logs/
  {logId}/
    - userId
    - event (login_success, login_failed, etc.)
    - timestamp
    - deviceInfo
    - ipAddress (if available)
    - details
```

#### Acceptance Criteria
- Users can enable biometric login
- 2FA optional for high-security users
- Sensitive data encrypted at rest
- Security events logged to Firestore
- Auto-logout after 30 min inactivity (configurable)
- User can view active sessions

#### Testing Requirements
- Test biometric on real devices
- Test 2FA flow
- Test encryption/decryption
- Security audit of implementation

---

## Medium Priority PRs (Month 2)

### PR #12: Complete AI Service (OpenAI Integration) 🔶 MEDIUM
**Branch**: `feature/ai-integration`  
**Priority**: MEDIUM  
**Estimated Effort**: 3-5 days  
**Dependencies**: PR #4 (environment config)

#### Packages to Add
```yaml
dependencies:
  http: ^1.1.2  # Already exists in project
  # OR
  openai_api: ^2.1.1
```

#### Files to Modify
1. `lib/services/ai_service.dart` - Implement real OpenAI integration

#### Files to Create
1. `lib/models/ai_symptom_analysis.dart` - Symptom analysis result
2. `lib/widgets/ai/disclaimer_widget.dart` - AI disclaimer
3. `lib/screens/patient/ai_symptom_checker_screen.dart` - Symptom checker UI

#### Features to Implement
- OpenAI API integration (GPT-4 or GPT-3.5-turbo)
- Symptom analysis with medical prompting
- Doctor recommendation based on symptoms
- Health tips generation
- Medication information lookup
- AI response caching
- Rate limiting and cost management
- User consent and disclaimer

#### Environment Variables to Add
```env
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-3.5-turbo
OPENAI_MAX_TOKENS=500
```

#### Acceptance Criteria
- AI provides relevant symptom analysis
- Includes medical disclaimer
- Recommends appropriate doctor specialties
- Responses are cached to reduce costs
- Rate limiting prevents abuse
- User must accept disclaimer before use

#### Testing Requirements
- Unit tests for AI service
- Integration tests with mock responses
- Manual testing with various symptoms
- Cost monitoring in production

---

### PR #13: Enhanced Support System 🔶 MEDIUM
**Branch**: `feature/support-ticketing`  
**Priority**: MEDIUM  
**Estimated Effort**: 2-3 days  
**Dependencies**: PR #7 (push notifications)

#### Files to Modify
1. `lib/screens/common/support_screen.dart` - Enhance with Firebase backend

#### Files to Create
1. `lib/models/support_ticket.dart` - Ticket model
2. `lib/models/faq.dart` - FAQ model
3. `lib/screens/common/faq_screen.dart` - FAQ viewer
4. `lib/screens/common/ticket_details_screen.dart` - View ticket
5. `lib/widgets/support/attachment_picker.dart` - Attach images to tickets
6. `lib/services/support_service.dart` - Support ticket management

#### Features to Implement
- Firebase-based ticket system
- FAQ database and search
- Image/file attachments for tickets
- Ticket status tracking (open, in-progress, resolved)
- Email notifications for ticket updates
- Live chat support (basic, using Firestore)
- Ticket categories (technical, billing, medical, other)

#### Firestore Collections to Add
```
support_tickets/
  {ticketId}/
    - userId
    - subject
    - description
    - category
    - status
    - priority
    - attachments[]
    - createdAt
    - updatedAt
    - messages[]  # For chat-like replies

faqs/
  {faqId}/
    - question
    - answer
    - category
    - order
    - helpful_count
```

#### Acceptance Criteria
- Users can submit support tickets
- Can attach images to tickets
- FAQ searchable and categorized
- Users notified of ticket updates
- Admin can respond to tickets
- Ticket history visible to user

#### Testing Requirements
- Test ticket submission
- Test file upload
- Test FAQ search
- Integration test for ticket workflow

---

### PR #14: Ratings & Reviews System 🔶 MEDIUM
**Branch**: `feature/ratings-reviews`  
**Priority**: MEDIUM  
**Estimated Effort**: 2-3 days  
**Dependencies**: None

#### Files to Create
1. `lib/models/review.dart` - Review model
2. `lib/screens/patient/leave_review_screen.dart` - Leave review
3. `lib/screens/doctor/reviews_list_screen.dart` - View reviews
4. `lib/widgets/rating_widget.dart` - Star rating widget
5. `lib/widgets/review_card.dart` - Review display card
6. `lib/services/review_service.dart` - Review management

#### Files to Modify
1. `lib/screens/patient/doctor_profile_screen.dart` - Show ratings
2. `lib/screens/patient/appointment_history_screen.dart` - Add "Leave Review" button
3. `lib/models/user.dart` - Add rating fields for doctors

#### Features to Implement
- Star rating system (1-5 stars)
- Written reviews
- Review moderation (flag inappropriate)
- Average rating calculation
- Review sorting (most helpful, recent)
- Reply to reviews (doctors)
- Edit/delete own reviews
- Helpful/not helpful voting

#### Firestore Collections to Add
```
reviews/
  {reviewId}/
    - doctorId
    - patientId
    - appointmentId
    - rating (1-5)
    - title
    - comment
    - helpful_count
    - reported
    - doctorReply
    - createdAt
    - updatedAt
```

#### Acceptance Criteria
- Patients can rate doctors after appointment
- Reviews visible on doctor profile
- Average rating displayed prominently
- Inappropriate reviews can be reported
- Doctors can reply to reviews
- Reviews can be sorted and filtered

#### Testing Requirements
- Unit tests for review service
- Widget tests for rating widget
- Test review submission flow
- Test moderation flags

---

### PR #15: Prescription Management 🔶 MEDIUM
**Branch**: `feature/prescriptions`  
**Priority**: MEDIUM  
**Estimated Effort**: 3-4 days  
**Dependencies**: PR #6 (payment, for prescription purchases)

#### Files to Create
1. `lib/services/prescription_service.dart` - Prescription management
2. `lib/models/prescription.dart` - Prescription model
3. `lib/models/medication.dart` - Medication model
4. `lib/screens/patient/prescription_list_screen.dart` - View prescriptions
5. `lib/screens/patient/prescription_detail_screen.dart` - Prescription details
6. `lib/screens/doctor/create_prescription_screen.dart` - Create prescription
7. `lib/widgets/prescription/prescription_card.dart` - Prescription display
8. `lib/widgets/prescription/medication_item.dart` - Medication item
9. `lib/providers/prescription_provider.dart` - Prescription state

#### Files to Modify
1. `lib/screens/doctor/patient_details_screen.dart` - Add "Prescribe" button
2. `lib/screens/patient/patient_home_screen.dart` - Add prescriptions section

#### Features to Implement
- Digital prescription creation by doctors
- E-prescription format (PDF)
- Prescription viewing by patients
- Medication details (name, dosage, frequency, duration)
- Prescription sharing (email, download)
- Prescription history
- Medication reminders integration
- Pharmacy integration (basic)

#### Firestore Collections to Add
```
prescriptions/
  {prescriptionId}/
    - doctorId
    - patientId
    - appointmentId
    - medications[]
      - name
      - dosage
      - frequency
      - duration
      - instructions
    - diagnosis
    - notes
    - status (active, completed, cancelled)
    - createdAt
    - expiresAt
```

#### Acceptance Criteria
- Doctors can create digital prescriptions
- Prescriptions linked to appointments
- Patients can view all prescriptions
- Prescriptions downloadable as PDF
- Can share prescription via email
- Medication reminders auto-created

#### Testing Requirements
- Test prescription creation flow
- Test PDF generation
- Test prescription sharing
- Integration test for full workflow

---

### PR #16: Lab Results Integration 🔶 MEDIUM
**Branch**: `feature/lab-results`  
**Priority**: MEDIUM  
**Estimated Effort**: 2-3 days  
**Dependencies**: None

#### Files to Create
1. `lib/screens/patient/lab_results_screen.dart` - Lab results list
2. `lib/screens/patient/lab_result_detail_screen.dart` - Result details
3. `lib/screens/patient/upload_lab_result_screen.dart` - Upload results
4. `lib/models/lab_result.dart` - Lab result model
5. `lib/services/lab_result_service.dart` - Lab result management
6. `lib/widgets/lab/lab_result_card.dart` - Result card
7. `lib/providers/lab_result_provider.dart` - Lab results state

#### Features to Implement
- Upload lab reports (PDF, images)
- View lab result history
- Share results with doctors
- Categorize results (blood test, X-ray, MRI, etc.)
- Track trends over time (charts)
- Add notes to results
- Download results

#### Firestore Collections to Add
```
lab_results/
  {resultId}/
    - patientId
    - testName
    - testType
    - category
    - fileUrl
    - fileType
    - notes
    - sharedWith[] (doctor IDs)
    - testDate
    - uploadedAt
```

#### Acceptance Criteria
- Patients can upload lab results
- Results organized by category
- Can share with specific doctors
- Results viewable in chronological order
- Supports PDF and images
- Download results locally

#### Testing Requirements
- Test file upload
- Test sharing mechanism
- Test file viewing
- Widget tests for screens

---

## Low Priority PRs (Month 3+)

### PR #17: Multi-language Support (i18n) 🔵 LOW
**Branch**: `feature/internationalization`  
**Priority**: LOW  
**Estimated Effort**: 5-7 days  
**Dependencies**: PR #3 (settings for language selection)

#### Packages to Add
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1  # Already exists
```

#### Files to Create
1. `lib/l10n/app_en.arb` - English translations
2. `lib/l10n/app_es.arb` - Spanish translations
3. `lib/l10n/app_ar.arb` - Arabic translations (RTL)
4. `lib/l10n/app_ur.arb` - Urdu translations (RTL)
5. `lib/l10n/app_hi.arb` - Hindi translations
6. `lib/providers/locale_provider.dart` - Language state management

#### Files to Modify
- All screen files - Replace hardcoded strings with localized strings

#### Features to Implement
- Full app localization
- RTL language support
- Language selection in settings
- Automatic language detection
- Date/time formatting per locale
- Number formatting per locale

#### Languages to Support
1. English (en)
2. Spanish (es)
3. Arabic (ar) - RTL
4. Urdu (ur) - RTL
5. Hindi (hi)

#### Acceptance Criteria
- All user-facing text localized
- RTL languages properly supported
- Language persists after app restart
- Date/time shows in user's format
- No hardcoded strings in UI

#### Testing Requirements
- Test each language
- Test RTL layouts
- Test language switching
- Visual regression testing

---

### PR #18: Advanced Analytics & Reporting 🔵 LOW
**Branch**: `feature/analytics-reporting`  
**Priority**: LOW  
**Estimated Effort**: 3-5 days  
**Dependencies**: PR #4 (environment config)

#### Packages to Add
```yaml
dependencies:
  firebase_analytics: ^10.8.0
```

#### Files to Create
1. `lib/services/analytics_service.dart` - Analytics tracking
2. `lib/screens/admin/analytics_dashboard_screen.dart` - Admin analytics
3. `lib/screens/doctor/doctor_analytics_screen.dart` - Doctor statistics
4. `lib/widgets/analytics/chart_widget.dart` - Various charts
5. `lib/models/analytics_event.dart` - Custom event model

#### Features to Implement
- Firebase Analytics integration
- Custom event tracking
- User behavior analysis
- Admin dashboard with insights
- Doctor performance metrics
- Patient engagement metrics
- Revenue tracking
- Geographic distribution
- Popular services tracking

#### Events to Track
1. User registration
2. Appointment bookings
3. Appointment cancellations
4. Payment completions
5. Doctor searches
6. Profile views
7. Video call usage
8. Feature usage

#### Acceptance Criteria
- Firebase Analytics properly integrated
- Custom events tracked
- Admin can view dashboard
- Doctors can view their stats
- Privacy compliance maintained

#### Testing Requirements
- Verify events sent to Firebase
- Test dashboard with sample data
- Privacy audit

---

### PR #19: Insurance Management 🔵 LOW
**Branch**: `feature/insurance`  
**Priority**: LOW  
**Estimated Effort**: 5-7 days  
**Dependencies**: PR #6 (payment integration)

#### Files to Create
1. `lib/screens/patient/insurance_screen.dart` - Insurance management
2. `lib/screens/patient/add_insurance_screen.dart` - Add insurance
3. `lib/screens/patient/insurance_claim_screen.dart` - File claim
4. `lib/models/insurance.dart` - Insurance model
5. `lib/models/insurance_claim.dart` - Claim model
6. `lib/services/insurance_service.dart` - Insurance management
7. `lib/widgets/insurance/insurance_card_widget.dart` - Insurance card display

#### Features to Implement
- Insurance card storage
- Multiple insurance support
- Insurance provider directory
- Claim submission
- Coverage verification
- Insurance claims history
- Document upload for claims

#### Firestore Collections to Add
```
insurance/
  {insuranceId}/
    - userId
    - provider
    - policyNumber
    - groupNumber
    - cardFrontUrl
    - cardBackUrl
    - coverageType
    - expiryDate

insurance_claims/
  {claimId}/
    - insuranceId
    - appointmentId
    - amount
    - status
    - submittedAt
    - documents[]
```

#### Acceptance Criteria
- Users can store insurance cards
- Can file insurance claims
- Claims tracked by status
- Can upload claim documents
- Insurance info used in billing

#### Testing Requirements
- Test insurance card upload
- Test claim submission
- Test multi-insurance scenarios

---

### PR #20: Social Features & Gamification 🔵 LOW
**Branch**: `feature/social-gamification`  
**Priority**: LOW  
**Estimated Effort**: 5-7 days  
**Dependencies**: PR #7 (push notifications)

#### Files to Create
1. `lib/screens/patient/health_challenges_screen.dart` - Health challenges
2. `lib/screens/patient/achievements_screen.dart` - Achievements/badges
3. `lib/screens/patient/community_screen.dart` - Community forum
4. `lib/screens/patient/referral_screen.dart` - Refer friends
5. `lib/models/challenge.dart` - Challenge model
6. `lib/models/achievement.dart` - Achievement model
7. `lib/services/gamification_service.dart` - Gamification logic

#### Features to Implement
- Health challenges (step goals, workout goals)
- Achievement badges
- Point system
- Leaderboards
- Community forums
- Friend referral system
- Social sharing (achievements)
- Rewards program

#### Firestore Collections to Add
```
challenges/
  {challengeId}/
    - name
    - description
    - type
    - goal
    - duration
    - participants[]
    - startDate
    - endDate

achievements/
  {achievementId}/
    - name
    - description
    - icon
    - criteria

user_achievements/
  {userId}/
    - achievements[]
    - points
    - level
    - streak
```

#### Acceptance Criteria
- Users can join health challenges
- Achievements unlock automatically
- Leaderboard functional
- Can refer friends
- Privacy options for social features

#### Testing Requirements
- Test challenge participation
- Test achievement unlocking
- Test referral system
- Privacy compliance testing

---

### PR #21: Advanced Accessibility Features 🔵 LOW
**Branch**: `feature/accessibility`  
**Priority**: LOW  
**Estimated Effort**: 3-4 days  
**Dependencies**: PR #3 (settings)

#### Files to Modify
- All UI screens - Add semantic labels and screen reader support

#### Files to Create
1. `lib/services/accessibility_service.dart` - Accessibility helpers
2. `lib/widgets/accessibility/high_contrast_widget.dart` - High contrast mode
3. `lib/widgets/accessibility/font_scale_widget.dart` - Font scaling

#### Features to Implement
- Screen reader optimization
- Semantic labels on all interactive elements
- Keyboard navigation support
- High contrast mode
- Font size adjustment
- Reduce motion option
- Focus indicators
- Voice commands (basic)
- Alternative text for images

#### Acceptance Criteria
- Full screen reader support (TalkBack, VoiceOver)
- All interactive elements accessible via keyboard
- High contrast mode available
- Font size adjustable
- WCAG 2.1 AA compliance

#### Testing Requirements
- Test with TalkBack (Android)
- Test with VoiceOver (iOS)
- Test keyboard navigation
- Accessibility audit

---

## Infrastructure & Quality PRs (Ongoing)

### PR #22: Testing Infrastructure 🛠️ INFRASTRUCTURE
**Branch**: `feature/testing-infrastructure`  
**Priority**: HIGH (for code quality)  
**Estimated Effort**: Ongoing (1-2 hours per feature)  
**Dependencies**: All other PRs

#### Packages to Add (if not exists)
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
  test: ^1.24.9
```

#### Test Files to Create
**Unit Tests**
- `test/services/auth_service_test.dart`
- `test/services/payment_service_test.dart`
- `test/services/notification_service_test.dart`
- `test/services/fcm_service_test.dart`
- `test/providers/user_provider_test.dart`
- `test/providers/settings_provider_test.dart`
- etc. (for all services and providers)

**Widget Tests**
- `test/widgets/settings_screen_test.dart`
- `test/widgets/payment_screen_test.dart`
- `test/widgets/login_screen_test.dart`
- etc. (for all screens)

**Integration Tests**
- `integration_test/auth_flow_test.dart`
- `integration_test/appointment_booking_test.dart`
- `integration_test/payment_flow_test.dart`
- `integration_test/settings_test.dart`

#### Testing Goals
- 80% code coverage for services
- 70% code coverage for providers
- 60% code coverage for widgets
- Integration tests for critical flows

#### Acceptance Criteria
- All new features include tests
- CI/CD runs tests automatically
- Coverage reports generated
- No failing tests in main branch

---

### PR #23: CI/CD Pipeline 🛠️ INFRASTRUCTURE
**Branch**: `feature/ci-cd`  
**Priority**: MEDIUM  
**Estimated Effort**: 2-3 days  
**Dependencies**: PR #22 (testing)

#### Files to Create
1. `.github/workflows/flutter_ci.yml` - CI workflow
2. `.github/workflows/android_release.yml` - Android release
3. `.github/workflows/ios_release.yml` - iOS release
4. `.github/workflows/code_quality.yml` - Linting and formatting

#### Features to Implement
- Automated testing on PR
- Build verification
- Code quality checks (linting)
- Automated releases
- Version management
- Changelog generation
- Firebase deployment automation

#### CI/CD Steps
1. Install Flutter
2. Get dependencies
3. Run analyzer
4. Run formatter check
5. Run unit tests
6. Run widget tests
7. Build APK/IPA
8. Run integration tests
9. Upload artifacts

#### Acceptance Criteria
- All PRs automatically tested
- Builds succeed before merge
- Releases automated
- Code quality enforced

---

### PR #24: Enhanced Documentation 🛠️ INFRASTRUCTURE
**Branch**: `feature/documentation`  
**Priority**: MEDIUM  
**Estimated Effort**: Ongoing  
**Dependencies**: All other PRs

#### Documentation to Create/Update
1. `docs/API.md` - API documentation
2. `docs/ARCHITECTURE.md` - System architecture
3. `docs/CONTRIBUTING.md` - Contribution guidelines
4. `docs/DEPLOYMENT.md` - Deployment guide
5. `docs/USER_GUIDE.md` - End-user documentation
6. `docs/SECURITY.md` - Security practices
7. `docs/diagrams/` - Architecture diagrams

#### Code Documentation
- Add JSDoc-style comments to all public methods
- Document complex algorithms
- Add README to each service directory
- Update main README.md

#### Acceptance Criteria
- All public APIs documented
- Architecture diagrams created
- User guide complete
- Contributing guidelines clear

---

### PR #25: Performance Optimization 🛠️ INFRASTRUCTURE
**Branch**: `feature/performance`  
**Priority**: MEDIUM  
**Estimated Effort**: 3-4 days  
**Dependencies**: Most features implemented

#### Files to Modify
- Various files identified through profiling

#### Features to Implement
- Image optimization
- Lazy loading
- Pagination improvements
- Cache optimization
- Bundle size reduction
- Database query optimization
- Network request batching
- Memory leak fixes

#### Tools to Use
- Flutter DevTools
- Firebase Performance Monitoring
- Lighthouse (for web)

#### Performance Goals
- App startup < 2 seconds
- Screen transitions < 100ms
- Network requests < 1 second
- Memory usage < 200MB
- APK size < 50MB

#### Acceptance Criteria
- Performance metrics meet goals
- No memory leaks detected
- Smooth 60fps animations
- Fast initial load time

---

## Implementation Timeline

### Phase 1: Critical Foundation (Weeks 1-2)
**Goal**: Make app production-ready for MVP
**Status**: ⚠️ Partially Complete (PR #3 completed, original PR #4 still pending)

| Week | PRs | Focus | Status |
|------|-----|-------|--------|
| Week 1 | PR #3, #4, #5 | Settings, Environment, Google Sign-In | ✅ PR #3 Done |
| Week 2 | PR #6 | Payment Integration | ⏳ Pending |

**Note**: GitHub PR #4 (Patient Screens) was completed but differs from the plan's PR #4 (Environment Config)

**Deliverables**: Functional settings ✅, secure configuration ⏳, Google auth ⏳, payment processing ⏳

---

### Phase 2: High Priority Features (Weeks 3-4)
**Goal**: Essential features for good UX

| Week | PRs | Focus |
|------|-----|-------|
| Week 3 | PR #7, #8 | Push Notifications, Google Maps |
| Week 4 | PR #9, #10, #11 | Offline Support, Emergency, Security |

**Deliverables**: Push notifications, maps, offline mode, emergency features, enhanced security

---

### Phase 3: Medium Priority Features (Month 2)
**Goal**: Enhanced functionality

| Week | PRs | Focus |
|------|-----|-------|
| Week 5-6 | PR #12, #13 | AI Integration, Support System |
| Week 7-8 | PR #14, #15, #16 | Ratings, Prescriptions, Lab Results |

**Deliverables**: AI symptom checker, ticketing, reviews, prescriptions, lab results

---

### Phase 4: Polish & Enhancement (Month 3+)
**Goal**: Nice-to-have features

| Week | PRs | Focus |
|------|-----|-------|
| Week 9-10 | PR #17, #18 | i18n, Analytics |
| Week 11-12 | PR #19, #20, #21 | Insurance, Social, Accessibility |

**Deliverables**: Multi-language, analytics, insurance, social features, accessibility

---

### Phase 5: Infrastructure (Ongoing)
**Goal**: Quality & maintainability

| Timeline | PRs | Focus |
|----------|-----|-------|
| Ongoing | PR #22, #23, #24, #25 | Testing, CI/CD, Docs, Performance |

**Deliverables**: Comprehensive tests, automated pipelines, documentation, optimizations

---

## Dependencies Matrix

### Critical Dependencies
```
PR #4 (Environment Config)
  ├── PR #5 (Google Sign-In)
  ├── PR #6 (Payment)
  ├── PR #7 (Push Notifications)
  ├── PR #8 (Google Maps)
  ├── PR #11 (Security Enhancements)
  └── PR #12 (AI Integration)

PR #3 (Settings)
  ├── PR #17 (i18n - language selection)
  └── PR #21 (Accessibility)

PR #6 (Payment)
  ├── PR #15 (Prescriptions - pharmacy payment)
  └── PR #19 (Insurance - billing)

PR #7 (Push Notifications)
  ├── PR #13 (Support - ticket notifications)
  └── PR #20 (Social - challenge notifications)

PR #8 (Google Maps)
  └── PR #10 (Emergency - location sharing)

PR #22 (Testing)
  └── All other PRs (tests for each feature)
```

### No Dependencies
- PR #3 (Settings Implementation)
- PR #9 (Offline Support)
- PR #14 (Ratings & Reviews)
- PR #16 (Lab Results)

---

## Resource Allocation

### If 1 Developer (Full-time)
- **Critical PRs**: 8-10 days
- **High Priority PRs**: 18-24 days
- **Medium Priority PRs**: 22-30 days
- **Low Priority PRs**: 25-35 days
- **Infrastructure**: Ongoing

**Total**: 14-20 weeks (3.5-5 months)

### If 2 Developers
- **Phase 1-2**: 3-4 weeks
- **Phase 3**: 4-5 weeks
- **Phase 4**: 5-6 weeks
- **Infrastructure**: Ongoing

**Total**: 12-15 weeks (3-3.75 months)

### If 3 Developers
- **Phase 1-2**: 2-3 weeks
- **Phase 3**: 3-4 weeks
- **Phase 4**: 4-5 weeks
- **Infrastructure**: Ongoing

**Total**: 9-12 weeks (2.25-3 months)

---

## Priority Justification

### Critical (MUST HAVE for MVP)
1. **Settings** - UI exists but broken
2. **Environment Config** - Security risk without it
3. **Google Sign-In** - Reduces friction in onboarding
4. **Payment** - Required for monetization

### High (IMPORTANT for Production)
1. **Push Notifications** - Expected in modern apps
2. **Google Maps** - Essential for finding doctors
3. **Offline Support** - Poor UX without it
4. **Emergency Features** - Critical for healthcare app
5. **Security Enhancements** - HIPAA/privacy compliance

### Medium (IMPORTANT for UX)
1. **AI Integration** - Differentiator feature
2. **Support System** - User satisfaction
3. **Ratings & Reviews** - Trust building
4. **Prescriptions** - Core healthcare feature
5. **Lab Results** - Medical records management

### Low (NICE TO HAVE)
1. **i18n** - Expands market
2. **Analytics** - Business insights
3. **Insurance** - Advanced feature
4. **Social** - Engagement feature
5. **Accessibility** - Inclusivity

---

## Next Steps

### Completed
1. ✅ **PR #1** - Authentication & Core Infrastructure (Completed)
2. ✅ **PR #2** - Doctor Screens Implementation (Completed) 
3. ✅ **PR #3** - Settings Implementation (Completed)
4. ✅ **PR #4** - Patient Screens & Services (Completed Nov 8, 2024)
   - NotificationService, RealTimeService, TelemedicineService
   - 14 patient screens fully functional
   - Notification state management

### In Progress / Next Up
1. **Review & Approve** remaining PRs in this list
2. **Assign Priorities** to development team
3. **Create Branches** for approved PRs
4. **Set Up Project Board** in GitHub
5. **Begin Implementation** starting with Environment Config (original PR #4 in plan, now renumbered)

---

## Notes

- Each PR should be **independently reviewable**
- PRs should be **merged sequentially** based on dependencies
- **Feature flags** recommended for incomplete features
- **Backward compatibility** must be maintained
- **Documentation** updated with each PR
- **Tests** included with each PR

---

**Document Version**: 1.1  
**Last Updated**: November 26, 2024  
**Prepared By**: AI Code Analysis System  
**Status**: Updated with PR #4 completion tracking

## Completion Log

### November 8, 2024 - PR #4 Merged
Implemented patient screens with notification, real-time, and telemedicine services:
- Created NotificationService for in-app notifications and push notification infrastructure
- Created RealTimeService for Firestore real-time data streams
- Created TelemedicineService for Agora RTC video calling
- Created NotificationProvider for notification state management
- All 14 patient screens made fully functional
- Enhanced Notification model with additional fields
- Added permission_handler dependency for camera/microphone permissions

This partially fulfills requirements outlined in:
- PR #7 (Push Notifications) - Basic infrastructure complete, FCM integration pending
- PR #9 (Offline Support) - Real-time services complete, caching pending
- Various patient screen requirements
