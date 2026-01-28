import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'inner_journey_model.dart';

/// Secure local storage for Inner Journey data
/// All data stays on device - never synced to cloud
class InnerJourneyStorage {
  static const String _boxName = 'inner_journey_private';
  static const String _dataKey = 'journey_data';

  static Box? _box;

  /// Initialize storage
  static Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// Save journey data
  static Future<void> saveData(InnerJourneyData data) async {
    try {
      await init();
      await _box!.put(_dataKey, jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('Error saving inner journey data: $e');
    }
  }

  /// Load journey data
  static Future<InnerJourneyData?> loadData() async {
    try {
      await init();
      final jsonStr = _box!.get(_dataKey);
      if (jsonStr == null) return null;
      return InnerJourneyData.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error loading inner journey data: $e');
      return null;
    }
  }

  /// Check if journey is enabled
  static Future<bool> isEnabled() async {
    final data = await loadData();
    return data?.isEnabled ?? false;
  }

  /// Clear all journey data (when user opts to delete)
  static Future<void> clearAllData() async {
    try {
      await init();
      await _box!.delete(_dataKey);
    } catch (e) {
      debugPrint('Error clearing inner journey data: $e');
    }
  }

  /// Update streak (called daily)
  static Future<void> updateDailyStreak() async {
    final data = await loadData();
    if (data == null || !data.isEnabled) return;

    final calculatedStreak = data.calculatedStreak;

    // Update if streak changed
    if (calculatedStreak != data.currentStreak) {
      final newBest = calculatedStreak > data.bestStreak
          ? calculatedStreak
          : data.bestStreak;

      await saveData(data.copyWith(
        currentStreak: calculatedStreak,
        bestStreak: newBest,
        totalCleanDays: data.totalCleanDays + 1,
      ));
    }
  }

  /// Record a battle won (overcame urge)
  static Future<void> recordBattleWon() async {
    final data = await loadData();
    if (data == null) return;

    await saveData(data.copyWith(
      battlesWon: data.battlesWon + 1,
    ));
  }

  /// Record a slip and reset streak
  static Future<void> recordSlip({String? trigger}) async {
    final data = await loadData();
    if (data == null) return;

    final slip = SlipRecord(
      date: DateTime.now(),
      trigger: trigger,
      streakBroken: data.calculatedStreak,
    );

    // Update trigger counts
    final newTriggerCounts = Map<String, int>.from(data.triggerCounts);
    if (trigger != null && trigger != 'other') {
      newTriggerCounts[trigger] = (newTriggerCounts[trigger] ?? 0) + 1;
    }

    await saveData(data.copyWith(
      currentStreak: 0,
      currentStreakStart: DateTime.now(),
      slipHistory: [...data.slipHistory, slip],
      triggerCounts: newTriggerCounts,
    ));
  }

  /// Disable journey but keep data (hide mode)
  static Future<void> disableKeepData() async {
    final data = await loadData();
    if (data == null) return;

    await saveData(data.copyWith(isEnabled: false));
  }

  /// Re-enable journey
  static Future<void> reEnable() async {
    final data = await loadData();
    if (data == null) return;

    await saveData(data.copyWith(
      isEnabled: true,
      currentStreakStart: DateTime.now(),
      currentStreak: 0,
    ));
  }
}
