import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/dhikr_model.dart';
import '../models/user_progress_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static const String _dhikrsBoxName = 'dhikrs';
  static const String _progressBoxName = 'progress';
  static const String _settingsBoxName = 'settings';
  static const int _currentVersion = 1; // Bump this when schema changes

  late Box<String> _dhikrsBox;
  late Box<String> _progressBox;
  late Box<dynamic> _settingsBox;
  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _dhikrsBox = await Hive.openBox<String>(_dhikrsBoxName);
      _progressBox = await Hive.openBox<String>(_progressBoxName);
      _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
      _prefs = await SharedPreferences.getInstance();

      // Check and run migrations if needed
      await _checkAndMigrate();

      _logger.i('Storage initialized successfully (v$_currentVersion)');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize storage', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Check storage version and run migrations if needed
  Future<void> _checkAndMigrate() async {
    try {
      final storedVersion = _prefs.getInt('storageVersion') ?? 0;

      if (storedVersion < _currentVersion) {
        _logger.i('Migrating storage from v$storedVersion to v$_currentVersion');
        await _runMigrations(storedVersion, _currentVersion);
        await _prefs.setInt('storageVersion', _currentVersion);
        _logger.i('Migration completed successfully');
      }
    } catch (e, stackTrace) {
      _logger.e('Migration failed', error: e, stackTrace: stackTrace);
      // Don't rethrow - allow app to continue with potentially old data
    }
  }

  /// Run all necessary migrations
  Future<void> _runMigrations(int fromVersion, int toVersion) async {
    for (int version = fromVersion; version < toVersion; version++) {
      _logger.i('Running migration: v$version -> v${version + 1}');

      switch (version) {
        case 0:
          await _migrateV0ToV1();
          break;
        // Add future migrations here:
        // case 1:
        //   await _migrateV1ToV2();
        //   break;
      }
    }
  }

  /// Initial migration - sets up version tracking
  Future<void> _migrateV0ToV1() async {
    try {
      _logger.i('Migration v0->v1: Setting up version tracking');

      // Check if data exists (not a fresh install)
      final hasDhikrs = _dhikrsBox.get('dhikrs') != null;
      final hasProgress = _progressBox.get('userProgress') != null;

      if (hasDhikrs || hasProgress) {
        _logger.i('Existing data found, marking as migrated');
        // Data exists, mark as version 1
        await _prefs.setInt('storageVersion', 1);
      } else {
        _logger.i('Fresh install detected');
      }
    } catch (e, stackTrace) {
      _logger.e('Migration v0->v1 failed', error: e, stackTrace: stackTrace);
      throw Exception('Migration v0->v1 failed: $e');
    }
  }

  // ==================== DHIKR STORAGE ====================

  Future<void> saveDhikrs(List<DhikrModel> dhikrs) async {
    try {
      final jsonList = dhikrs.map((d) => jsonEncode(d.toJson())).toList();
      await _dhikrsBox.put('dhikrs', jsonEncode(jsonList));
    } catch (e, stackTrace) {
      _logger.e('Failed to save dhikrs', error: e, stackTrace: stackTrace);
      rethrow; // Re-throw for caller to handle
    }
  }

  List<DhikrModel> loadDhikrs() {
    try {
      final jsonStr = _dhikrsBox.get('dhikrs');
      if (jsonStr == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList
          .map((str) => DhikrModel.fromJson(jsonDecode(str as String)))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Failed to load dhikrs', error: e, stackTrace: stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<void> saveFavorites(List<String> favoriteIds) async {
    await _dhikrsBox.put('favorites', jsonEncode(favoriteIds));
  }

  List<String> loadFavorites() {
    try {
      final jsonStr = _dhikrsBox.get('favorites');
      if (jsonStr == null) return [];
      return List<String>.from(jsonDecode(jsonStr));
    } catch (e, stackTrace) {
      _logger.e('Failed to load favorites', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ==================== ESMA FAVORITES STORAGE ====================

  Future<void> saveEsmaFavorites(List<String> favoriteIds) async {
    await _dhikrsBox.put('esmaFavorites', jsonEncode(favoriteIds));
  }

  List<String> loadEsmaFavorites() {
    try {
      final jsonStr = _dhikrsBox.get('esmaFavorites');
      if (jsonStr == null) return [];
      return List<String>.from(jsonDecode(jsonStr));
    } catch (e, stackTrace) {
      _logger.e('Failed to load esma favorites', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // ==================== USER PROGRESS STORAGE ====================

  Future<void> saveUserProgress(UserProgressModel progress) async {
    try {
      await _progressBox.put('userProgress', jsonEncode(progress.toJson()));
    } catch (e, stackTrace) {
      _logger.e('Failed to save user progress', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  UserProgressModel? loadUserProgress() {
    try {
      final jsonStr = _progressBox.get('userProgress');
      if (jsonStr == null) return null;
      return UserProgressModel.fromJson(jsonDecode(jsonStr));
    } catch (e, stackTrace) {
      _logger.e('Failed to load user progress', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> updateDailyProgress(int count) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final dailyKey = 'daily_$today';
      final current = _progressBox.get(dailyKey);
      final currentCount = current != null ? int.parse(current) : 0;
      await _progressBox.put(dailyKey, (currentCount + count).toString());
    } catch (e, stackTrace) {
      _logger.e('Failed to update daily progress', error: e, stackTrace: stackTrace);
      // Don't rethrow - silent fail for progress tracking
    }
  }

  int getDailyProgress() {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final dailyKey = 'daily_$today';
      final current = _progressBox.get(dailyKey);
      return current != null ? int.parse(current) : 0;
    } catch (e, stackTrace) {
      _logger.e('Failed to get daily progress', error: e, stackTrace: stackTrace);
      return 0;
    }
  }

  Map<String, int> getWeeklyProgress() {
    try {
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
    } catch (e, stackTrace) {
      _logger.e('Failed to get weekly progress', error: e, stackTrace: stackTrace);
      return {};
    }
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

  // ==================== USER NAME STORAGE ====================

  Future<void> saveUserName(String name) async {
    await _settingsBox.put('userName', name);
  }

  String getUserName() {
    return _settingsBox.get('userName', defaultValue: '') as String;
  }

  Future<void> saveOnboardingComplete(bool complete) async {
    await _settingsBox.put('onboardingComplete', complete);
  }

  bool isOnboardingComplete() {
    return _settingsBox.get('onboardingComplete', defaultValue: false) as bool;
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

  // ==================== RAMADAN MODE STORAGE ====================

  Future<void> saveRamadanEnabled(bool enabled) async {
    await _settingsBox.put('ramadanEnabled', enabled);
  }

  bool getRamadanEnabled() {
    return _settingsBox.get('ramadanEnabled', defaultValue: false) as bool;
  }

  // ==================== PRAYER CITY STORAGE ====================

  Future<void> saveSelectedCityId(String cityId) async {
    await _settingsBox.put('selectedCityId', cityId);
  }

  String? getSelectedCityId() {
    return _settingsBox.get('selectedCityId') as String?;
  }

  // ==================== DAILY WIRD STORAGE ====================

  Future<void> saveWirdItems(List<Map<String, dynamic>> items) async {
    await _dhikrsBox.put('wirdItems', jsonEncode(items));
  }

  List<Map<String, dynamic>> loadWirdItems() {
    try {
      final jsonStr = _dhikrsBox.get('wirdItems');
      if (jsonStr == null) return [];
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      _logger.e('Failed to load wird items', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> saveWirdLastReset(DateTime date) async {
    await _prefs.setString('wirdLastReset', date.toIso8601String());
  }

  DateTime? getWirdLastReset() {
    final dateStr = _prefs.getString('wirdLastReset');
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  // ==================== TEVBE STORAGE ====================

  Future<void> saveTevbeSessions(List<Map<String, dynamic>> sessions) async {
    await _dhikrsBox.put('tevbeSessions', jsonEncode(sessions));
  }

  List<Map<String, dynamic>> loadTevbeSessions() {
    try {
      final jsonStr = _dhikrsBox.get('tevbeSessions');
      if (jsonStr == null) return [];
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e, stackTrace) {
      _logger.e('Failed to load tevbe sessions', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> clearTevbeData() async {
    await _dhikrsBox.delete('tevbeSessions');
  }

  // ==================== DATA MANAGEMENT ====================

  Future<void> clearAllData() async {
    await _dhikrsBox.clear();
    await _progressBox.clear();
    await _settingsBox.clear();
    await _prefs.clear();
  }

  Future<String> exportData() async {
    // Collect all daily progress data
    final dailyProgressData = <String, int>{};
    for (var key in _progressBox.keys) {
      if (key.toString().startsWith('daily_')) {
        final value = _progressBox.get(key);
        if (value != null) {
          dailyProgressData[key.toString()] = int.parse(value.toString());
        }
      }
    }

    final data = {
      'version': 1, // For future migration support
      'dhikrs': _dhikrsBox.get('dhikrs'),
      'favorites': _dhikrsBox.get('favorites'),
      'esmaFavorites': _dhikrsBox.get('esmaFavorites'),
      'wirdItems': _dhikrsBox.get('wirdItems'),
      'userProgress': _progressBox.get('userProgress'),
      'dailyProgress': dailyProgressData,
      'settings': {
        'themeMode': getThemeMode(),
        'language': getLanguage(),
        'hapticEnabled': getHapticEnabled(),
        'soundEnabled': getSoundEnabled(),
        'notificationsEnabled': getNotificationsEnabled(),
        'userName': getUserName(),
        'ramadanEnabled': getRamadanEnabled(),
      },
      'streak': {
        'currentStreak': getCurrentStreak(),
        'longestStreak': getLongestStreak(),
        'lastActiveDate': _prefs.getString('lastActiveDate'),
      },
      'dailyEsma': {
        'date': _prefs.getString('dailyEsmaDate'),
        'index': _prefs.getInt('dailyEsmaIndex'),
      },
      'wird': {
        'lastReset': _prefs.getString('wirdLastReset'),
      },
      'exportDate': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // Import dhikrs and favorites
      if (data['dhikrs'] != null) {
        await _dhikrsBox.put('dhikrs', data['dhikrs']);
      }
      if (data['favorites'] != null) {
        await _dhikrsBox.put('favorites', data['favorites']);
      }
      if (data['esmaFavorites'] != null) {
        await _dhikrsBox.put('esmaFavorites', data['esmaFavorites']);
      }
      if (data['wirdItems'] != null) {
        await _dhikrsBox.put('wirdItems', data['wirdItems']);
      }

      // Import user progress
      if (data['userProgress'] != null) {
        await _progressBox.put('userProgress', data['userProgress']);
      }

      // Import daily progress
      if (data['dailyProgress'] != null) {
        final dailyProgress = data['dailyProgress'] as Map<String, dynamic>;
        for (var entry in dailyProgress.entries) {
          await _progressBox.put(entry.key, entry.value.toString());
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        await saveThemeMode(settings['themeMode'] ?? 'system');
        await saveLanguage(settings['language'] ?? 'tr');
        await saveHapticEnabled(settings['hapticEnabled'] ?? true);
        await saveSoundEnabled(settings['soundEnabled'] ?? false);
        await saveNotificationsEnabled(settings['notificationsEnabled'] ?? true);
        if (settings['userName'] != null) {
          await saveUserName(settings['userName']);
        }
        await saveRamadanEnabled(settings['ramadanEnabled'] ?? false);
      }

      // Import streak data
      if (data['streak'] != null) {
        final streak = data['streak'] as Map<String, dynamic>;
        if (streak['currentStreak'] != null) {
          await _prefs.setInt('currentStreak', streak['currentStreak']);
        }
        if (streak['longestStreak'] != null) {
          await _prefs.setInt('longestStreak', streak['longestStreak']);
        }
        if (streak['lastActiveDate'] != null) {
          await _prefs.setString('lastActiveDate', streak['lastActiveDate']);
        }
      }

      // Import daily esma data
      if (data['dailyEsma'] != null) {
        final dailyEsma = data['dailyEsma'] as Map<String, dynamic>;
        if (dailyEsma['date'] != null) {
          await _prefs.setString('dailyEsmaDate', dailyEsma['date']);
        }
        if (dailyEsma['index'] != null) {
          await _prefs.setInt('dailyEsmaIndex', dailyEsma['index']);
        }
      }

      // Import wird data
      if (data['wird'] != null) {
        final wird = data['wird'] as Map<String, dynamic>;
        if (wird['lastReset'] != null) {
          await _prefs.setString('wirdLastReset', wird['lastReset']);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
}
