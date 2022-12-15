import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_habits/models/goals_model.dart';
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

  Stream<QuerySnapshot<Map<String, dynamic>>> get goalsStream =>
      _db.collection('users').doc(user?.uid).collection('goals').snapshots();

  // update name
  Future<void> updateDisplayName(String nameEntered) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nameEntered);
  }

  //Upload profile image
  Future<void> updatePhoto(XFile image) async {
    TaskSnapshot taskSnapshot = await _storage
        .ref("users/${user?.uid}/profile")
        .putFile(File(image.path));
    var url = await taskSnapshot.ref.getDownloadURL();
    user?.updatePhotoURL(url);
    UserModel userModel = UserModel(url);
    _db.collection('users').doc(user?.uid).set(userModel.toJson());
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<String> init() async {
    String status = "";
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).catchError((error) {
      status = "Error: ${error.toString()}";
    });
    status = "Firebase inicialitzat";
    return status;
  }

  Future<List<Goal>> getGoals() async {
    await _db.collection('users').doc(user?.uid).collection('goals').get();
    return [];
  }

  Future<List<CompletedTask>> getCompletedTasks() async {
    List<CompletedTask> completedTasks = [];
    QuerySnapshot<Map<String, dynamic>> data = await _db
        .collection('users')
        .doc(user?.uid)
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
    await _db
        .collection('users')
        .doc(user?.uid)
        .collection('goals')
        .add(goal.toJson());
  }

  Future<void> updateGoal(String id, Goal goal) async {
    await _db
        .collection('users')
        .doc(user?.uid)
        .collection('goals')
        .doc(id)
        .update(goal.toJson());
  }

  Future<void> saveCompletedGoals(CompletedTask task) async {
    await _db
        .collection('users')
        .doc(user?.uid)
        .collection('completedGoals')
        .add(task.toJson());
  }
}
