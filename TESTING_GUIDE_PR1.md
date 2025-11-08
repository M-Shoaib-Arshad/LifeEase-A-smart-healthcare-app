# PR #1 Testing Guide - Authentication Flows

## Overview

This document provides detailed testing procedures for all authentication screens and flows in the LifeEase healthcare application. Follow these test cases to ensure all authentication functionality works correctly.

---

## Test Environment Setup

### Prerequisites
- [ ] Flutter development environment configured
- [ ] Firebase project created and configured
- [ ] Test devices available (iOS Simulator, Android Emulator, or physical devices)
- [ ] Valid test email addresses for different roles
- [ ] Test Firebase project (separate from production)

### Test Data Setup

Create the following test accounts in Firebase Console:

**Patient Account**:
- Email: `patient.test@lifeease.com`
- Password: `Patient123!`
- Role: `patient`

**Doctor Account**:
- Email: `doctor.test@lifeease.com`
- Password: `Doctor123!`
- Role: `doctor`

**Admin Account**:
- Email: `admin.test@lifeease.com`
- Password: `Admin123!`
- Role: `admin`

---

## Test Cases

### 1. Splash Screen Tests

#### TC-SPLASH-001: Splash Screen Display
**Objective**: Verify splash screen appears and animates correctly

**Steps**:
1. Launch the app (fresh install or clear app data)
2. Observe the splash screen

**Expected Results**:
- ✅ Splash screen displays immediately
- ✅ Logo animation plays smoothly (scale and rotation)
- ✅ Text "LifeEase" fades in and slides up
- ✅ Progress bar animates from 0% to 100%
- ✅ Pulse animation effect is visible
- ✅ No visible errors or crashes

**Pass/Fail**: _______

---

#### TC-SPLASH-002: Auto Navigation to Login
**Objective**: Verify automatic navigation after splash screen

**Steps**:
1. Launch the app
2. Wait for 3 seconds
3. Observe navigation

**Expected Results**:
- ✅ App automatically navigates to login screen after ~3 seconds
- ✅ Transition is smooth (no jarring jumps)
- ✅ Login screen loads completely

**Pass/Fail**: _______

---

### 2. Login Screen Tests

#### TC-LOGIN-001: Login Screen Display
**Objective**: Verify all login screen elements are present

**Steps**:
1. Navigate to login screen
2. Review all screen elements

**Expected Results**:
- ✅ "Welcome Back" header is visible
- ✅ Email input field is present
- ✅ Password input field is present
- ✅ Password visibility toggle icon is present
- ✅ Role selection dropdown is present (Patient, Doctor, Admin)
- ✅ "Remember Me" checkbox is present
- ✅ "Login" button is present
- ✅ "Forgot Password?" link is present
- ✅ "Don't have an account? Sign Up" link is present
- ✅ Social login buttons (Google, Facebook) are visible
- ✅ All elements are properly styled and aligned

**Pass/Fail**: _______

---

#### TC-LOGIN-002: Email Validation
**Objective**: Verify email field validation

**Test Data**:
| Input | Expected Behavior |
|-------|------------------|
| (empty) | Show "Please enter your email" |
| `notanemail` | Show "Please enter a valid email" |
| `test@` | Show "Please enter a valid email" |
| `test@example.com` | No error, validation passes |

**Steps**:
1. For each test input:
   - Enter the value in email field
   - Click outside the field or press "Login"
   - Observe validation message

**Expected Results**:
- ✅ All invalid inputs show appropriate error messages
- ✅ Valid email passes validation
- ✅ Error messages are clearly visible in red
- ✅ Error messages disappear when valid input is entered

**Pass/Fail**: _______

---

#### TC-LOGIN-003: Password Validation
**Objective**: Verify password field validation

**Steps**:
1. Leave password field empty
2. Enter valid email
3. Click "Login"

**Expected Results**:
- ✅ Shows "Please enter your password" error
- ✅ Form submission is prevented
- ✅ Error message is visible

**Pass/Fail**: _______

---

#### TC-LOGIN-004: Password Visibility Toggle
**Objective**: Verify password visibility toggle functionality

**Steps**:
1. Enter password: `TestPassword123!`
2. Click the eye icon
3. Click the eye icon again

**Expected Results**:
- ✅ Initially, password is obscured (shows •••)
- ✅ After first click, password is visible as plain text
- ✅ Icon changes from eye to eye-slash
- ✅ After second click, password is obscured again
- ✅ Icon changes back to eye

**Pass/Fail**: _______

---

#### TC-LOGIN-005: Role Selection
**Objective**: Verify role selection dropdown works

**Steps**:
1. Click on role selection dropdown
2. Observe available options
3. Select "Patient"
4. Repeat for "Doctor" and "Admin"

**Expected Results**:
- ✅ Dropdown opens with three options: Patient, Doctor, Admin
- ✅ Selected role is displayed in the dropdown
- ✅ Dropdown closes after selection
- ✅ Selected value is retained

**Pass/Fail**: _______

---

#### TC-LOGIN-006: Successful Login - Patient
**Objective**: Verify patient login and navigation

**Test Data**:
- Email: `patient.test@lifeease.com`
- Password: `Patient123!`
- Role: Patient

**Steps**:
1. Enter valid patient credentials
2. Select "Patient" role
3. Click "Login" button
4. Wait for authentication

**Expected Results**:
- ✅ Loading indicator appears on button
- ✅ Login succeeds without error
- ✅ User is navigated to `/patient/home`
- ✅ Patient home screen displays correctly
- ✅ User data is loaded (name, profile picture)
- ✅ No error messages appear

**Pass/Fail**: _______

---

#### TC-LOGIN-007: Successful Login - Doctor
**Objective**: Verify doctor login and navigation

**Test Data**:
- Email: `doctor.test@lifeease.com`
- Password: `Doctor123!`
- Role: Doctor

**Steps**:
1. Enter valid doctor credentials
2. Select "Doctor" role
3. Click "Login" button
4. Wait for authentication

**Expected Results**:
- ✅ Loading indicator appears
- ✅ Login succeeds
- ✅ User is navigated to `/doctor/home`
- ✅ Doctor dashboard displays correctly
- ✅ Doctor-specific features are visible

**Pass/Fail**: _______

---

#### TC-LOGIN-008: Successful Login - Admin
**Objective**: Verify admin login and navigation

**Test Data**:
- Email: `admin.test@lifeease.com`
- Password: `Admin123!`
- Role: Admin

**Steps**:
1. Enter valid admin credentials
2. Select "Admin" role
3. Click "Login" button
4. Wait for authentication

**Expected Results**:
- ✅ Loading indicator appears
- ✅ Login succeeds
- ✅ User is navigated to `/admin/dashboard` or `/admin/home`
- ✅ Admin dashboard displays correctly
- ✅ Admin-specific features are visible

**Pass/Fail**: _______

---

#### TC-LOGIN-009: Failed Login - Wrong Password
**Objective**: Verify error handling for incorrect password

**Test Data**:
- Email: `patient.test@lifeease.com`
- Password: `WrongPassword123!` (incorrect)

**Steps**:
1. Enter valid email
2. Enter incorrect password
3. Click "Login"

**Expected Results**:
- ✅ Login attempt fails
- ✅ Error message appears: "Sign-in failed: [error details]"
- ✅ User remains on login screen
- ✅ Form fields retain their values
- ✅ Loading state clears

**Pass/Fail**: _______

---

#### TC-LOGIN-010: Failed Login - Non-existent Account
**Objective**: Verify error handling for non-existent email

**Test Data**:
- Email: `nonexistent@example.com`
- Password: `AnyPassword123!`

**Steps**:
1. Enter non-existent email
2. Enter any password
3. Click "Login"

**Expected Results**:
- ✅ Login attempt fails
- ✅ Error message appears indicating user not found
- ✅ User remains on login screen
- ✅ No navigation occurs

**Pass/Fail**: _______

---

#### TC-LOGIN-011: Remember Me Functionality
**Objective**: Verify "Remember Me" checkbox works

**Steps**:
1. Check "Remember Me" checkbox
2. Enter valid credentials
3. Login successfully
4. Close and reopen app
5. Check if user is still logged in

**Expected Results**:
- ✅ Checkbox can be checked/unchecked
- ✅ State is preserved during login
- ✅ (If implemented) User remains logged in after app restart

**Pass/Fail**: _______

---

#### TC-LOGIN-012: Forgot Password Navigation
**Objective**: Verify forgot password link navigation

**Steps**:
1. Click "Forgot Password?" link

**Expected Results**:
- ✅ Navigates to forgot password screen
- ✅ Navigation is smooth (no errors)

**Pass/Fail**: _______

---

#### TC-LOGIN-013: Sign Up Navigation
**Objective**: Verify sign up link navigation

**Steps**:
1. Click "Don't have an account? Sign Up" link

**Expected Results**:
- ✅ Navigates to sign up screen
- ✅ Navigation is smooth

**Pass/Fail**: _______

---

### 3. Sign Up Screen Tests

#### TC-SIGNUP-001: Sign Up Screen Display
**Objective**: Verify all sign up screen elements are present

**Steps**:
1. Navigate to sign up screen
2. Review all screen elements

**Expected Results**:
- ✅ "Create Account" header is visible
- ✅ Avatar upload area with placeholder icon
- ✅ "Upload Photo" button (camera/gallery options)
- ✅ Name input field
- ✅ Email input field
- ✅ Password input field with visibility toggle
- ✅ Role selection dropdown
- ✅ "Sign Up" button
- ✅ "Already have an account? Login" link
- ✅ All elements properly styled

**Pass/Fail**: _______

---

#### TC-SIGNUP-002: Name Validation
**Objective**: Verify name field validation

**Test Data**:
| Input | Expected Behavior |
|-------|------------------|
| (empty) | Show "Please enter your name" |
| `AB` | Show "Name must be at least 3 characters" |
| `John Doe` | No error, validation passes |

**Steps**:
1. For each test input:
   - Enter value in name field
   - Click outside or submit
   - Observe validation

**Expected Results**:
- ✅ All invalid inputs show appropriate errors
- ✅ Valid name passes validation
- ✅ Error messages are clear and visible

**Pass/Fail**: _______

---

#### TC-SIGNUP-003: Email Validation
**Objective**: Verify email validation on signup

**Test Data**:
| Input | Expected Behavior |
|-------|------------------|
| (empty) | Show "Please enter your email" |
| `notanemail` | Show "Please enter a valid email" |
| `existing@email.com` | (On submit) Show "Email already in use" |
| `new@email.com` | No error, validation passes |

**Steps**:
1. Test each input scenario
2. Observe validation messages

**Expected Results**:
- ✅ All validations work as expected
- ✅ Firebase error for existing email is handled gracefully

**Pass/Fail**: _______

---

#### TC-SIGNUP-004: Password Validation
**Objective**: Verify password requirements enforcement

**Test Data**:
| Input | Expected Behavior |
|-------|------------------|
| (empty) | Show "Please enter a password" |
| `short` | Show "Password must be at least 8 characters" |
| `nouppercase123!` | Show "Must contain uppercase letter" |
| `NOLOWERCASE123!` | Show "Must contain lowercase letter" |
| `NoDigits!` | Show "Must contain a number" |
| `ValidPass123!` | No error, validation passes |

**Steps**:
1. Test each password scenario
2. Observe validation

**Expected Results**:
- ✅ All password requirements are enforced
- ✅ Error messages are specific and helpful
- ✅ Strong password is accepted

**Pass/Fail**: _______

---

#### TC-SIGNUP-005: Role Selection Required
**Objective**: Verify role selection is mandatory

**Steps**:
1. Fill all fields except role
2. Click "Sign Up"

**Expected Results**:
- ✅ Shows "Please select a role" error in SnackBar
- ✅ Form submission is prevented
- ✅ User remains on signup screen

**Pass/Fail**: _______

---

#### TC-SIGNUP-006: Avatar Upload - Gallery
**Objective**: Verify avatar upload from gallery

**Steps**:
1. Click "Upload Photo" button
2. Select "Gallery" option
3. Choose an image from gallery
4. Observe result

**Expected Results**:
- ✅ Bottom sheet appears with "Camera" and "Gallery" options
- ✅ Gallery picker opens
- ✅ Selected image displays in avatar placeholder
- ✅ Image is cropped/resized appropriately (circular preview)

**Pass/Fail**: _______

---

#### TC-SIGNUP-007: Avatar Upload - Camera
**Objective**: Verify avatar upload from camera

**Steps**:
1. Click "Upload Photo" button
2. Select "Camera" option
3. Take a photo
4. Observe result

**Expected Results**:
- ✅ Camera permission is requested (if not granted)
- ✅ Camera opens
- ✅ Captured photo displays in avatar placeholder
- ✅ Image quality is acceptable

**Pass/Fail**: _______

---

#### TC-SIGNUP-008: Successful Registration - Patient
**Objective**: Verify complete patient registration flow

**Test Data**:
- Name: `John Patient`
- Email: `john.patient.test@lifeease.com`
- Password: `Patient123!`
- Role: Patient

**Steps**:
1. Fill all required fields with valid data
2. Select "Patient" role
3. Click "Sign Up"
4. Wait for registration to complete

**Expected Results**:
- ✅ Loading indicator appears
- ✅ Firebase Auth account is created
- ✅ Firestore user profile is created with correct data
- ✅ User is navigated to `/otp-verification` screen
- ✅ No error messages appear
- ✅ Data is saved to SharedPreferences

**Pass/Fail**: _______

---

#### TC-SIGNUP-009: Successful Registration - Doctor
**Objective**: Verify doctor registration

**Test Data**:
- Name: `Dr. Sarah Doctor`
- Email: `sarah.doctor.test@lifeease.com`
- Password: `Doctor123!`
- Role: Doctor

**Steps**:
1. Complete registration with doctor role
2. Verify in Firebase Console

**Expected Results**:
- ✅ Registration succeeds
- ✅ User document in Firestore has role: "doctor"
- ✅ Navigation to OTP verification
- ✅ All doctor-specific fields are initialized

**Pass/Fail**: _______

---

#### TC-SIGNUP-010: Duplicate Email Handling
**Objective**: Verify error when email already exists

**Test Data**:
- Email: `patient.test@lifeease.com` (existing)
- Other fields: valid

**Steps**:
1. Attempt to register with existing email
2. Observe error handling

**Expected Results**:
- ✅ Firebase returns "email-already-in-use" error
- ✅ Error message is displayed to user
- ✅ User remains on signup screen
- ✅ Form fields retain their values
- ✅ Loading state clears

**Pass/Fail**: _______

---

#### TC-SIGNUP-011: Back to Login Navigation
**Objective**: Verify navigation back to login

**Steps**:
1. Click "Already have an account? Login" link

**Expected Results**:
- ✅ Navigates to login screen
- ✅ Form data is not lost (optional)

**Pass/Fail**: _______

---

### 4. OTP Verification Tests

#### TC-OTP-001: OTP Screen Display
**Objective**: Verify OTP verification screen elements

**Steps**:
1. Navigate to OTP verification screen (from signup)
2. Review screen elements

**Expected Results**:
- ✅ "Verify OTP" header is visible
- ✅ Instructions text: "Enter the 4-digit code sent to your phone"
- ✅ 4 OTP input boxes are displayed
- ✅ Timer countdown is visible (60 seconds)
- ✅ "Resend OTP" button is present (initially disabled)
- ✅ "Verify" button is present
- ✅ Phone number is displayed (masked: ***-***-1234)

**Pass/Fail**: _______

---

#### TC-OTP-002: OTP Input Behavior
**Objective**: Verify OTP input boxes behavior

**Steps**:
1. Enter first digit
2. Observe cursor movement
3. Enter remaining digits
4. Press backspace
5. Observe cursor movement

**Expected Results**:
- ✅ Cursor auto-focuses to first box
- ✅ After entering digit, cursor moves to next box
- ✅ Each box accepts only one digit
- ✅ Non-numeric input is rejected
- ✅ Backspace moves cursor to previous box
- ✅ Visual feedback when box is filled (changes color)

**Pass/Fail**: _______

---

#### TC-OTP-003: Auto-Submit on Complete
**Objective**: Verify auto-submission when all digits entered

**Steps**:
1. Enter 4 digits rapidly
2. Observe behavior

**Expected Results**:
- ✅ After 4th digit, verification is automatically triggered
- ✅ Loading indicator appears
- ✅ No need to click "Verify" button manually

**Pass/Fail**: _______

---

#### TC-OTP-004: Timer Countdown
**Objective**: Verify countdown timer functionality

**Steps**:
1. Observe timer when screen loads
2. Wait for timer to reach 0

**Expected Results**:
- ✅ Timer starts at 60 seconds
- ✅ Timer counts down: 60, 59, 58...
- ✅ Timer displays in MM:SS format (01:00, 00:59...)
- ✅ When timer reaches 00:00, "Resend OTP" button becomes enabled
- ✅ Timer text turns red when below 10 seconds (optional)

**Pass/Fail**: _______

---

#### TC-OTP-005: Resend OTP
**Objective**: Verify resend OTP functionality

**Steps**:
1. Wait for timer to expire (or manually set to 0)
2. Click "Resend OTP" button
3. Observe behavior

**Expected Results**:
- ✅ "Resend OTP" button is enabled after timer expires
- ✅ Clicking button triggers OTP resend
- ✅ Success message appears: "OTP has been resent"
- ✅ Timer resets to 60 seconds
- ✅ "Resend OTP" button becomes disabled again

**Pass/Fail**: _______

---

#### TC-OTP-006: Correct OTP Verification
**Objective**: Verify successful OTP verification

**Test Data**: Correct OTP (get from Firebase or use test OTP)

**Steps**:
1. Enter correct 4-digit OTP
2. Wait for verification

**Expected Results**:
- ✅ Verification succeeds
- ✅ Success animation plays (green checkmark)
- ✅ User is navigated to appropriate home screen based on role
- ✅ Welcome message appears (optional)

**Pass/Fail**: _______

---

#### TC-OTP-007: Incorrect OTP Verification
**Objective**: Verify error handling for wrong OTP

**Test Data**: Incorrect OTP (e.g., 0000)

**Steps**:
1. Enter incorrect 4-digit OTP
2. Observe error handling

**Expected Results**:
- ✅ Verification fails
- ✅ Error message appears: "Invalid OTP. Please try again."
- ✅ OTP boxes shake (error animation)
- ✅ OTP boxes turn red
- ✅ Input boxes are cleared
- ✅ Cursor returns to first box
- ✅ User can retry

**Pass/Fail**: _______

---

### 5. Forgot Password Tests

#### TC-FORGOT-001: Forgot Password Screen Display
**Objective**: Verify forgot password screen elements

**Steps**:
1. Navigate to forgot password screen
2. Review elements

**Expected Results**:
- ✅ "Forgot Password" header is visible
- ✅ Instructions text explaining the process
- ✅ Email input field
- ✅ "Send Reset Link" button
- ✅ "Back to Login" button or link
- ✅ Proper styling and layout

**Pass/Fail**: _______

---

#### TC-FORGOT-002: Email Validation
**Objective**: Verify email validation on forgot password

**Test Data**:
| Input | Expected Behavior |
|-------|------------------|
| (empty) | Show "Please enter your email" |
| `notanemail` | Show "Please enter a valid email" |
| `valid@email.com` | No error, passes validation |

**Steps**:
1. Test each scenario
2. Observe validation

**Expected Results**:
- ✅ All invalid inputs show errors
- ✅ Valid email passes validation

**Pass/Fail**: _______

---

#### TC-FORGOT-003: Send Reset Email - Existing Account
**Objective**: Verify password reset for existing account

**Test Data**: Email of existing account

**Steps**:
1. Enter valid email of existing account
2. Click "Send Reset Link"
3. Check email inbox

**Expected Results**:
- ✅ Loading indicator appears
- ✅ Success dialog appears: "Password reset email sent. Please check your inbox."
- ✅ Email is received in inbox (check spam folder too)
- ✅ Email contains reset link
- ✅ Email is properly formatted with app branding

**Pass/Fail**: _______

---

#### TC-FORGOT-004: Send Reset Email - Non-existent Account
**Objective**: Verify behavior for non-existent email

**Test Data**: Non-existent email

**Steps**:
1. Enter email that doesn't exist
2. Click "Send Reset Link"

**Expected Results**:
- ✅ Request completes (Firebase returns success for security)
- ✅ Success message is shown (doesn't reveal if email exists)
- ✅ OR error message if Firebase is configured to return error

**Note**: Firebase typically doesn't reveal if email exists for security reasons.

**Pass/Fail**: _______

---

#### TC-FORGOT-005: Reset Link Functionality
**Objective**: Verify password reset link works

**Steps**:
1. Send reset email
2. Open email and click reset link
3. Enter new password
4. Complete reset process
5. Try logging in with new password

**Expected Results**:
- ✅ Reset link opens password reset page
- ✅ User can enter new password
- ✅ Password requirements are enforced
- ✅ Reset completes successfully
- ✅ Login works with new password
- ✅ Old password no longer works

**Pass/Fail**: _______

---

#### TC-FORGOT-006: Expired Reset Link
**Objective**: Verify handling of expired reset link

**Steps**:
1. Send reset email
2. Wait for link to expire (default 1 hour)
3. Try to use expired link

**Expected Results**:
- ✅ Error message appears: "Reset link has expired"
- ✅ User is prompted to request new link
- ✅ Process can be restarted

**Pass/Fail**: _______

---

#### TC-FORGOT-007: Back to Login Navigation
**Objective**: Verify back to login functionality

**Steps**:
1. Click "Back to Login" button

**Expected Results**:
- ✅ Navigates back to login screen
- ✅ No data is lost
- ✅ Navigation is smooth

**Pass/Fail**: _______

---

## Integration Tests

### IT-001: Complete Sign Up and Login Flow
**Objective**: Test end-to-end user journey

**Steps**:
1. Launch app (splash screen)
2. Navigate to sign up
3. Complete registration with all details
4. Verify OTP
5. Arrive at home screen
6. Logout
7. Login with same credentials
8. Verify successful login

**Expected Results**:
- ✅ All steps complete without errors
- ✅ User data persists across sessions
- ✅ Role-based routing works correctly

**Pass/Fail**: _______

---

### IT-002: Password Reset Flow
**Objective**: Test complete password reset journey

**Steps**:
1. Create account
2. Login successfully
3. Logout
4. Use "Forgot Password"
5. Reset password via email
6. Login with new password

**Expected Results**:
- ✅ Password reset completes successfully
- ✅ Old password no longer works
- ✅ New password works for login

**Pass/Fail**: _______

---

### IT-003: Role-Based Navigation
**Objective**: Verify all roles navigate to correct screens

**Steps**:
1. Login as Patient → verify navigates to `/patient/home`
2. Logout
3. Login as Doctor → verify navigates to `/doctor/home`
4. Logout
5. Login as Admin → verify navigates to `/admin/dashboard`

**Expected Results**:
- ✅ Each role navigates to correct home screen
- ✅ Role-specific features are visible
- ✅ No access to other role screens

**Pass/Fail**: _______

---

## Performance Tests

### PT-001: App Launch Time
**Objective**: Measure app launch performance

**Steps**:
1. Close app completely
2. Launch app
3. Measure time to splash screen display
4. Measure time to login screen ready

**Acceptance Criteria**:
- ✅ Splash screen appears < 1 second
- ✅ Login screen ready < 3 seconds
- ✅ No visible lag or freezing

**Pass/Fail**: _______

---

### PT-002: Login Response Time
**Objective**: Measure login performance

**Steps**:
1. Enter valid credentials
2. Click login
3. Measure time to home screen

**Acceptance Criteria**:
- ✅ Response < 2 seconds on good network
- ✅ Loading indicator is smooth
- ✅ No UI freezing during login

**Pass/Fail**: _______

---

## Security Tests

### ST-001: Password Storage
**Objective**: Verify passwords are not stored in plain text

**Steps**:
1. Create account with password
2. Check SharedPreferences/local storage
3. Check Firebase Auth console

**Expected Results**:
- ✅ Password is not in SharedPreferences
- ✅ Password is hashed in Firebase Auth
- ✅ No plain text password anywhere

**Pass/Fail**: _______

---

### ST-002: Session Security
**Objective**: Verify secure session management

**Steps**:
1. Login
2. Check authentication token
3. Force token expiry
4. Attempt to access protected route

**Expected Results**:
- ✅ Token is securely stored
- ✅ Expired token redirects to login
- ✅ Session is invalidated on logout

**Pass/Fail**: _______

---

## Accessibility Tests

### AT-001: Screen Reader Support
**Objective**: Verify screen reader compatibility

**Steps**:
1. Enable screen reader (TalkBack/VoiceOver)
2. Navigate through login screen
3. Test all interactive elements

**Expected Results**:
- ✅ All elements are properly labeled
- ✅ Navigation order is logical
- ✅ Form inputs are clearly announced
- ✅ Error messages are read aloud

**Pass/Fail**: _______

---

### AT-002: Font Scaling
**Objective**: Verify app works with large fonts

**Steps**:
1. Enable largest font size in device settings
2. Open app and test all screens

**Expected Results**:
- ✅ All text is readable
- ✅ No text overflow
- ✅ Layout adapts appropriately

**Pass/Fail**: _______

---

## Cross-Platform Tests

### CP-001: iOS Testing
**Objective**: Verify all flows work on iOS

**Devices**: iPhone SE, iPhone 14, iPad
**Steps**: Run all test cases on iOS devices

**Pass/Fail**: _______

---

### CP-002: Android Testing
**Objective**: Verify all flows work on Android

**Devices**: Small phone, Medium phone, Tablet
**Steps**: Run all test cases on Android devices

**Pass/Fail**: _______

---

## Edge Cases

### EC-001: No Internet Connection
**Steps**:
1. Disconnect internet
2. Attempt login
3. Observe error handling

**Expected Results**:
- ✅ Clear error message: "No internet connection"
- ✅ Retry option available

**Pass/Fail**: _______

---

### EC-002: Slow Network
**Steps**:
1. Simulate slow network (3G)
2. Test login and signup
3. Observe loading states

**Expected Results**:
- ✅ Loading indicators show appropriately
- ✅ No timeout errors
- ✅ Operations complete successfully (given enough time)

**Pass/Fail**: _______

---

### EC-003: App Backgrounding During Auth
**Steps**:
1. Start login process
2. Background the app
3. Return to app
4. Complete login

**Expected Results**:
- ✅ State is preserved
- ✅ Login can complete
- ✅ No crash or data loss

**Pass/Fail**: _______

---

## Test Summary

**Total Test Cases**: _____ / _____
**Passed**: _____
**Failed**: _____
**Skipped**: _____

**Pass Rate**: _____% 

**Critical Issues Found**:
1. 
2. 
3. 

**Recommendations**:
1. 
2. 
3. 

**Tested By**: _____________________
**Date**: _____________________
**Build Version**: _____________________

---

## Bug Report Template

Use this template to report any issues found during testing:

```
**Bug ID**: BUG-AUTH-XXX
**Severity**: Critical / High / Medium / Low
**Test Case**: TC-XXX-XXX
**Description**: [Clear description of the issue]
**Steps to Reproduce**:
1. 
2. 
3. 

**Expected Behavior**: 
**Actual Behavior**: 
**Screenshots/Video**: [Attach if applicable]
**Device**: 
**OS Version**: 
**App Version**: 
**Reproducibility**: Always / Sometimes / Rare
```

---

**End of Testing Guide**
