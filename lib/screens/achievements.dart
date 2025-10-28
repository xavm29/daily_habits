import 'package:daily_habits/models/gamification_model.dart';
import 'package:daily_habits/models/user_data.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class Achievements extends StatefulWidget {
  const Achievements({Key? key}) : super(key: key);

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  late UserData userData;
  int totalXP = 0;
  UserLevel currentLevel = UserLevel.levels.first;
  List<AchievementBadge> earnedBadges = [];

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    _calculateGamificationStats();
  }

  void _calculateGamificationStats() {
    // Calculate XP
    totalXP = GamificationService.calculateXP(
      habitsCompleted: userData.tasks.length,
      streakDays: _getCurrentStreak(),
      perfectDays: _getPerfectDays(),
    );

    // Get current level
    currentLevel = UserLevel.getLevelForXP(totalXP);

    // Get earned badges
    final stats = {
      'longestStreak': _getLongestStreak(),
      'totalCompleted': userData.tasks.length,
      'earlyBirdCount': _getEarlyBirdCount(),
      'perfectWeeks': _getPerfectWeeks(),
      'goalsCreated': 5, // This would come from Firebase in production
    };

    earnedBadges = AchievementBadge.getEarnedBadges(stats);
  }

  int _getCurrentStreak() {
    if (userData.tasks.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      bool hasTaskForDay = userData.tasks.any((task) {
        DateTime taskDate = DateTime(
          task.completedDateTime.year,
          task.completedDateTime.month,
          task.completedDateTime.day,
        );
        DateTime compareDate = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
        );
        return taskDate == compareDate;
      });

      if (!hasTaskForDay) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _getLongestStreak() {
    if (userData.tasks.isEmpty) return 0;

    List sortedTasks = List.from(userData.tasks)
      ..sort((a, b) => a.completedDateTime.compareTo(b.completedDateTime));

    int maxStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < sortedTasks.length; i++) {
      DateTime prevDate = DateTime(
        sortedTasks[i - 1].completedDateTime.year,
        sortedTasks[i - 1].completedDateTime.month,
        sortedTasks[i - 1].completedDateTime.day,
      );
      DateTime currDate = DateTime(
        sortedTasks[i].completedDateTime.year,
        sortedTasks[i].completedDateTime.month,
        sortedTasks[i].completedDateTime.day,
      );

      if (currDate.difference(prevDate).inDays == 1) {
        currentStreak++;
      } else if (currDate != prevDate) {
        maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
        currentStreak = 1;
      }
    }

    return currentStreak > maxStreak ? currentStreak : maxStreak;
  }

  int _getPerfectDays() {
    // Count days where all goals were completed
    // This is simplified - in production you'd check against actual goals
    return (userData.tasks.length / 3).floor();
  }

  int _getEarlyBirdCount() {
    return userData.tasks.where((task) {
      return task.completedDateTime.hour < 9;
    }).length;
  }

  int _getPerfectWeeks() {
    return (_getCurrentStreak() / 7).floor();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.achievements),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Level Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [currentLevel.color, currentLevel.color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${currentLevel.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentLevel.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '$totalXP XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 20,
                    percent: currentLevel.getProgress(totalXP),
                    center: Text(
                      '${currentLevel.getXPToNextLevel(totalXP)} ${l10n.xpToNextLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    barRadius: const Radius.circular(10),
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    progressColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    GamificationService.getMotivationalMessage(_getCurrentStreak()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Badges Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.badges,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${earnedBadges.length}/${AchievementBadge.allBadges.length}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: AchievementBadge.allBadges.length,
                    itemBuilder: (context, index) {
                      final badge = AchievementBadge.allBadges[index];
                      final isEarned = earnedBadges.contains(badge);

                      return _BadgeCard(
                        badge: badge,
                        isEarned: isEarned,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final AchievementBadge badge;
  final bool isEarned;

  const _BadgeCard({
    required this.badge,
    required this.isEarned,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(badge.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  badge.icon,
                  size: 64,
                  color: isEarned ? badge.color : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(badge.description),
                const SizedBox(height: 8),
                Text(
                  isEarned ? '✅ ${l10n.earned}' : '🔒 ${l10n.locked}',
                  style: TextStyle(
                    color: isEarned ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      },
      child: Card(
        elevation: isEarned ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isEarned
              ? BorderSide(color: badge.color, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.icon,
              size: 48,
              color: isEarned ? badge.color : Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                badge.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                  color: isEarned ? Colors.black : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
