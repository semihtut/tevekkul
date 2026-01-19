import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

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
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettingsFromStorage();
  }

  void _loadSettingsFromStorage() {
    final storage = StorageService();
    final themeModeStr = storage.getThemeMode();
    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    state = SettingsState(
      themeMode: themeMode,
      language: storage.getLanguage(),
      hapticEnabled: storage.getHapticEnabled(),
      soundEnabled: storage.getSoundEnabled(),
      notificationsEnabled: storage.getNotificationsEnabled(),
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    final modeStr = mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system');
    StorageService().saveThemeMode(modeStr);
  }

  void setLanguage(String language) {
    state = state.copyWith(language: language);
    StorageService().saveLanguage(language);
  }

  void setHapticEnabled(bool enabled) {
    state = state.copyWith(hapticEnabled: enabled);
    StorageService().saveHapticEnabled(enabled);
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    StorageService().saveSoundEnabled(enabled);
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    StorageService().saveNotificationsEnabled(enabled);
  }

  void toggleHaptic() {
    final newValue = !state.hapticEnabled;
    state = state.copyWith(hapticEnabled: newValue);
    StorageService().saveHapticEnabled(newValue);
  }

  void toggleSound() {
    final newValue = !state.soundEnabled;
    state = state.copyWith(soundEnabled: newValue);
    StorageService().saveSoundEnabled(newValue);
  }

  void toggleNotifications() {
    final newValue = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: newValue);
    StorageService().saveNotificationsEnabled(newValue);
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
