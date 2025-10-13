import 'package:flutter_test/flutter_test.dart';
import 'package:daily_habits/models/challenge_model.dart';

void main() {
  group('Challenge Model Tests', () {
    late DateTime now;
    late DateTime past;
    late DateTime future;

    setUp(() {
      now = DateTime.now();
      past = now.subtract(const Duration(days: 5));
      future = now.add(const Duration(days: 10));
    });

    group('Challenge Creation', () {
      test('should create challenge with all properties', () {
        final challenge = Challenge(
          title: 'Test Challenge',
          description: 'Test Description',
          durationDays: 30,
          startDate: now,
          endDate: future,
          participants: ['user1', 'user2'],
          createdBy: 'user1',
          category: 'Health',
          targetCount: 30,
        );

        expect(challenge.title, equals('Test Challenge'));
        expect(challenge.description, equals('Test Description'));
        expect(challenge.durationDays, equals(30));
        expect(challenge.participants.length, equals(2));
        expect(challenge.category, equals('Health'));
        expect(challenge.targetCount, equals(30));
      });
    });

    group('isActive', () {
      test('should return true for active challenge', () {
        final challenge = Challenge(
          title: 'Active Challenge',
          description: 'Currently active',
          durationDays: 15,
          startDate: past,
          endDate: future,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 15,
        );

        expect(challenge.isActive(), isTrue);
      });

      test('should return false for challenge not started yet', () {
        final futureStart = now.add(const Duration(days: 5));
        final futureEnd = now.add(const Duration(days: 20));

        final challenge = Challenge(
          title: 'Future Challenge',
          description: 'Starts in future',
          durationDays: 15,
          startDate: futureStart,
          endDate: futureEnd,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 15,
        );

        expect(challenge.isActive(), isFalse);
      });

      test('should return false for expired challenge', () {
        final pastEnd = now.subtract(const Duration(days: 5));
        final pastStart = now.subtract(const Duration(days: 20));

        final challenge = Challenge(
          title: 'Expired Challenge',
          description: 'Already ended',
          durationDays: 15,
          startDate: pastStart,
          endDate: pastEnd,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 15,
        );

        expect(challenge.isActive(), isFalse);
      });
    });

    group('getProgress', () {
      test('should return correct progress percentage', () {
        final challenge = Challenge(
          title: 'Progress Test',
          description: 'Test progress',
          durationDays: 10,
          startDate: now,
          endDate: future,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 10,
        );

        expect(challenge.getProgress(0), equals(0.0));
        expect(challenge.getProgress(5), equals(0.5));
        expect(challenge.getProgress(10), equals(1.0));
      });

      test('should not exceed 1.0 for over-achievement', () {
        final challenge = Challenge(
          title: 'Over Achievement',
          description: 'More than target',
          durationDays: 10,
          startDate: now,
          endDate: future,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 10,
        );

        expect(challenge.getProgress(15), equals(1.0));
        expect(challenge.getProgress(20), equals(1.0));
      });

      test('should return 0 for no completed count', () {
        final challenge = Challenge(
          title: 'No Progress',
          description: 'Zero progress',
          durationDays: 10,
          startDate: now,
          endDate: future,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 10,
        );

        expect(challenge.getProgress(0), equals(0.0));
      });
    });

    group('getDaysRemaining', () {
      test('should return correct days remaining', () {
        final endDate = now.add(const Duration(days: 7));

        final challenge = Challenge(
          title: 'Week Challenge',
          description: 'One week left',
          durationDays: 14,
          startDate: past,
          endDate: endDate,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 14,
        );

        final remaining = challenge.getDaysRemaining();
        expect(remaining, greaterThanOrEqualTo(6));
        expect(remaining, lessThanOrEqualTo(8)); // Allow 1 day tolerance
      });

      test('should return 0 for expired challenge', () {
        final pastEnd = now.subtract(const Duration(days: 5));

        final challenge = Challenge(
          title: 'Expired',
          description: 'Already ended',
          durationDays: 10,
          startDate: past,
          endDate: pastEnd,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 10,
        );

        expect(challenge.getDaysRemaining(), equals(0));
      });
    });

    group('Participant Management', () {
      test('should allow adding participants', () {
        final challenge = Challenge(
          title: 'Growing Challenge',
          description: 'More people joining',
          durationDays: 30,
          startDate: now,
          endDate: future,
          participants: ['user1'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 30,
        );

        challenge.participants.add('user2');
        challenge.participants.add('user3');

        expect(challenge.participants.length, equals(3));
        expect(challenge.participants, contains('user2'));
        expect(challenge.participants, contains('user3'));
      });

      test('should allow removing participants', () {
        final challenge = Challenge(
          title: 'Shrinking Challenge',
          description: 'People leaving',
          durationDays: 30,
          startDate: now,
          endDate: future,
          participants: ['user1', 'user2', 'user3'],
          createdBy: 'user1',
          category: 'General',
          targetCount: 30,
        );

        challenge.participants.remove('user2');

        expect(challenge.participants.length, equals(2));
        expect(challenge.participants, isNot(contains('user2')));
      });
    });
  });
}
