import 'package:flutter/material.dart';
import '../services/smart_reminder_service.dart';
import '../styles/styles.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder time updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
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
                    children: const [
                      Icon(Icons.notifications_active, color: AppColors.primarys, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Smart Reminders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let us remind you at the best time based on your routine',
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
              title: const Text('Default Reminder Time'),
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
              title: const Text('Smart Reminders'),
              subtitle: const Text('Learn from your routine and remind you at the best time'),
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
              title: const Text('Streak Alerts'),
              subtitle: const Text('Get motivated when you\'re on a streak'),
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
              title: const Text('Evening Reminder'),
              subtitle: const Text('Remind you of incomplete habits in the evening'),
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
                      children: const [
                        Text(
                          'How Smart Reminders Work',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'We analyze when you usually complete your habits and send reminders 30 minutes before that time. The more you use the app, the smarter it gets!',
                          style: TextStyle(fontSize: 12),
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
