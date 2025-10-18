import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';
import '../models/goals_model.dart';
import 'notification_service.dart';

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
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      // Filter out expired challenges in memory
      final now = DateTime.now();
      return snapshot.docs.map((doc) {
        final challenge = Challenge.fromJson(doc.data());
        challenge.id = doc.id;
        return challenge;
      }).where((challenge) => challenge.endDate.isAfter(now)).toList();
    });
  }

  // Get challenges that the user has joined
  Stream<List<Challenge>> getUserChallenges() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('challenges')
        .where('participants', arrayContains: currentUserId)
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

    // Get challenge details
    final challengeDoc = await _firestore.collection('challenges').doc(challengeId).get();
    if (!challengeDoc.exists) return;

    final challenge = Challenge.fromJson(challengeDoc.data()!);
    challenge.id = challengeDoc.id;

    // Add user to participants
    await _firestore.collection('challenges').doc(challengeId).update({
      'participants': FieldValue.arrayUnion([currentUserId]),
    });

    // Create progress tracking document
    final progress = ChallengeProgress(
      challengeId: challengeId,
      userId: currentUserId!,
    );

    await _firestore
        .collection('challengeProgress')
        .doc('${challengeId}_$currentUserId')
        .set(progress.toJson());

    // Create daily goals/tasks for the challenge
    await _createChallengeGoals(challenge);
  }

  // Create daily goals for a challenge
  Future<void> _createChallengeGoals(Challenge challenge) async {
    if (currentUserId == null) return;

    final now = DateTime.now();
    final startDate = challenge.startDate.isAfter(now) ? challenge.startDate : now;

    // Create one daily recurring goal for the challenge
    final goal = Goal(
      '${challenge.title}',
      challenge.habitCategory,
      Goal.kDaily, // Daily
      [1, 2, 3, 4, 5, 6, 7], // All days of the week (Mon-Sun)
      challenge.endDate,
      DateTime(now.year, now.month, now.day, 9, 0), // 9 AM reminder
      goalType: Goal.kTypeCheckbox,
    );

    final docRef = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('goals')
        .add(goal.toJson());

    // Schedule notification for this goal
    final notificationService = NotificationService();
    await notificationService.scheduleDailyNotification(
      id: docRef.id.hashCode, // Use document ID hash as notification ID
      title: 'Recordatorio: ${challenge.title}',
      body: '¡No olvides completar tu reto de hoy!',
      hour: 9,
      minute: 0,
      payload: challenge.title,
    );
  }

  // Leave a challenge
  Future<void> leaveChallenge(String challengeId) async {
    if (currentUserId == null) return;

    // Get challenge details to find and delete the goal
    final challengeDoc = await _firestore.collection('challenges').doc(challengeId).get();
    if (challengeDoc.exists) {
      final challenge = Challenge.fromJson(challengeDoc.data()!);

      // Delete the goal associated with this challenge
      final goalsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('goals')
          .where('title', isEqualTo: challenge.title)
          .get();

      for (var doc in goalsSnapshot.docs) {
        await doc.reference.delete();
      }
    }

    await _firestore.collection('challenges').doc(challengeId).update({
      'participants': FieldValue.arrayRemove([currentUserId]),
    });

    // Delete progress tracking document
    await _firestore
        .collection('challengeProgress')
        .doc('${challengeId}_$currentUserId')
        .delete();
  }

  // Create a new challenge
  Future<String?> createChallenge(Challenge challenge) async {
    if (currentUserId == null) return null;

    final docRef = await _firestore.collection('challenges').add(challenge.toJson());
    return docRef.id;
  }

  // Get user's progress in a challenge
  Stream<ChallengeProgress?> getUserProgress(String challengeId) {
    if (currentUserId == null) return Stream.value(null);

    return _firestore
        .collection('challengeProgress')
        .doc('${challengeId}_$currentUserId')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      final progress = ChallengeProgress.fromJson(snapshot.data()!);
      progress.id = snapshot.id;
      return progress;
    });
  }

  // Mark today as completed for a challenge
  Future<void> markTodayCompleted(String challengeId) async {
    if (currentUserId == null) return;

    final docRef = _firestore
        .collection('challengeProgress')
        .doc('${challengeId}_$currentUserId');

    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final progress = ChallengeProgress.fromJson(snapshot.data()!);

    // Only mark if not already completed today
    if (!progress.hasCompletedToday()) {
      progress.markTodayAsCompleted();
      await docRef.update(progress.toJson());
    }
  }

  // Check if user has completed today
  Future<bool> hasCompletedToday(String challengeId) async {
    if (currentUserId == null) return false;

    final snapshot = await _firestore
        .collection('challengeProgress')
        .doc('${challengeId}_$currentUserId')
        .get();

    if (!snapshot.exists) return false;

    final progress = ChallengeProgress.fromJson(snapshot.data()!);
    return progress.hasCompletedToday();
  }

  // Get leaderboard for a challenge
  Future<List<Map<String, dynamic>>> getLeaderboard(String challengeId) async {
    final snapshot = await _firestore
        .collection('challengeProgress')
        .where('challengeId', isEqualTo: challengeId)
        .get();

    List<Map<String, dynamic>> leaderboard = [];
    for (var doc in snapshot.docs) {
      final progress = ChallengeProgress.fromJson(doc.data());

      // Fetch user info
      final userSnapshot = await _firestore.collection('users').doc(progress.userId).get();
      final userData = userSnapshot.data();

      leaderboard.add({
        'userId': progress.userId,
        'completedDays': progress.completedDays,
        'currentStreak': progress.currentStreak,
        'userName': userData?['userName'] ?? 'User',
        'userPhoto': userData?['userPhoto'] ?? '',
      });
    }

    // Sort in memory instead of in query
    leaderboard.sort((a, b) => (b['completedDays'] as int).compareTo(a['completedDays'] as int));

    // Return top 10
    return leaderboard.take(10).toList();
  }

  // Auto-update challenges when a user completes habits
  Future<void> checkAndUpdateChallengesOnHabitCompletion({String? goalTitle, String? goalCategory}) async {
    if (currentUserId == null) return;

    // Get all challenges the user is participating in
    final challengesSnapshot = await _firestore
        .collection('challenges')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in challengesSnapshot.docs) {
      final challengeId = doc.id;
      final challenge = Challenge.fromJson(doc.data());

      // Skip if not active
      if (!challenge.isActive) continue;

      // Check if the completed habit matches this challenge
      // Match by title (exact) or category
      bool isMatchingHabit = false;

      if (goalTitle != null && goalTitle == challenge.title) {
        // Direct title match (habit created from challenge)
        isMatchingHabit = true;
      } else if (goalCategory != null && goalCategory == challenge.habitCategory) {
        // Category match (any habit in the same category)
        isMatchingHabit = true;
      }

      if (!isMatchingHabit) continue;

      // Check if today has already been marked as completed
      final hasCompleted = await hasCompletedToday(challengeId);

      if (!hasCompleted) {
        // Mark today as completed for this challenge
        await markTodayCompleted(challengeId);
      }
    }
  }

  // Force recreate all default challenges (for debugging)
  Future<void> recreateDefaultChallenges() async {
    // Delete all existing system challenges
    final snapshot = await _firestore
        .collection('challenges')
        .where('createdBy', isEqualTo: 'system')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // Create new ones
    await _createDefaultChallenges();
  }

  // Initialize default challenges
  Future<void> initializeDefaultChallenges() async {
    // Check if we already have 5 or more challenges
    final snapshot = await _firestore.collection('challenges').get();
    if (snapshot.docs.length >= 5) return; // Challenges already exist

    await _createDefaultChallenges();
  }

  Future<void> _createDefaultChallenges() async {
    final now = DateTime.now();
    final challenges = [
      Challenge(
        title: '7-Day Consistency Challenge', // Default fallback
        description: 'Complete at least one habit each day for 7 consecutive days',
        titleKey: 'challenge7DayConsistency',
        descriptionKey: 'challenge7DayConsistencyDesc',
        durationDays: 7,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        participants: [],
        createdBy: 'system',
        category: 'Consistency',
        targetCount: 7,
        isActive: true,
        habitCategory: 'any',
      ),
      Challenge(
        title: '30-Day Fitness Challenge',
        description: 'Complete exercise-related habits for 30 days',
        titleKey: 'challenge30DayFitness',
        descriptionKey: 'challenge30DayFitnessDesc',
        durationDays: 30,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        participants: [],
        createdBy: 'system',
        category: 'Health',
        targetCount: 30,
        isActive: true,
        habitCategory: 'fitness',
      ),
      Challenge(
        title: 'Morning Routine Master',
        description: 'Complete your morning routine before 9 AM for 14 days',
        titleKey: 'challengeMorningRoutineMaster',
        descriptionKey: 'challengeMorningRoutineMasterDesc',
        durationDays: 14,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        participants: [],
        createdBy: 'system',
        category: 'Productivity',
        targetCount: 14,
        isActive: true,
        habitCategory: 'morning',
      ),
      Challenge(
        title: '21-Day Reading Challenge',
        description: 'Read at least 15 minutes each day for 21 days',
        titleKey: 'challenge21DayReading',
        descriptionKey: 'challenge21DayReadingDesc',
        durationDays: 21,
        startDate: now,
        endDate: now.add(const Duration(days: 21)),
        participants: [],
        createdBy: 'system',
        category: 'Productivity',
        targetCount: 21,
        isActive: true,
        habitCategory: 'reading',
      ),
      Challenge(
        title: '14-Day Hydration Challenge',
        description: 'Drink at least 8 glasses of water each day for 14 days',
        titleKey: 'challenge14DayHydration',
        descriptionKey: 'challenge14DayHydrationDesc',
        durationDays: 14,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        participants: [],
        createdBy: 'system',
        category: 'Health',
        targetCount: 14,
        isActive: true,
        habitCategory: 'health',
      ),
    ];

    for (var challenge in challenges) {
      await _firestore.collection('challenges').add(challenge.toJson());
    }
  }
}
