import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inner_journey_model.dart';
import '../data/inner_journey_storage.dart';
import '../data/daily_wisdom_model.dart';

/// Provider for Inner Journey data
class InnerJourneyNotifier extends StateNotifier<InnerJourneyData> {
  InnerJourneyNotifier() : super(const InnerJourneyData()) {
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await InnerJourneyStorage.loadData();
    if (data != null) {
      // Update streak based on current date
      final calculatedStreak = data.calculatedStreak;
      if (calculatedStreak != data.currentStreak) {
        final newBest = calculatedStreak > data.bestStreak
            ? calculatedStreak
            : data.bestStreak;
        final updatedData = data.copyWith(
          currentStreak: calculatedStreak,
          bestStreak: newBest,
        );
        state = updatedData;
        await InnerJourneyStorage.saveData(updatedData);
      } else {
        state = data;
      }
    }
  }

  /// Start a new journey
  Future<void> startJourney(StruggleType type) async {
    final newData = InnerJourneyData.initial(struggleType: type);
    state = newData;
    await InnerJourneyStorage.saveData(newData);
  }

  /// Record that user overcame an urge
  Future<void> recordBattleWon() async {
    final updatedData = state.copyWith(battlesWon: state.battlesWon + 1);
    state = updatedData;
    await InnerJourneyStorage.saveData(updatedData);
  }

  /// Record a slip/relapse
  Future<void> recordSlip({String? trigger}) async {
    final slip = SlipRecord(
      date: DateTime.now(),
      trigger: trigger,
      streakBroken: state.calculatedStreak,
    );

    // Update trigger counts
    final newTriggerCounts = Map<String, int>.from(state.triggerCounts);
    if (trigger != null && trigger != 'other' && trigger != 'skip') {
      newTriggerCounts[trigger] = (newTriggerCounts[trigger] ?? 0) + 1;
    }

    final updatedData = state.copyWith(
      currentStreak: 0,
      currentStreakStart: DateTime.now(),
      slipHistory: [...state.slipHistory, slip],
      triggerCounts: newTriggerCounts,
    );
    state = updatedData;
    await InnerJourneyStorage.saveData(updatedData);
  }

  /// Disable journey but keep data
  Future<void> disableKeepData() async {
    final updatedData = state.copyWith(isEnabled: false);
    state = updatedData;
    await InnerJourneyStorage.saveData(updatedData);
  }

  /// Re-enable journey (continue from where left off but reset streak)
  Future<void> reEnable() async {
    final updatedData = state.copyWith(
      isEnabled: true,
      currentStreakStart: DateTime.now(),
      currentStreak: 0,
    );
    state = updatedData;
    await InnerJourneyStorage.saveData(updatedData);
  }

  /// Delete all journey data
  Future<void> deleteAllData() async {
    await InnerJourneyStorage.clearAllData();
    state = const InnerJourneyData();
  }

  /// Refresh data from storage
  Future<void> refresh() async {
    await _loadData();
  }
}

final innerJourneyProvider =
    StateNotifierProvider<InnerJourneyNotifier, InnerJourneyData>((ref) {
  return InnerJourneyNotifier();
});

/// Provider to check if journey is enabled
final isJourneyEnabledProvider = Provider<bool>((ref) {
  return ref.watch(innerJourneyProvider).isEnabled;
});

/// Provider for current streak
final journeyStreakProvider = Provider<int>((ref) {
  return ref.watch(innerJourneyProvider).calculatedStreak;
});

/// Provider for daily wisdom data
class DailyWisdomNotifier extends StateNotifier<List<JourneyWisdom>> {
  DailyWisdomNotifier() : super([]) {
    _loadData();
  }

  Map<String, dynamic>? _cachedData;

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('data/inner_journey_wisdom.json');
      _cachedData = jsonDecode(jsonString) as Map<String, dynamic>;
      final List<dynamic> wisdomList = _cachedData!['daily_wisdom'] ?? [];
      state = wisdomList
          .map((e) => JourneyWisdom.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading daily wisdom: $e');
    }
  }

  /// Get today's wisdom (based on day of year)
  JourneyWisdom? getTodaysWisdom() {
    if (state.isEmpty) return null;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return state[dayOfYear % state.length];
  }

  /// Get random wisdom
  JourneyWisdom? getRandomWisdom() {
    if (state.isEmpty) return null;
    final index = DateTime.now().millisecondsSinceEpoch % state.length;
    return state[index];
  }

  /// Get emergency dhikr
  EmergencyDhikr? getEmergencyDhikr() {
    if (_cachedData == null) return null;
    final data = _cachedData!['emergency_dhikr'];
    if (data == null) return null;
    return EmergencyDhikr.fromJson(data as Map<String, dynamic>);
  }

  /// Get tawbah dua
  TawbahDua? getTawbahDua() {
    if (_cachedData == null) return null;
    final data = _cachedData!['tawbah_dua'];
    if (data == null) return null;
    return TawbahDua.fromJson(data as Map<String, dynamic>);
  }

  /// Get physical reset tips
  List<String> getPhysicalResetTips(String lang) {
    if (_cachedData == null) return [];
    final tips = _cachedData!['physical_reset_tips'] as Map<String, dynamic>?;
    if (tips == null) return [];
    return List<String>.from(tips[lang] ?? tips['en'] ?? []);
  }

  /// Get tawbah conditions
  List<Map<String, dynamic>> getTawbahConditions(String lang) {
    if (_cachedData == null) return [];
    final conditions = _cachedData!['tawbah_conditions'] as Map<String, dynamic>?;
    if (conditions == null) return [];
    return List<Map<String, dynamic>>.from(conditions[lang] ?? conditions['en'] ?? []);
  }

  /// Get protection duas
  List<Map<String, dynamic>> getProtectionDuas() {
    if (_cachedData == null) return [];
    return List<Map<String, dynamic>>.from(_cachedData!['protection_duas'] ?? []);
  }
}

final dailyWisdomProvider =
    StateNotifierProvider<DailyWisdomNotifier, List<JourneyWisdom>>((ref) {
  return DailyWisdomNotifier();
});

/// Provider for today's wisdom
final todaysWisdomProvider = Provider<JourneyWisdom?>((ref) {
  final wisdomList = ref.watch(dailyWisdomProvider);
  if (wisdomList.isEmpty) return null;
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return wisdomList[dayOfYear % wisdomList.length];
});
