import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge_model.dart';

class ChallengeService {
  static final ChallengeService instance = ChallengeService._internal();
  ChallengeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get all active challenges
  Stream<List<Challenge>> getActiveChallenges() {
    return _firestore
        .collection('challenges')
        .where('endDate', isGreaterThan: DateTime.now())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final challenge = Challenge.fromJson(doc.data());
        challenge.id = doc.id;
        return challenge;
      }).toList();
    });
  }

  // Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    if (currentUserId == null) return;

    await _firestore.collection('challenges').doc(challengeId).update({
      'participants': FieldValue.arrayUnion([currentUserId]),
    });
  }

  // Leave a challenge
  Future<void> leaveChallenge(String challengeId) async {
    if (currentUserId == null) return;

    await _firestore.collection('challenges').doc(challengeId).update({
      'participants': FieldValue.arrayRemove([currentUserId]),
    });
  }

  // Create a new challenge
  Future<String?> createChallenge(Challenge challenge) async {
    if (currentUserId == null) return null;

    final docRef = await _firestore.collection('challenges').add(challenge.toJson());
    return docRef.id;
  }

  // Get user's progress in a challenge
  Future<int> getUserProgressInChallenge(String challengeId) async {
    if (currentUserId == null) return 0;

    final snapshot = await _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('progress')
        .doc(currentUserId)
        .get();

    if (!snapshot.exists) return 0;
    return snapshot.data()?['completedCount'] ?? 0;
  }

  // Update user progress in a challenge
  Future<void> updateProgress(String challengeId, int completedCount) async {
    if (currentUserId == null) return;

    await _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('progress')
        .doc(currentUserId)
        .set({
      'completedCount': completedCount,
      'lastUpdated': DateTime.now(),
    }, SetOptions(merge: true));
  }

  // Get leaderboard for a challenge
  Future<List<Map<String, dynamic>>> getLeaderboard(String challengeId) async {
    final snapshot = await _firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('progress')
        .orderBy('completedCount', descending: true)
        .limit(10)
        .get();

    List<Map<String, dynamic>> leaderboard = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      // Fetch user info
      final userSnapshot = await _firestore.collection('users').doc(doc.id).get();
      final userData = userSnapshot.data();

      leaderboard.add({
        'userId': doc.id,
        'completedCount': data['completedCount'] ?? 0,
        'userName': userData?['userName'] ?? 'User',
        'userPhoto': userData?['userPhoto'] ?? '',
      });
    }

    return leaderboard;
  }

  // Initialize default challenges
  Future<void> initializeDefaultChallenges() async {
    // Check if challenges already exist
    final snapshot = await _firestore.collection('challenges').limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // Challenges already exist

    final now = DateTime.now();
    final challenges = [
      Challenge(
        title: '7-Day Consistency Challenge',
        description: 'Complete at least one habit every day for 7 days straight',
        durationDays: 7,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        participants: [],
        createdBy: 'system',
        category: 'Consistency',
        targetCount: 7,
      ),
      Challenge(
        title: '30-Day Fitness Challenge',
        description: 'Complete fitness-related habits for 30 days',
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        participants: [],
        createdBy: 'system',
        category: 'Health',
        targetCount: 30,
      ),
      Challenge(
        title: 'Morning Routine Master',
        description: 'Complete your morning routine before 9 AM for 14 days',
        durationDays: 14,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        participants: [],
        createdBy: 'system',
        category: 'Productivity',
        targetCount: 14,
      ),
    ];

    for (var challenge in challenges) {
      await _firestore.collection('challenges').add(challenge.toJson());
    }
  }
}
