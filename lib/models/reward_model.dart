import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reward {
  late String id;
  late String title;
  late String description;
  late int cost; // Cost in coins
  late int iconCodePoint;
  late Color color;
  late bool isRedeemed;
  late DateTime? redeemedAt;

  Reward({
    required this.title,
    required this.description,
    required this.cost,
    required IconData icon,
    required this.color,
    this.isRedeemed = false,
    this.redeemedAt,
  }) : iconCodePoint = icon.codePoint;

  Reward.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    cost = json['cost'] ?? 0;
    iconCodePoint = json['iconCodePoint'] ?? 0xe22e; // Default icon codepoint
    final colorVal = json['colorValue'];
    if (colorVal is int) {
      color = Color(colorVal);
    } else {
      color = Colors.blue;
    }
    isRedeemed = json['isRedeemed'] ?? false;
    redeemedAt = json['redeemedAt'] != null
        ? (json['redeemedAt'] as Timestamp).toDate()
        : null;
  }

  // Getter to retrieve IconData from stored code point
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'cost': cost,
      'iconCodePoint': iconCodePoint,
      'colorValue': color.value,
      'isRedeemed': isRedeemed,
      'redeemedAt': redeemedAt,
    };
  }

  static List<Reward> getDefaultRewards() {
    return [
      Reward(
        title: 'Ice Cream Break',
        description: 'Treat yourself to your favorite ice cream!',
        cost: 50,
        icon: Icons.icecream,
        color: Colors.pink,
      ),
      Reward(
        title: 'Movie Night',
        description: 'Watch a movie guilt-free!',
        cost: 100,
        icon: Icons.movie,
        color: Colors.purple,
      ),
      Reward(
        title: 'Coffee Shop Visit',
        description: 'Enjoy a premium coffee at your favorite cafe',
        cost: 75,
        icon: Icons.local_cafe,
        color: Colors.brown,
      ),
      Reward(
        title: 'New Book',
        description: 'Buy that book you\'ve been eyeing',
        cost: 150,
        icon: Icons.menu_book,
        color: Colors.teal,
      ),
      Reward(
        title: 'Spa Day',
        description: 'Relax and rejuvenate with a spa session',
        cost: 300,
        icon: Icons.spa,
        color: Colors.cyan,
      ),
      Reward(
        title: 'Gaming Session',
        description: '3 hours of guilt-free gaming',
        cost: 80,
        icon: Icons.sports_esports,
        color: Colors.orange,
      ),
      Reward(
        title: 'Restaurant Dinner',
        description: 'Dinner at a nice restaurant',
        cost: 200,
        icon: Icons.restaurant,
        color: Colors.red,
      ),
      Reward(
        title: 'Shopping Spree',
        description: 'Buy something you\'ve wanted for a while',
        cost: 250,
        icon: Icons.shopping_bag,
        color: Colors.deepPurple,
      ),
      Reward(
        title: 'Day Off',
        description: 'Take a guilt-free day off from responsibilities',
        cost: 500,
        icon: Icons.beach_access,
        color: Colors.lightBlue,
      ),
      Reward(
        title: 'Weekend Getaway',
        description: 'Plan a short trip somewhere new',
        cost: 1000,
        icon: Icons.flight_takeoff,
        color: Colors.indigo,
      ),
    ];
  }
}

class UserCoins {
  late int totalCoins;
  late int spentCoins;

  UserCoins({
    this.totalCoins = 0,
    this.spentCoins = 0,
  });

  int get availableCoins => totalCoins - spentCoins;

  UserCoins.fromJson(Map<String, dynamic> json) {
    totalCoins = json['totalCoins'] ?? 0;
    spentCoins = json['spentCoins'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCoins': totalCoins,
      'spentCoins': spentCoins,
    };
  }
}
