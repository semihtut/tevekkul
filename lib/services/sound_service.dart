import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = false;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  /// Play a soft click sound for dhikr tap
  Future<void> playTapSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play completion sound when target is reached
  Future<void> playCompletionSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play milestone sound (e.g., every 33 counts)
  Future<void> playMilestoneSound() async {
    if (!_isEnabled) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/milestone.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Dispose the audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
