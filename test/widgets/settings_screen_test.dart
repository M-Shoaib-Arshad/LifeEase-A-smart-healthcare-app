import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:LifeEase/screens/common/settings_screen.dart';
import 'package:LifeEase/providers/user_provider.dart';
import 'package:LifeEase/providers/settings_provider.dart';
import 'package:LifeEase/providers/theme_provider.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('should display settings screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
    });

    testWidgets('should display all setting sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for section titles
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
    });

    testWidgets('should display change password option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Update your account password'), findsOneWidget);
    });

    testWidgets('should display profile settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Profile Settings'), findsOneWidget);
      expect(find.text('Manage your personal information'), findsOneWidget);
    });

    testWidgets('should display notification settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Configure notification preferences'), findsOneWidget);
    });

    testWidgets('should display language settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Choose your preferred language'), findsOneWidget);
    });

    testWidgets('should display theme settings option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Customize app appearance'), findsOneWidget);
    });

    testWidgets('should display help and support option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Get help and contact support'), findsOneWidget);
    });

    testWidgets('should display about option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('App version and information'), findsOneWidget);
    });

    testWidgets('should display sign out button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should show change password dialog when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on change password
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
    });

    testWidgets('should show logout confirmation dialog when sign out is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on sign out button
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is shown
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should display current language', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Default language should be English
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('should have settings icon in header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsWidgets);
    });

    testWidgets('should have lock icon for password change', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should have person icon for profile', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should have notification icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('should have language icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    });

    testWidgets('should have palette icon for theme', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    });
  });
}
