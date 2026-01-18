import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dhikr_model.dart';
import '../models/user_progress_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _dhikrsBoxName = 'dhikrs';
  static const String _progressBoxName = 'progress';
  static const String _settingsBoxName = 'settings';

  late Box<String> _dhikrsBox;
  late Box<String> _progressBox;
  late Box<dynamic> _settingsBox;
  late SharedPreferences _prefs;

  Future<void> init() async {
    await Hive.initFlutter();
    _dhikrsBox = await Hive.openBox<String>(_dhikrsBoxName);
    _progressBox = await Hive.openBox<String>(_progressBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== DHIKR STORAGE ====================

  Future<void> saveDhikrs(List<DhikrModel> dhikrs) async {
    final jsonList = dhikrs.map((d) => jsonEncode(d.toJson())).toList();
    await _dhikrsBox.put('dhikrs', jsonEncode(jsonList));
  }

  List<DhikrModel> loadDhikrs() {
    final jsonStr = _dhikrsBox.get('dhikrs');
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((str) => DhikrModel.fromJson(jsonDecode(str as String)))
        .toList();
  }

  Future<void> saveFavorites(List<String> favoriteIds) async {
    await _dhikrsBox.put('favorites', jsonEncode(favoriteIds));
  }

  List<String> loadFavorites() {
    final jsonStr = _dhikrsBox.get('favorites');
    if (jsonStr == null) return [];
    return List<String>.from(jsonDecode(jsonStr));
  }

  // ==================== USER PROGRESS STORAGE ====================

  Future<void> saveUserProgress(UserProgressModel progress) async {
    await _progressBox.put('userProgress', jsonEncode(progress.toJson()));
  }

  UserProgressModel? loadUserProgress() {
    final jsonStr = _progressBox.get('userProgress');
    if (jsonStr == null) return null;
    return UserProgressModel.fromJson(jsonDecode(jsonStr));
  }

  Future<void> updateDailyProgress(int count) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyKey = 'daily_$today';
    final current = _progressBox.get(dailyKey);
    final currentCount = current != null ? int.parse(current) : 0;
    await _progressBox.put(dailyKey, (currentCount + count).toString());
  }

  int getDailyProgress() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final dailyKey = 'daily_$today';
    final current = _progressBox.get(dailyKey);
    return current != null ? int.parse(current) : 0;
  }

  Map<String, int> getWeeklyProgress() {
    final result = <String, int>{};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final dailyKey = 'daily_$dateStr';
      final current = _progressBox.get(dailyKey);
      result[dateStr] = current != null ? int.parse(current) : 0;
    }

    return result;
  }

  // ==================== SETTINGS STORAGE ====================

  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox.put('themeMode', themeMode);
  }

  String getThemeMode() {
    return _settingsBox.get('themeMode', defaultValue: 'system') as String;
  }

  Future<void> saveLanguage(String language) async {
    await _settingsBox.put('language', language);
  }

  String getLanguage() {
    return _settingsBox.get('language', defaultValue: 'tr') as String;
  }

  Future<void> saveHapticEnabled(bool enabled) async {
    await _settingsBox.put('hapticEnabled', enabled);
  }

  bool getHapticEnabled() {
    return _settingsBox.get('hapticEnabled', defaultValue: true) as bool;
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    await _settingsBox.put('soundEnabled', enabled);
  }

  bool getSoundEnabled() {
    return _settingsBox.get('soundEnabled', defaultValue: false) as bool;
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _settingsBox.put('notificationsEnabled', enabled);
  }

  bool getNotificationsEnabled() {
    return _settingsBox.get('notificationsEnabled', defaultValue: true) as bool;
  }

  // ==================== DAILY ESMA STORAGE ====================

  Future<void> saveDailyEsmaIndex(int index) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _prefs.setString('dailyEsmaDate', today);
    await _prefs.setInt('dailyEsmaIndex', index);
  }

  int? getDailyEsmaIndex() {
    final savedDate = _prefs.getString('dailyEsmaDate');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (savedDate != today) return null;
    return _prefs.getInt('dailyEsmaIndex');
  }

  // ==================== STREAK TRACKING ====================

  Future<void> updateStreak() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastActive = _prefs.getString('lastActiveDate');
    final currentStreak = _prefs.getInt('currentStreak') ?? 0;

    if (lastActive == today) {
      // Already active today
      return;
    }

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    if (lastActive == yesterday) {
      // Continue streak
      await _prefs.setInt('currentStreak', currentStreak + 1);
    } else {
      // Reset streak
      await _prefs.setInt('currentStreak', 1);
    }

    await _prefs.setString('lastActiveDate', today);

    // Update longest streak
    final longestStreak = _prefs.getInt('longestStreak') ?? 0;
    final newStreak = _prefs.getInt('currentStreak') ?? 1;
    if (newStreak > longestStreak) {
      await _prefs.setInt('longestStreak', newStreak);
    }
  }

  int getCurrentStreak() {
    return _prefs.getInt('currentStreak') ?? 0;
  }

  int getLongestStreak() {
    return _prefs.getInt('longestStreak') ?? 0;
  }

  // ==================== DATA MANAGEMENT ====================

  Future<void> clearAllData() async {
    await _dhikrsBox.clear();
    await _progressBox.clear();
    await _settingsBox.clear();
    await _prefs.clear();
  }

  Future<String> exportData() async {
    final data = {
      'dhikrs': _dhikrsBox.get('dhikrs'),
      'favorites': _dhikrsBox.get('favorites'),
      'userProgress': _progressBox.get('userProgress'),
      'settings': {
        'themeMode': getThemeMode(),
        'language': getLanguage(),
        'hapticEnabled': getHapticEnabled(),
        'soundEnabled': getSoundEnabled(),
        'notificationsEnabled': getNotificationsEnabled(),
      },
      'streak': {
        'currentStreak': getCurrentStreak(),
        'longestStreak': getLongestStreak(),
      },
      'exportDate': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonData) async {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;

    if (data['dhikrs'] != null) {
      await _dhikrsBox.put('dhikrs', data['dhikrs']);
    }
    if (data['favorites'] != null) {
      await _dhikrsBox.put('favorites', data['favorites']);
    }
    if (data['userProgress'] != null) {
      await _progressBox.put('userProgress', data['userProgress']);
    }
    if (data['settings'] != null) {
      final settings = data['settings'] as Map<String, dynamic>;
      await saveThemeMode(settings['themeMode'] ?? 'system');
      await saveLanguage(settings['language'] ?? 'tr');
      await saveHapticEnabled(settings['hapticEnabled'] ?? true);
      await saveSoundEnabled(settings['soundEnabled'] ?? false);
      await saveNotificationsEnabled(settings['notificationsEnabled'] ?? true);
    }
  }
}
