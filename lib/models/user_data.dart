import 'package:daily_habits/models/completed_goal.dart';
import 'package:flutter/material.dart';

import '../services/firebase_service.dart';
import 'goals_model.dart';

class UserData extends ChangeNotifier {
  String userName = "";
  String userPhotoUrl = "";
  List<Goal> goals = [];
  List<CompletedTask> tasks = [];

  setUserName(String userName) async {
    await FirebaseService.instance.updateDisplayName(userName);
    notifyListeners();
  }

  addGoal(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }
}

class UserModel {
  late String photoUrl;

  UserModel(this.photoUrl);

  UserModel.fromJson(Map<String, dynamic> json) {
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      'photoUrl': photoUrl,
    };
  }
}
