import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../services/analytics_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../models/user_data.dart';
import '../styles/styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showCompletedHabits = true;
  bool _showProgressBar = true;
  bool _enableSound = true;
  bool _enableVibration = true;
  int _weekStartDay = 1; // 1 = Monday, 0 = Sunday
  String _dateFormat = 'dd/MM/yyyy';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCompletedHabits = prefs.getBool('show_completed') ?? true;
      _showProgressBar = prefs.getBool('show_progress') ?? true;
      _enableSound = SoundService.instance.isEnabled;
      _enableVibration = VibrationService.instance.isEnabled;
      _weekStartDay = prefs.getInt('week_start_day') ?? 1;
      _dateFormat = prefs.getString('date_format') ?? 'dd/MM/yyyy';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primarys,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Switch between light and dark theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                    AnalyticsService.instance.logChangeTheme(isDarkMode: value);
                  },
                  activeColor: AppColors.primarys,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.view_list, color: AppColors.primarys),
                  title: const Text('Show Completed Habits'),
                  subtitle: const Text('Display completed habits in the list'),
                  value: _showCompletedHabits,
                  onChanged: (value) {
                    setState(() {
                      _showCompletedHabits = value;
                    });
                    _saveSetting('show_completed', value);
                  },
                  activeColor: AppColors.primarys,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.bar_chart, color: AppColors.primarys),
                  title: const Text('Show Progress Bars'),
                  subtitle: const Text('Display progress indicators'),
                  value: _showProgressBar,
                  onChanged: (value) {
                    setState(() {
                      _showProgressBar = value;
                    });
                    _saveSetting('show_progress', value);
                  },
                  activeColor: AppColors.primarys,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feedback Section
          _buildSectionHeader('Feedback'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up, color: AppColors.primarys),
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Play sounds when completing habits'),
                  value: _enableSound,
                  onChanged: (value) async {
                    setState(() {
                      _enableSound = value;
                    });
                    await SoundService.instance.setEnabled(value);
                  },
                  activeColor: AppColors.primarys,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration, color: AppColors.primarys),
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate on habit completion'),
                  value: _enableVibration,
                  onChanged: (value) async {
                    setState(() {
                      _enableVibration = value;
                    });
                    await VibrationService.instance.setEnabled(value);
                  },
                  activeColor: AppColors.primarys,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Calendar Section
          _buildSectionHeader('Calendar'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppColors.primarys),
                  title: const Text('Week Starts On'),
                  subtitle: Text(_weekStartDay == 1 ? 'Monday' : 'Sunday'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showWeekStartDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.date_range, color: AppColors.primarys),
                  title: const Text('Date Format'),
                  subtitle: Text(_dateFormat),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDateFormatDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data & Privacy
          _buildSectionHeader('Data & Privacy'),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
              subtitle: const Text('This cannot be undone'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showClearDataDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showWeekStartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Week Starts On'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Sunday'),
              value: 0,
              groupValue: _weekStartDay,
              onChanged: (value) {
                setState(() {
                  _weekStartDay = value!;
                });
                _saveSetting('week_start_day', value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<int>(
              title: const Text('Monday'),
              value: 1,
              groupValue: _weekStartDay,
              onChanged: (value) {
                setState(() {
                  _weekStartDay = value!;
                });
                _saveSetting('week_start_day', value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDateFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDateFormatOption('dd/MM/yyyy'),
            _buildDateFormatOption('MM/dd/yyyy'),
            _buildDateFormatOption('yyyy-MM-dd'),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFormatOption(String format) {
    return RadioListTile<String>(
      title: Text(format),
      value: format,
      groupValue: _dateFormat,
      onChanged: (value) {
        setState(() {
          _dateFormat = value!;
        });
        _saveSetting('date_format', value!);
        Navigator.pop(context);
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all your habits, progress, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Clear local storage
                await LocalStorageService.instance.clearLocalData();

                // Clear Firebase data if user is logged in
                final user = FirebaseService.instance.user;
                if (user != null) {
                  await FirebaseService.instance.clearAllUserData(user.uid);
                }

                // Clear SharedPreferences (except theme preference)
                final prefs = await SharedPreferences.getInstance();
                final isDarkMode = prefs.getBool('isDarkMode');
                await prefs.clear();
                if (isDarkMode != null) {
                  await prefs.setBool('isDarkMode', isDarkMode);
                }

                // Clear provider data
                if (mounted) {
                  final userData = Provider.of<UserData>(context, listen: false);
                  userData.tasks.clear();
                }

                // Track analytics
                await AnalyticsService.instance.logCustomEvent(
                  eventName: 'clear_all_data',
                );

                // Close loading dialog
                if (mounted) Navigator.pop(context);

                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (mounted) Navigator.pop(context);

                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
