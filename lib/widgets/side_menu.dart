import 'package:daily_habits/screens/achievements.dart';
import 'package:daily_habits/screens/profile.dart';
import 'package:daily_habits/screens/statistics.dart';
import 'package:daily_habits/screens/friends.dart';
import 'package:daily_habits/screens/leaderboard.dart';
import 'package:daily_habits/screens/rewards.dart';
import 'package:daily_habits/screens/reminder_settings.dart';
import 'package:daily_habits/screens/settings_screen.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';

import '../screens/challenges.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.purplelow,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.calendar_today, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Hábitos Diarios',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.bar_chart, color: AppColors.primarys),
              title: const Text('Estadísticas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Statistics()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.emoji_events, color: AppColors.primarys),
              title: const Text('Retos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Challenges()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.military_tech, color: AppColors.primarys),
              title: const Text('Logros'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Achievements()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.people, color: AppColors.primarys),
              title: const Text('Amigos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FriendsScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.leaderboard, color: AppColors.primarys),
              title: const Text('Clasificación'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.card_giftcard, color: AppColors.primarys),
              title: const Text('Recompensas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RewardsScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: AppColors.primarys),
              title: const Text('Recordatorios'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReminderSettingsScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primarys),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.person, color: AppColors.primarys),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
