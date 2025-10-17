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
        title: const Text('Configuración'),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Apariencia'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primarys,
                  ),
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Cambiar entre tema claro y oscuro'),
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
                  title: const Text('Mostrar Hábitos Completados'),
                  subtitle: const Text('Mostrar hábitos completados en la lista'),
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
                  title: const Text('Mostrar Barras de Progreso'),
                  subtitle: const Text('Mostrar indicadores de progreso'),
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
          _buildSectionHeader('Retroalimentación'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up, color: AppColors.primarys),
                  title: const Text('Efectos de Sonido'),
                  subtitle: const Text('Reproducir sonidos al completar hábitos'),
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
                  title: const Text('Vibración'),
                  subtitle: const Text('Vibrar al completar hábitos'),
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
          _buildSectionHeader('Calendario'),
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppColors.primarys),
                  title: const Text('La Semana Comienza en'),
                  subtitle: Text(_weekStartDay == 1 ? 'Lunes' : 'Domingo'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showWeekStartDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.date_range, color: AppColors.primarys),
                  title: const Text('Formato de Fecha'),
                  subtitle: Text(_dateFormat),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showDateFormatDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data & Privacy
          _buildSectionHeader('Datos y Privacidad'),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Borrar Todos los Datos', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Esta acción no se puede deshacer'),
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
        title: const Text('La Semana Comienza en'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Domingo'),
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
              title: const Text('Lunes'),
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
        title: const Text('Formato de Fecha'),
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
        title: const Text('¿Borrar Todos los Datos?'),
        content: const Text(
          'Esto eliminará todos tus hábitos, progreso y configuraciones. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
                      content: Text('Datos borrados exitosamente'),
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
                      content: Text('Error al borrar datos: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );
  }
}
