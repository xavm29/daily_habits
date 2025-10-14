import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService instance = SoundService._internal();
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool('enable_sound') ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_sound', enabled);
  }

  bool get isEnabled => _isEnabled;

  Future<void> playSuccessSound() async {
    if (!_isEnabled) return;

    try {
      // TODO: Add success.mp3 file to assets/sounds/ and enable this line
      // await _audioPlayer.play(AssetSource('sounds/success.mp3'));

      // For now, just log that sound would be played
      print('Sound would be played here (add success.mp3 to assets/sounds/)');
    } catch (e) {
      // Silently fail if sound doesn't play
      print('Error playing sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
