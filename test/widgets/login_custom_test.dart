import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daily_habits/screens/login_custom.dart';
import 'package:daily_habits/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Mock Firebase initialization for testing
class FakeFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'fake-api-key',
    appId: 'fake-app-id',
    messagingSenderId: 'fake-sender-id',
    projectId: 'fake-project-id',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Initialize Firebase for testing
    try {
      await Firebase.initializeApp(
        options: FakeFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase already initialized
    }
  });

  group('LoginCustomScreen Widget Tests', () {
    testWidgets('should display welcome text in sign-in mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify welcome text for sign-in mode
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify email and password fields exist
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sign in button exists
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should display Google sign-in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Google sign-in button text is displayed
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('should display skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify skip button and text
      expect(find.text('Skip for now'), findsOneWidget);
      expect(find.text('You can register later to sync your data'), findsOneWidget);
    });

    testWidgets('should toggle to sign-up mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially in sign-in mode
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Tap the toggle button
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Now in sign-up mode
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Sign up to save your progress'), findsOneWidget);
    });

    testWidgets('should toggle back to sign-in mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to sign-up mode
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Tap toggle back to sign-in
      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      // Back in sign-in mode
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should display OR divider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify OR divider
      expect(find.text('OR'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('should display logo image', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify logo image exists
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should validate empty email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the sign-in button and tap it without filling fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');

      // Try to submit
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password length', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter valid email
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

      // Enter short password
      await tester.enterText(find.byType(TextFormField).last, '12345');

      // Try to submit
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });

  group('LoginCustomScreen Form Interaction', () {
    testWidgets('should accept valid email and password input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter valid email
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');

      // Enter valid password
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.pumpAndSettle();

      // Verify the input was accepted (no validation errors shown immediately)
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    testWidgets('should obscure password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TextFormField wraps a TextField, so we need to check TextField
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeast(2));

      // Password field should be the second one (last)
      final passwordField = tester.widget<TextField>(textFields.last);

      // Verify password is obscured by checking the obscureText property
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('email field should have email keyboard type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const LoginCustomScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TextFormField wraps a TextField, so we need to check TextField
      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeast(2));

      final emailField = tester.widget<TextField>(textFields.first);

      // Verify email keyboard type
      expect(emailField.keyboardType, equals(TextInputType.emailAddress));
    });
  });
}
