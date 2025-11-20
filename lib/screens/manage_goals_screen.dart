import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../l10n/app_localizations.dart';
import '../models/goals_model.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../styles/styles.dart';
import 'create_goals.dart';

class ManageGoalsScreen extends StatefulWidget {
  const ManageGoalsScreen({super.key});

  @override
  State<ManageGoalsScreen> createState() => _ManageGoalsScreenState();
}

class _ManageGoalsScreenState extends State<ManageGoalsScreen> {
  var goals = <String, Goal>{};

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    if (FirebaseService.instance.isAuthenticated) {
      // Authenticated: Use Firestore stream
      final stream = FirebaseService.instance.goalsStream;
      stream.listen((event) {
        goals.clear();
        for (var doc in event.docs) {
          var goal = Goal.fromJson(doc.data());
          goal.id = doc.id;
          goals[doc.id] = goal;
        }
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      // Not authenticated: Load from local storage
      final localGoals = LocalStorageService.instance.getLocalGoals();
      goals.clear();
      for (var goal in localGoals) {
        goals[goal.id] = goal;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Separate active and expired goals
    final now = DateTime.now();
    final activeGoals = <String, Goal>{};
    final expiredGoals = <String, Goal>{};

    for (var entry in goals.entries) {
      if (entry.value.endDate.isAfter(now)) {
        activeGoals[entry.key] = entry.value;
      } else {
        expiredGoals[entry.key] = entry.value;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.manageGoals),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: goals.isEmpty
          ? _buildEmptyState(l10n)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeGoals.isNotEmpty) ...[
                  Text(
                    l10n.activeGoals,
                    style: TextStyles.bigText,
                  ),
                  const SizedBox(height: 12),
                  ...activeGoals.entries.map((entry) =>
                      _buildGoalCard(entry.key, entry.value, l10n)),
                  const SizedBox(height: 24),
                ],
                if (expiredGoals.isNotEmpty) ...[
                  Text(
                    l10n.expiredGoals,
                    style: TextStyles.bigText.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ...expiredGoals.entries.map((entry) => _buildGoalCard(
                      entry.key, entry.value, l10n,
                      isExpired: true)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGoals()),
          );
        },
        backgroundColor: AppColors.primarys,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noGoalsYet,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createYourFirstGoal,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
      String goalId, Goal goal, AppLocalizations l10n,
      {bool isExpired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Slidable(
        key: ValueKey(goalId),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editGoal(goalId, goal),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: l10n.edit,
            ),
            SlidableAction(
              onPressed: (context) => _deleteGoal(goalId, l10n),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete,
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
              _getGoalIcon(goal),
              size: 40,
              color: isExpired ? Colors.grey : AppColors.primarys,
            ),
            title: Text(
              goal.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isExpired ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      goal.category,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyText(goal, l10n),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.endDate}: ${_formatDate(goal.endDate)}',
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (goal.goalType != Goal.kTypeCheckbox) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.track_changes,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.target}: ${goal.targetValue} ${goal.unit ?? ""}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getGoalIcon(Goal goal) {
    switch (goal.goalType) {
      case Goal.kTypeDuration:
        return Icons.timer;
      case Goal.kTypeQuantity:
        return Icons.numbers;
      default:
        return Icons.flag;
    }
  }

  String _getFrequencyText(Goal goal, AppLocalizations l10n) {
    if (goal.periodic == Goal.kDaily) {
      return l10n.daily;
    } else if (goal.periodic == Goal.kWeekly) {
      final days = goal.weekDays.map((day) => _getDayName(day, l10n)).join(', ');
      return '${l10n.weekly}: $days';
    } else {
      return l10n.daily;
    }
  }

  String _getDayName(int day, AppLocalizations l10n) {
    switch (day) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editGoal(String goalId, Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoals(
          goalId: goalId,
          existingGoal: goal,
        ),
      ),
    );
  }

  Future<void> _deleteGoal(String goalId, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteGoalConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.instance.deleteGoal(goalId);
        // Also delete from local storage for offline users
        if (!FirebaseService.instance.isAuthenticated) {
          await LocalStorageService.instance.deleteGoal(goalId);
          // Reload goals from local storage
          _loadGoals();
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.goalDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
