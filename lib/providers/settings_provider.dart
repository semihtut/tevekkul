import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final bool hapticEnabled;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final int defaultTarget;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.language = 'tr',
    this.hapticEnabled = true,
    this.soundEnabled = false,
    this.notificationsEnabled = true,
    this.defaultTarget = 33,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? hapticEnabled,
    bool? soundEnabled,
    bool? notificationsEnabled,
    int? defaultTarget,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultTarget: defaultTarget ?? this.defaultTarget,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void setHapticEnabled(bool enabled) {
    state = state.copyWith(hapticEnabled: enabled);
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void setDefaultTarget(int target) {
    state = state.copyWith(defaultTarget: target);
  }

  void loadSettings(SettingsState settings) {
    state = settings;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

final languageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).language;
});

final hapticEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).hapticEnabled;
});
