import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:daily_habits/services/reward_service.dart';
import 'package:daily_habits/models/reward_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

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

  group('RewardService Tests', () {
    late RewardService rewardService;

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

    setUp(() {
      rewardService = RewardService.instance;
    });

    group('calculateCoinsForTask', () {
      test('should return 1 coin for regular task completion', () {
        final coins = rewardService.calculateCoinsForTask(false, 0);
        expect(coins, equals(1));
      });

      test('should return 6 coins for perfect day', () {
        final coins = rewardService.calculateCoinsForTask(true, 0);
        expect(coins, equals(6)); // 1 + 5 (perfect day bonus)
      });

      test('should return 3 coins for 7-day streak', () {
        final coins = rewardService.calculateCoinsForTask(false, 7);
        expect(coins, equals(3)); // 1 + 2 (7-day streak bonus)
      });

      test('should return 6 coins for 30-day streak', () {
        final coins = rewardService.calculateCoinsForTask(false, 30);
        expect(coins, equals(8)); // 1 + 2 (7-day) + 5 (30-day)
      });

      test('should return 13 coins for perfect day with 30-day streak', () {
        final coins = rewardService.calculateCoinsForTask(true, 30);
        expect(coins, equals(13)); // 1 + 5 (perfect) + 2 (7-day) + 5 (30-day)
      });
    });

    group('UserCoins Model', () {
      test('should calculate available coins correctly', () {
        final userCoins = UserCoins(totalCoins: 100, spentCoins: 30);
        expect(userCoins.availableCoins, equals(70));
      });

      test('should handle zero coins', () {
        final userCoins = UserCoins(totalCoins: 0, spentCoins: 0);
        expect(userCoins.availableCoins, equals(0));
      });

      test('should serialize to JSON correctly', () {
        final userCoins = UserCoins(totalCoins: 150, spentCoins: 50);
        final json = userCoins.toJson();

        expect(json['totalCoins'], equals(150));
        expect(json['spentCoins'], equals(50));
      });

      test('should deserialize from JSON correctly', () {
        final json = {'totalCoins': 200, 'spentCoins': 75};
        final userCoins = UserCoins.fromJson(json);

        expect(userCoins.totalCoins, equals(200));
        expect(userCoins.spentCoins, equals(75));
        expect(userCoins.availableCoins, equals(125));
      });
    });

    group('Reward Model', () {
      test('should create reward with all properties', () {
        final reward = Reward(
          title: 'Test Reward',
          description: 'Test Description',
          cost: 100,
          icon: Icons.star,
          color: Colors.blue,
        );

        expect(reward.title, equals('Test Reward'));
        expect(reward.description, equals('Test Description'));
        expect(reward.cost, equals(100));
        expect(reward.isRedeemed, isFalse);
        expect(reward.redeemedAt, isNull);
      });

      test('should serialize reward to JSON', () {
        final reward = Reward(
          title: 'Coffee',
          description: 'Get a coffee',
          cost: 50,
          icon: Icons.local_cafe,
          color: Colors.brown,
        );

        final json = reward.toJson();

        expect(json['title'], equals('Coffee'));
        expect(json['description'], equals('Get a coffee'));
        expect(json['cost'], equals(50));
        expect(json['isRedeemed'], isFalse);
      });

      test('should get default rewards list', () {
        final rewards = Reward.getDefaultRewards();

        expect(rewards, isNotEmpty);
        expect(rewards.length, equals(10));
        expect(rewards.first.title, equals('Ice Cream Break'));
        expect(rewards.last.title, equals('Weekend Getaway'));
      });

      test('default rewards should have appropriate costs', () {
        final rewards = Reward.getDefaultRewards();

        for (var reward in rewards) {
          expect(reward.cost, greaterThan(0));
          expect(reward.cost, lessThanOrEqualTo(1000));
        }
      });
    });
  });
}
