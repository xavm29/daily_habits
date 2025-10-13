import 'package:flutter/material.dart';

class UserLevel {
  final int level;
  final String title;
  final int minXP;
  final int maxXP;
  final Color color;

  const UserLevel({
    required this.level,
    required this.title,
    required this.minXP,
    required this.maxXP,
    required this.color,
  });

  static const levels = [
    UserLevel(
      level: 1,
      title: 'Beginner',
      minXP: 0,
      maxXP: 100,
      color: Colors.grey,
    ),
    UserLevel(
      level: 2,
      title: 'Bronze',
      minXP: 100,
      maxXP: 300,
      color: Color(0xFFCD7F32),
    ),
    UserLevel(
      level: 3,
      title: 'Silver',
      minXP: 300,
      maxXP: 600,
      color: Color(0xFFC0C0C0),
    ),
    UserLevel(
      level: 4,
      title: 'Gold',
      minXP: 600,
      maxXP: 1000,
      color: Color(0xFFFFD700),
    ),
    UserLevel(
      level: 5,
      title: 'Platinum',
      minXP: 1000,
      maxXP: 1500,
      color: Color(0xFFE5E4E2),
    ),
    UserLevel(
      level: 6,
      title: 'Diamond',
      minXP: 1500,
      maxXP: 2500,
      color: Color(0xFFB9F2FF),
    ),
    UserLevel(
      level: 7,
      title: 'Master',
      minXP: 2500,
      maxXP: 5000,
      color: Color(0xFF9966CC),
    ),
    UserLevel(
      level: 8,
      title: 'Legend',
      minXP: 5000,
      maxXP: 999999,
      color: Color(0xFFFF6B6B),
    ),
  ];

  static UserLevel getLevelForXP(int xp) {
    for (var level in levels.reversed) {
      if (xp >= level.minXP) {
        return level;
      }
    }
    return levels.first;
  }

  double getProgress(int currentXP) {
    if (currentXP < minXP) return 0.0;
    if (currentXP >= maxXP) return 1.0;
    return (currentXP - minXP) / (maxXP - minXP);
  }

  int getXPToNextLevel(int currentXP) {
    return maxXP - currentXP;
  }
}

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final BadgeCategory category;
  final int requiredValue;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requiredValue,
  });

  static const allBadges = [
    // Streak Badges
    AchievementBadge(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Complete habits for 7 days straight',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      category: BadgeCategory.streak,
      requiredValue: 7,
    ),
    AchievementBadge(
      id: 'streak_30',
      title: 'Month Master',
      description: 'Complete habits for 30 days straight',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      category: BadgeCategory.streak,
      requiredValue: 30,
    ),
    AchievementBadge(
      id: 'streak_100',
      title: 'Century Champion',
      description: 'Complete habits for 100 days straight',
      icon: Icons.local_fire_department,
      color: Colors.red,
      category: BadgeCategory.streak,
      requiredValue: 100,
    ),

    // Total Completion Badges
    AchievementBadge(
      id: 'complete_50',
      title: 'Half Century',
      description: 'Complete 50 total habits',
      icon: Icons.check_circle,
      color: Colors.green,
      category: BadgeCategory.completion,
      requiredValue: 50,
    ),
    AchievementBadge(
      id: 'complete_100',
      title: 'Centurion',
      description: 'Complete 100 total habits',
      icon: Icons.check_circle,
      color: Colors.teal,
      category: BadgeCategory.completion,
      requiredValue: 100,
    ),
    AchievementBadge(
      id: 'complete_500',
      title: 'Habit Hero',
      description: 'Complete 500 total habits',
      icon: Icons.emoji_events,
      color: Colors.amber,
      category: BadgeCategory.completion,
      requiredValue: 500,
    ),

    // Early Bird Badges
    AchievementBadge(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete 10 habits before 9 AM',
      icon: Icons.wb_sunny,
      color: Colors.yellow,
      category: BadgeCategory.timing,
      requiredValue: 10,
    ),

    // Perfect Week
    AchievementBadge(
      id: 'perfect_week',
      title: 'Perfect Week',
      description: 'Complete all habits every day for a week',
      icon: Icons.stars,
      color: Colors.purple,
      category: BadgeCategory.perfection,
      requiredValue: 7,
    ),

    // Goals Created
    AchievementBadge(
      id: 'goal_creator',
      title: 'Goal Setter',
      description: 'Create 10 different habits',
      icon: Icons.flag,
      color: Colors.blue,
      category: BadgeCategory.creation,
      requiredValue: 10,
    ),
  ];

  static List<AchievementBadge> getEarnedBadges(Map<String, dynamic> stats) {
    List<AchievementBadge> earned = [];

    for (var badge in allBadges) {
      bool isEarned = false;

      switch (badge.category) {
        case BadgeCategory.streak:
          isEarned = (stats['longestStreak'] ?? 0) >= badge.requiredValue;
          break;
        case BadgeCategory.completion:
          isEarned = (stats['totalCompleted'] ?? 0) >= badge.requiredValue;
          break;
        case BadgeCategory.timing:
          isEarned = (stats['earlyBirdCount'] ?? 0) >= badge.requiredValue;
          break;
        case BadgeCategory.perfection:
          isEarned = (stats['perfectWeeks'] ?? 0) >= badge.requiredValue;
          break;
        case BadgeCategory.creation:
          isEarned = (stats['goalsCreated'] ?? 0) >= badge.requiredValue;
          break;
      }

      if (isEarned) {
        earned.add(badge);
      }
    }

    return earned;
  }
}

enum BadgeCategory {
  streak,
  completion,
  timing,
  perfection,
  creation,
}

class GamificationService {
  // XP Points for different actions
  static const int xpPerHabitCompleted = 10;
  static const int xpPerStreakDay = 5;
  static const int xpPerPerfectDay = 20; // All habits completed
  static const int xpPerChallenge = 50;

  static int calculateXP({
    int habitsCompleted = 0,
    int streakDays = 0,
    int perfectDays = 0,
    int challengesCompleted = 0,
  }) {
    return (habitsCompleted * xpPerHabitCompleted) +
        (streakDays * xpPerStreakDay) +
        (perfectDays * xpPerPerfectDay) +
        (challengesCompleted * xpPerChallenge);
  }

  static String getMotivationalMessage(int streak) {
    if (streak == 0) return "Start your journey today! 🚀";
    if (streak < 7) return "Great start! Keep going! 💪";
    if (streak < 30) return "You're on fire! 🔥";
    if (streak < 100) return "Incredible dedication! 🌟";
    return "You're a legend! 👑";
  }
}
