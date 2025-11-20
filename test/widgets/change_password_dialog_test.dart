import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:LifeEase/widgets/settings/change_password_dialog.dart';
import 'package:LifeEase/providers/user_provider.dart';

void main() {
  group('ChangePasswordDialog Widget Tests', () {
    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChangePasswordDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display all password fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
    });

    testWidgets('should display action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Change Password'), findsOneWidget);
    });

    testWidgets('should have password visibility toggles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should have 3 visibility toggle icons (one for each password field)
      expect(find.byIcon(Icons.visibility), findsNWidgets(3));
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Initially all passwords should be hidden (visibility icons shown)
      expect(find.byIcon(Icons.visibility), findsNWidgets(3));

      // Tap first visibility toggle (current password)
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pumpAndSettle();

      // Should now show visibility_off for the toggled field
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    });

    testWidgets('should show error when current password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to submit without entering current password
      await tester.tap(find.widgetWithText(FilledButton, 'Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your current password'), findsOneWidget);
    });

    testWidgets('should show error when new password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter current password but not new password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Current Password'),
        'oldpassword',
      );
      
      await tester.tap(find.widgetWithText(FilledButton, 'Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a new password'), findsOneWidget);
    });

    testWidgets('should show error when new password is too short', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter current password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Current Password'),
        'oldpassword',
      );
      
      // Enter short new password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        '12345',
      );
      
      await tester.tap(find.widgetWithText(FilledButton, 'Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter current password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Current Password'),
        'oldpassword',
      );
      
      // Enter new password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        'newpassword123',
      );
      
      // Enter different confirm password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm New Password'),
        'differentpassword',
      );
      
      await tester.tap(find.widgetWithText(FilledButton, 'Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Change Password'), findsNothing);
    });

    testWidgets('should have lock icons for password fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Should have lock_outline for current password
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      
      // Should have lock icon for new and confirm password
      expect(find.byIcon(Icons.lock), findsNWidgets(2));
    });

    testWidgets('should show validation error when confirm password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter current and new password but not confirm password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Current Password'),
        'oldpassword',
      );
      
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New Password'),
        'newpassword123',
      );
      
      await tester.tap(find.widgetWithText(FilledButton, 'Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Please confirm your new password'), findsOneWidget);
    });
  });
}
