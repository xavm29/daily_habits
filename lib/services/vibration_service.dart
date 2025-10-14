import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibrationService {
  static final VibrationService instance = VibrationService._internal();
  VibrationService._internal();

  bool _isEnabled = true;
  bool _hasVibrator = false;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('enable_vibration') ?? true;

    // Check if device has vibrator
    final hasVibrator = await Vibration.hasVibrator();
    _hasVibrator = hasVibrator ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_vibration', enabled);
  }

  bool get isEnabled => _isEnabled;

  Future<void> vibrateSuccess() async {
    if (!_isEnabled || !_hasVibrator) return;

    try {
      // Short vibration pattern for success
      await Vibration.vibrate(duration: 100);
    } catch (e) {
      // Silently fail if vibration doesn't work
      print('Error vibrating: $e');
    }
  }
}
