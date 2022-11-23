import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;

  static FirebaseService get instance {
    _instance ??= FirebaseService();
    return _instance!;
  }
  final User _user = FirebaseAuth.instance.currentUser!;
  User? get user => FirebaseAuth.instance.currentUser;
  final _db = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>> get tasksStream =>
      _db.collection('users').doc(_user.uid).collection('tasks').snapshots();
  // update name
  Future<void> updateDisplayName(String nameEntered) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(nameEntered);
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
}