import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  late String id;
  late String fromUserId;
  late String toUserId;
  late String fromUserName;
  late String fromUserPhoto;
  late DateTime createdAt;
  late String status; // 'pending', 'accepted', 'rejected'

  FriendRequest({
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    required this.fromUserPhoto,
    required this.createdAt,
    this.status = 'pending',
  });

  FriendRequest.fromJson(Map<String, dynamic> json) {
    fromUserId = json['fromUserId'];
    toUserId = json['toUserId'];
    fromUserName = json['fromUserName'];
    fromUserPhoto = json['fromUserPhoto'] ?? '';
    createdAt = (json['createdAt'] as Timestamp).toDate();
    status = json['status'] ?? 'pending';
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'fromUserPhoto': fromUserPhoto,
      'createdAt': createdAt,
      'status': status,
    };
  }
}

class Friend {
  late String id;
  late String userId;
  late String userName;
  late String userPhoto;
  late int currentStreak;
  late int totalXP;
  late DateTime addedAt;

  Friend({
    required this.userId,
    required this.userName,
    required this.userPhoto,
    this.currentStreak = 0,
    this.totalXP = 0,
    required this.addedAt,
  });

  Friend.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userPhoto = json['userPhoto'] ?? '';
    currentStreak = json['currentStreak'] ?? 0;
    totalXP = json['totalXP'] ?? 0;
    addedAt = (json['addedAt'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'currentStreak': currentStreak,
      'totalXP': totalXP,
      'addedAt': addedAt,
    };
  }
}

class UserProfile {
  late String userId;
  late String userName;
  late String userPhoto;
  late String email;
  late int currentStreak;
  late int totalXP;
  late int level;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.email,
    this.currentStreak = 0,
    this.totalXP = 0,
    this.level = 1,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userPhoto = json['userPhoto'] ?? '';
    email = json['email'] ?? '';
    currentStreak = json['currentStreak'] ?? 0;
    totalXP = json['totalXP'] ?? 0;
    level = json['level'] ?? 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'email': email,
      'currentStreak': currentStreak,
      'totalXP': totalXP,
      'level': level,
    };
  }
}
