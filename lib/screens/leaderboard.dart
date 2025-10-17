import 'package:daily_habits/models/user_data.dart';
import 'package:daily_habits/services/firebase_service.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gamification_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Clasificación'),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'XP', icon: Icon(Icons.star)),
            Tab(text: 'Rachas', icon: Icon(Icons.local_fire_department)),
            Tab(text: 'Esta Semana', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildXPLeaderboard(),
          _buildStreakLeaderboard(),
          _buildWeeklyLeaderboard(),
        ],
      ),
    );
  }

  Widget _buildXPLeaderboard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getXPLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Sin clasificaciones aún', Icons.star_outline);
        }

        final leaderboard = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final isCurrentUser = entry['userId'] == currentUserId;
            final rank = index + 1;

            return _buildLeaderboardCard(
              rank: rank,
              userName: entry['userName'] ?? 'Usuario',
              userPhoto: entry['userPhoto'] ?? '',
              value: '${entry['xp']} XP',
              subtitle: 'Nivel ${entry['level']}',
              isCurrentUser: isCurrentUser,
              color: _getRankColor(rank),
            );
          },
        );
      },
    );
  }

  Widget _buildStreakLeaderboard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getStreakLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Sin rachas aún', Icons.local_fire_department);
        }

        final leaderboard = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final isCurrentUser = entry['userId'] == currentUserId;
            final rank = index + 1;

            return _buildLeaderboardCard(
              rank: rank,
              userName: entry['userName'] ?? 'Usuario',
              userPhoto: entry['userPhoto'] ?? '',
              value: '${entry['streak']} días',
              subtitle: '🔥 ¡En racha!',
              isCurrentUser: isCurrentUser,
              color: _getRankColor(rank),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyLeaderboard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getWeeklyLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Sin actividad esta semana', Icons.calendar_today);
        }

        final leaderboard = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final isCurrentUser = entry['userId'] == currentUserId;
            final rank = index + 1;

            return _buildLeaderboardCard(
              rank: rank,
              userName: entry['userName'] ?? 'Usuario',
              userPhoto: entry['userPhoto'] ?? '',
              value: '${entry['completions']} completados',
              subtitle: 'Esta semana',
              isCurrentUser: isCurrentUser,
              color: _getRankColor(rank),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String userName,
    required String userPhoto,
    required String value,
    required String subtitle,
    required bool isCurrentUser,
    required Color color,
  }) {
    return Card(
      elevation: isCurrentUser ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? BorderSide(color: AppColors.primarys, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRankBadge(rank, color),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 24,
              backgroundImage: userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
              child: userPhoto.isEmpty ? const Icon(Icons.person) : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                userName,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarys,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'TÚ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank, Color color) {
    IconData icon;
    if (rank == 1) {
      icon = Icons.emoji_events;
    } else if (rank == 2) {
      icon = Icons.military_tech;
    } else if (rank == 3) {
      icon = Icons.workspace_premium;
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '¡Completa hábitos para ver clasificaciones!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  Future<List<Map<String, dynamic>>> _getXPLeaderboard() async {
    // Simulate leaderboard data - in production this would come from Firebase
    final userData = Provider.of<UserData>(context, listen: false);
    final currentUserXP = GamificationService.calculateXP(
      habitsCompleted: userData.tasks.length,
      streakDays: _getCurrentStreak(userData),
    );

    // Mock data for demonstration
    return [
      {
        'userId': currentUserId,
        'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'You',
        'userPhoto': FirebaseAuth.instance.currentUser?.photoURL ?? '',
        'xp': currentUserXP,
        'level': UserLevel.getLevelForXP(currentUserXP).level,
      },
      {
        'userId': 'user2',
        'userName': 'Alex Johnson',
        'userPhoto': '',
        'xp': currentUserXP - 50,
        'level': UserLevel.getLevelForXP(currentUserXP - 50).level,
      },
      {
        'userId': 'user3',
        'userName': 'Maria Garcia',
        'userPhoto': '',
        'xp': currentUserXP - 120,
        'level': UserLevel.getLevelForXP(currentUserXP - 120).level,
      },
    ]..sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
  }

  Future<List<Map<String, dynamic>>> _getStreakLeaderboard() async {
    final userData = Provider.of<UserData>(context, listen: false);
    final currentStreak = _getCurrentStreak(userData);

    return [
      {
        'userId': currentUserId,
        'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'You',
        'userPhoto': FirebaseAuth.instance.currentUser?.photoURL ?? '',
        'streak': currentStreak,
      },
      {
        'userId': 'user2',
        'userName': 'Alex Johnson',
        'userPhoto': '',
        'streak': currentStreak - 2,
      },
      {
        'userId': 'user3',
        'userName': 'Maria Garcia',
        'userPhoto': '',
        'streak': currentStreak - 5,
      },
    ]..sort((a, b) => (b['streak'] as int).compareTo(a['streak'] as int));
  }

  Future<List<Map<String, dynamic>>> _getWeeklyLeaderboard() async {
    final userData = Provider.of<UserData>(context, listen: false);
    final weeklyCompletions = _getWeeklyCompletions(userData);

    return [
      {
        'userId': currentUserId,
        'userName': FirebaseAuth.instance.currentUser?.displayName ?? 'You',
        'userPhoto': FirebaseAuth.instance.currentUser?.photoURL ?? '',
        'completions': weeklyCompletions,
      },
      {
        'userId': 'user2',
        'userName': 'Alex Johnson',
        'userPhoto': '',
        'completions': weeklyCompletions - 3,
      },
      {
        'userId': 'user3',
        'userName': 'Maria Garcia',
        'userPhoto': '',
        'completions': weeklyCompletions - 7,
      },
    ]..sort((a, b) => (b['completions'] as int).compareTo(a['completions'] as int));
  }

  int _getCurrentStreak(UserData userData) {
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

  int _getWeeklyCompletions(UserData userData) {
    DateTime now = DateTime.now();
    DateTime weekAgo = now.subtract(const Duration(days: 7));

    return userData.tasks.where((task) {
      return task.completedDateTime.isAfter(weekAgo);
    }).length;
  }
}
