import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _donePlayer = AudioPlayer();
  final AudioPlayer _revealPlayer = AudioPlayer();
  bool _isEnabled = false;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  /// Play tick sound for dhikr tap
  Future<void> playTickSound() async {
    if (!_isEnabled) return;
    try {
      await _tickPlayer.play(AssetSource('sounds/tick-tock-94356.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play completion sound when target is reached
  Future<void> playDoneSound() async {
    if (!_isEnabled) return;
    try {
      await _donePlayer.play(AssetSource('sounds/done-463074.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Play reveal sound for Esma Surprise
  Future<void> playRevealSound() async {
    if (!_isEnabled) return;
    try {
      await _revealPlayer.play(AssetSource('sounds/magical-reveal-start-388923.mp3'));
    } catch (e) {
      // Silently fail if sound file not found
    }
  }

  /// Dispose all audio players
  void dispose() {
    _tickPlayer.dispose();
    _donePlayer.dispose();
    _revealPlayer.dispose();
  }
}
