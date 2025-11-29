import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:LifeEase/widgets/auth/social_auth_divider.dart';

void main() {
  group('SocialAuthDivider', () {
    testWidgets('displays the default text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialAuthDivider(),
          ),
        ),
      );

      expect(find.text('Or continue with'), findsOneWidget);
    });

    testWidgets('displays custom text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialAuthDivider(text: 'Or sign up with'),
          ),
        ),
      );

      expect(find.text('Or sign up with'), findsOneWidget);
    });

    testWidgets('contains two dividers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialAuthDivider(),
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocialAuthDivider(),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.byType(Padding).first,
      );
      expect(padding.padding, const EdgeInsets.symmetric(vertical: 16));
    });
  });
}
