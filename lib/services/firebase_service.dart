import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:daily_habits/services/challenge_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../firebase_options.dart';
import '../models/completed_goal.dart';
import '../models/user_data.dart';

class FirebaseService {
  static FirebaseService? _instance;

  static FirebaseService get instance {
    _instance ??= FirebaseService();
    return _instance!;
  }

  User? get user => FirebaseAuth.instance.currentUser;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Check if user is authenticated
  bool get isAuthenticated => user != null;

  // Return empty stream if not authenticated to prevent permission errors
  Stream<QuerySnapshot<Map<String, dynamic>>> get goalsStream {
    if (!isAuthenticated) {
      // Return empty stream for unauthenticated users
      return Stream.empty();
    }
    return _db.collection('users').doc(user!.uid).collection('goals').snapshots();
  }

  // update name
  Future<void> updateDisplayName(String nameEntered) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nameEntered);
  }

  //Upload profile image
  Future<void> updatePhoto(XFile image) async {
    if (!isAuthenticated) return;

    TaskSnapshot taskSnapshot = await _storage
        .ref("users/${user!.uid}/profile")
        .putFile(File(image.path));
    var url = await taskSnapshot.ref.getDownloadURL();
    user?.updatePhotoURL(url);
    UserModel userModel = UserModel(url);
    _db.collection('users').doc(user!.uid).set(userModel.toJson());
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<String> init() async {
    String status = "";
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      status = "Firebase inicialitzat";
    } catch (error) {
      status = "Error: ${error.toString()}";
    }
    return status;
  }

  Future<List<Goal>> getGoals() async {
    if (!isAuthenticated) return [];

    await _db.collection('users').doc(user!.uid).collection('goals').get();
    return [];
  }

  Future<List<CompletedTask>> getCompletedTasks() async {
    if (!isAuthenticated) return [];

    List<CompletedTask> completedTasks = [];
    QuerySnapshot<Map<String, dynamic>> data = await _db
        .collection('users')
        .doc(user!.uid)
        .collection('completedGoals')
        .get();
    if (data.docs.isNotEmpty) {
      for (var element in data.docs) {
        completedTasks.add(CompletedTask.fromJson(element.data()));
      }
    }
    return completedTasks;
  }

  Future<void> saveGoal(Goal goal) async {
    if (!isAuthenticated) return;

    await _db
        .collection('users')
        .doc(user!.uid)
        .collection('goals')
        .add(goal.toJson());
  }

  Future<void> updateGoal(String id, Goal goal) async {
    if (!isAuthenticated) return;

    await _db
        .collection('users')
        .doc(user!.uid)
        .collection('goals')
        .doc(id)
        .update(goal.toJson());
  }

  Future<void> saveCompletedGoals(CompletedTask task) async {
    if (!isAuthenticated) return;

    await _db
        .collection('users')
        .doc(user!.uid)
        .collection('completedGoals')
        .add(task.toJson());

    // Actualizar progreso de retos cuando se completa un objetivo
    try {
      await ChallengeService.instance.checkAndUpdateChallengesOnHabitCompletion();
    } catch (e) {
      // Ignorar errores para no afectar el flujo principal
      print('Error al actualizar progreso del reto: $e');
    }
  }

  Future<void> clearAllUserData(String userId) async {
    if (!isAuthenticated) return;

    // Delete all goals
    final goalsSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();
    for (var doc in goalsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all completed tasks
    final tasksSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('completedGoals')
        .get();
    for (var doc in tasksSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all challenges
    final challengesSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('challenges')
        .get();
    for (var doc in challengesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all rewards
    final rewardsSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('rewards')
        .get();
    for (var doc in rewardsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete all achievements
    final achievementsSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();
    for (var doc in achievementsSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Delete a specific goal
  Future<void> deleteGoal(String goalId) async {
    if (!isAuthenticated) return;

    await _db
        .collection('users')
        .doc(user!.uid)
        .collection('goals')
        .doc(goalId)
        .delete();

    // Also delete any related notifications
    // Note: NotificationService would handle this
  }
}
