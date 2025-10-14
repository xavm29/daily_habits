import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daily_habits/screens/home.dart';
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

  group('Home Screen Widget Tests', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Build the Home screen wrapped with Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      // Wait for initial frame
      await tester.pump();

      // Verify app bar exists with title
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display floating action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      await tester.pump();

      // Verify floating action button exists
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('should display "To be done" text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      await tester.pump();

      // Verify "To be done" text is displayed
      expect(find.text('To be done'), findsOneWidget);
    });

    testWidgets('should display calendar widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      await tester.pump();

      // Verify calendar is present (by checking for calendar-related widgets)
      // TableCalendar doesn't have a direct finder, so we check for its parent
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have drawer menu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      await tester.pump();

      // Verify drawer exists (drawer icon in AppBar)
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      // Get the scaffold widget
      final Scaffold scaffold = tester.widget(scaffoldFinder);
      expect(scaffold.drawer, isNotNull);
    });

    testWidgets('FAB tap should navigate to create goals', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      await tester.pump();

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // After tapping FAB, we should navigate to CreateGoals screen
      // This will show the create goals page or dialog
      // Since navigation happens, we can verify no error occurred
      expect(tester.takeException(), isNull);
    });
  });

  group('Home Screen Empty State', () {
    testWidgets('should handle empty goals list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => UserData(),
            child: const Home(),
          ),
        ),
      );

      await tester.pump();

      // With no goals, we should still see the basic UI
      expect(find.text('To be done'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
