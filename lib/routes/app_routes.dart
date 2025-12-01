import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/patient/patient_home_screen.dart';
import '../screens/patient/profile_setup_screen.dart';
import '../screens/patient/profile_view_screen.dart';
import '../screens/patient/edit_profile_screen.dart';
import '../screens/patient/doctor_search_screen.dart';
import '../screens/patient/doctor_list_screen.dart';
import '../screens/patient/doctor_profile_screen.dart';
import '../screens/patient/doctor_map_search_screen.dart';
import '../screens/patient/appointment_booking_screen.dart';
import '../screens/patient/appointment_confirmation_screen.dart';
import '../screens/patient/appointment_history_screen.dart';
import '../screens/patient/health_tracker_input_screen.dart';
import '../screens/patient/health_tracker_dashboard_screen.dart';
import '../screens/patient/medication_reminder_setup_screen.dart';
import '../screens/patient/medical_records_screen.dart';
import '../screens/patient/telemedicine_call_screen.dart';
import '../screens/doctor/doctor_home_screen.dart';
import '../screens/doctor/doctor_profile_setup_screen.dart';
import '../screens/doctor/doctor_profile_view_screen.dart';
import '../screens/doctor/patients_list_screen.dart';
import '../screens/doctor/appointment_management_screen.dart';
import '../screens/doctor/patient_details_screen.dart';
import '../screens/doctor/telemedicine_consultation_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/user_management_screen.dart';
import '../screens/admin/content_management_screen.dart';
import '../screens/common/settings_screen.dart';
import '../screens/common/support_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(
        path: '/otp-verification',
        builder: (context, state) => const OTPVerificationScreen()),
    GoRoute(
        path: '/patient/home',
        builder: (context, state) => const PatientHomeScreen()),
    GoRoute(
        path: '/patient/profile-setup',
        builder: (context, state) => const ProfileSetupScreen()),
    GoRoute(
        path: '/patient/profile',
        builder: (context, state) => const ProfileViewScreen()),
    GoRoute(
        path: '/patient/edit-profile',
        builder: (context, state) => const EditProfileScreen()),
    GoRoute(
        path: '/patient/doctor-search',
        builder: (context, state) => const DoctorSearchScreen()),
    GoRoute(
        path: '/patient/doctor-list',
        builder: (context, state) => const DoctorListScreen()),
    GoRoute(
        path: '/patient/doctor-profile',
        builder: (context, state) => const DoctorProfileScreen()),
    GoRoute(
        path: '/patient/doctor-map',
        builder: (context, state) => const DoctorMapSearchScreen()),
    GoRoute(
        path: '/patient/appointment-booking',
        builder: (context, state) => const AppointmentBookingScreen()),
    GoRoute(
        path: '/patient/appointment-confirmation',
        builder: (context, state) => const AppointmentConfirmationScreen()),
    GoRoute(
        path: '/patient/appointment-history',
        builder: (context, state) => const AppointmentHistoryScreen()),
    GoRoute(
        path: '/patient/health-tracker-input',
        builder: (context, state) => const HealthTrackerInputScreen()),
    GoRoute(
        path: '/patient/health-tracker-dashboard',
        builder: (context, state) => const HealthTrackerDashboardScreen()),
    GoRoute(
        path: '/patient/medication-reminder-setup',
        builder: (context, state) => const MedicationReminderSetupScreen()),
    GoRoute(
        path: '/patient/medical-records',
        builder: (context, state) => const MedicalRecordsScreen()),
    GoRoute(
        path: '/patient/telemedicine-call',
        builder: (context, state) => const TelemedicineCallScreen()),
    GoRoute(
        path: '/doctor/home',
        builder: (context, state) => const DoctorHomeScreen()),
    GoRoute(
        path: '/doctor/profile-setup',
        builder: (context, state) => const DoctorProfileSetupScreen()),
    GoRoute(
        path: '/doctor/profile',
        builder: (context, state) => const DoctorProfileViewScreen()),
    GoRoute(
        path: '/doctor/patients',
        builder: (context, state) => const PatientsListScreen()),
    GoRoute(
        path: '/doctor/appointment-management',
        builder: (context, state) => const AppointmentManagementScreen()),
    GoRoute(
        path: '/doctor/patient-details',
        builder: (context, state) => const PatientDetailsScreen()),
    GoRoute(
        path: '/doctor/telemedicine-consultation',
        builder: (context, state) => const TelemedicineConsultationScreen()),
    GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen()),
    GoRoute(
        path: '/admin/user-management',
        builder: (context, state) => const UserManagementScreen()),
    GoRoute(
        path: '/admin/content-management',
        builder: (context, state) => const ContentManagementScreen()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(
        path: '/support', builder: (context, state) => const SupportScreen()),
  ],
  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.role == 'guest' &&
        state.uri.toString() != '/splash' &&
        state.uri.toString() != '/login' &&
        state.uri.toString() != '/signup' &&
        state.uri.toString() != '/forgot-password' &&
        state.uri.toString() != '/otp-verification') {
      return '/login';
    }
    return null;
  },
);
