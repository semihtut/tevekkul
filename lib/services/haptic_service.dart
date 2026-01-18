import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  /// Light haptic feedback for regular taps
  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for important actions
  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for completion or milestones
  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection click for UI selections
  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Vibrate for errors or warnings
  Future<void> vibrate() async {
    if (!_isEnabled) return;
    await HapticFeedback.vibrate();
  }

  /// Custom pattern for dhikr counting
  Future<void> dhikrTap() async {
    if (!_isEnabled) return;
    await HapticFeedback.lightImpact();
  }

  /// Stronger feedback when reaching target
  Future<void> targetReached() async {
    if (!_isEnabled) return;
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Feedback for milestone (e.g., every 33 counts)
  Future<void> milestone() async {
    if (!_isEnabled) return;
    await HapticFeedback.mediumImpact();
  }
}
