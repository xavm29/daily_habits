import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reward_model.dart';

class RewardService {
  static final RewardService instance = RewardService._internal();
  RewardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get user coins
  Stream<UserCoins> getUserCoins() {
    if (currentUserId == null) return Stream.value(UserCoins());

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('rewards')
        .doc('coins')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return UserCoins();
      return UserCoins.fromJson(snapshot.data()!);
    });
  }

  // Add coins (called when completing tasks, streaks, etc.)
  Future<void> addCoins(int amount, {String? reason}) async {
    if (currentUserId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('rewards')
        .doc('coins');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      UserCoins coins;
      if (!snapshot.exists) {
        coins = UserCoins();
      } else {
        coins = UserCoins.fromJson(snapshot.data()!);
      }

      coins.totalCoins += amount;
      transaction.set(docRef, coins.toJson());

      // Log the transaction
      _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .add({
        'amount': amount,
        'type': 'earned',
        'reason': reason ?? 'Task completion',
        'timestamp': DateTime.now(),
      });
    });
  }

  // Redeem reward
  Future<bool> redeemReward(Reward reward) async {
    if (currentUserId == null) return false;

    final docRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('rewards')
        .doc('coins');

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('No coins data found');
        }

        UserCoins coins = UserCoins.fromJson(snapshot.data()!);

        if (coins.availableCoins < reward.cost) {
          throw Exception('Insufficient coins');
        }

        coins.spentCoins += reward.cost;
        transaction.set(docRef, coins.toJson());

        // Save redeemed reward
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('redeemed')
            .add({
          ...reward.toJson(),
          'redeemedAt': DateTime.now(),
        });

        // Log the transaction
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('transactions')
            .add({
          'amount': -reward.cost,
          'type': 'spent',
          'reason': 'Redeemed: ${reward.title}',
          'timestamp': DateTime.now(),
        });
      });
      return true;
    } catch (e) {
      print('Error redeeming reward: $e');
      return false;
    }
  }

  // Get redeemed rewards
  Stream<List<Reward>> getRedeemedRewards() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('redeemed')
        .orderBy('redeemedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final reward = Reward.fromJson(doc.data());
        reward.id = doc.id;
        return reward;
      }).toList();
    });
  }

  // Calculate coins earned from activity
  int calculateCoinsForTask(bool isPerfectDay, int currentStreak) {
    int coins = 1; // Base coins for completing a task

    if (isPerfectDay) {
      coins += 5; // Bonus for perfect day
    }

    if (currentStreak >= 7) {
      coins += 2; // Bonus for week streak
    }

    if (currentStreak >= 30) {
      coins += 5; // Bonus for month streak
    }

    return coins;
  }
}
