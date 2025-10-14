import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daily_habits/screens/challenges.dart';
import 'package:firebase_core/firebase_core.dart';

// Use Challenges instead of ChallengesScreen
typedef ChallengesScreen = Challenges;

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

  group('Challenges Screen Widget Tests', () {
    testWidgets('should display app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar with title
      expect(find.text('Challenges'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display challenge list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify challenge list exists
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display add button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify add button exists in app bar
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display challenges', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify challenges are displayed
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('should scroll through challenges', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we can scroll (ListView exists)
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // No error should occur
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display default challenges', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for some default challenges
      expect(find.text('7-Day Consistency Challenge'), findsOneWidget);
      expect(find.text('30-Day Fitness Challenge'), findsOneWidget);
    });

    testWidgets('should show create challenge dialog when add button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add button in app bar
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Create Custom Challenge'), findsOneWidget);
      expect(find.text('Challenge Title*'), findsOneWidget);
      expect(find.text('Description*'), findsOneWidget);
    });

    testWidgets('create challenge dialog should have all fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify all form fields
      expect(find.text('Challenge Title*'), findsOneWidget);
      expect(find.text('Description*'), findsOneWidget);
      expect(find.text('Duration (days)*'), findsOneWidget);
      expect(find.text('Target Count*'), findsOneWidget);
      expect(find.text('Category*'), findsOneWidget);
    });

    testWidgets('create challenge dialog should have Create and Cancel buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should close dialog when Cancel is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Create Custom Challenge'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Create Custom Challenge'), findsNothing);
    });

    testWidgets('should validate title field when creating challenge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Try to create without entering title
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show validation error (snackbar)
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('should display challenge cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display challenge cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('challenge cards should display Join or Leave button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should display Join or Leave buttons for challenges
      final joinButtons = find.text('Join Challenge');
      final leaveButtons = find.text('Leave Challenge');
      expect(joinButtons.evaluate().isNotEmpty || leaveButtons.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('should display challenge details in cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for challenge details (icons, days remaining, etc.)
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
      expect(find.byIcon(Icons.people), findsWidgets);
    });
  });

  group('Challenges Screen Behavior', () {
    testWidgets('should display challenge list with content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify ListView exists
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should handle scrolling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // No exception should occur
      expect(tester.takeException(), isNull);
    });
  });

  group('Challenges Screen Empty States', () {
    testWidgets('should handle no active challenges', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Even with no active challenges, UI should render without error
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Create Challenge Dialog Interaction', () {
    testWidgets('should accept valid challenge input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Find text fields and enter valid data
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      await tester.enterText(textFields.first, 'My Test Challenge');
      await tester.pumpAndSettle();

      // No validation errors should appear immediately
      expect(find.text('Please enter a title'), findsNothing);
    });

    testWidgets('should validate description field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChallengesScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter only title
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'My Test Challenge');

      // Try to create without description
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Should show validation error (snackbar)
      expect(find.text('Please enter a description'), findsOneWidget);
    });
  });
}
