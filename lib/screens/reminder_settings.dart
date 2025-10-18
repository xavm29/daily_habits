import 'package:flutter/material.dart';
import '../services/smart_reminder_service.dart';
import '../styles/styles.dart';
import '../l10n/app_localizations.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  int _selectedHour = 9;
  int _selectedMinute = 0;
  bool _smartReminders = true;
  bool _streakReminders = true;
  bool _incompleteReminders = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final time = await SmartReminderService.instance.getPreferredReminderTime();
    setState(() {
      _selectedHour = time['hour']!;
      _selectedMinute = time['minute']!;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
    );

    if (picked != null) {
      setState(() {
        _selectedHour = picked.hour;
        _selectedMinute = picked.minute;
      });

      await SmartReminderService.instance.setPreferredReminderTime(
        _selectedHour,
        _selectedMinute,
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reminderTimeUpdated),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminderSettings),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: AppColors.primarys, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.smartReminders,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.letUsRemindYou,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Default Reminder Time
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.access_time, color: AppColors.primarys),
              title: Text(l10n.defaultReminderTime),
              subtitle: Text(
                '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.edit),
              onTap: _selectTime,
            ),
          ),
          const SizedBox(height: 16),

          // Smart Reminders Toggle
          Card(
            elevation: 2,
            child: SwitchListTile(
              secondary: const Icon(Icons.psychology, color: AppColors.primarys),
              title: Text(l10n.smartReminders),
              subtitle: Text(l10n.smartRemindersDescription),
              value: _smartReminders,
              onChanged: (value) {
                setState(() {
                  _smartReminders = value;
                });
              },
              activeColor: AppColors.primarys,
            ),
          ),
          const SizedBox(height: 16),

          // Streak Reminders
          Card(
            elevation: 2,
            child: SwitchListTile(
              secondary: const Icon(Icons.local_fire_department, color: AppColors.primarys),
              title: Text(l10n.streakAlerts),
              subtitle: Text(l10n.getMotivatedOnStreak),
              value: _streakReminders,
              onChanged: (value) {
                setState(() {
                  _streakReminders = value;
                });
              },
              activeColor: AppColors.primarys,
            ),
          ),
          const SizedBox(height: 16),

          // Incomplete Reminders
          Card(
            elevation: 2,
            child: SwitchListTile(
              secondary: const Icon(Icons.pending_actions, color: AppColors.primarys),
              title: Text(l10n.eveningReminder),
              subtitle: Text(l10n.remindIncompleteHabits),
              value: _incompleteReminders,
              onChanged: (value) {
                setState(() {
                  _incompleteReminders = value;
                });
              },
              activeColor: AppColors.primarys,
            ),
          ),
          const SizedBox(height: 24),

          // Info Card
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.howSmartRemindersWork,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.smartRemindersExplanation,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
