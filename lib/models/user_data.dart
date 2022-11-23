import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'goals_model.dart';

class UserData extends ChangeNotifier {
  String userName = "";
  String userPhotoUrl = "";
  List<Goal> goals = [];

  setUserName(String userName) async {
    await FirebaseService.instance.updateDisplayName(userName);
    notifyListeners();
  }

  addGoal(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }
}
