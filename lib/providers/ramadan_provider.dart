import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ramadan_model.dart';
import '../models/prayer_times_model.dart';
import '../models/esma_model.dart';
import '../services/ramadan_service.dart';
import '../services/prayer_times_service.dart';
import '../services/storage_service.dart';
import '../services/data_loader_service.dart';

// ==================== RAMADAN STATE ====================

/// Provider for Ramadan mode enabled/disabled (manual toggle)
final ramadanEnabledProvider = StateProvider<bool>((ref) {
  // Load from storage
  final storage = StorageService();
  return storage.getRamadanEnabled();
});

/// Provider for checking if Ramadan is active (by date)
final isRamadanByDateProvider = Provider<bool>((ref) {
  return RamadanService().isRamadan();
});

/// Provider for checking if Ramadan mode should be shown
/// (either by date OR manual toggle)
final showRamadanModeProvider = Provider<bool>((ref) {
  final byDate = ref.watch(isRamadanByDateProvider);
  final manualEnabled = ref.watch(ramadanEnabledProvider);
  return byDate || manualEnabled;
});

/// Provider for current Ramadan day (1-30)
final ramadanDayProvider = Provider<int>((ref) {
  return RamadanService().getRamadanDay();
});

/// Provider for total Ramadan days
final ramadanTotalDaysProvider = Provider<int>((ref) {
  return RamadanService().totalDays;
});

/// Provider for days until Ramadan
final daysUntilRamadanProvider = Provider<int>((ref) {
  return RamadanService().getDaysUntilRamadan();
});

// ==================== RAMADAN CONTENT ====================

/// Provider for today's Ramadan content
final ramadanContentProvider = FutureProvider<RamadanDayContent?>((ref) async {
  final showRamadan = ref.watch(showRamadanModeProvider);
  if (!showRamadan) return null;

  // If manual mode is on but not actual Ramadan, show day 1 for demo
  final day = ref.watch(ramadanDayProvider);
  final actualDay = day > 0 ? day : 1;

  return RamadanService().getDayContent(actualDay);
});

/// Provider for specific day's Ramadan content
final ramadanDayContentProvider = FutureProvider.family<RamadanDayContent?, int>((ref, day) async {
  return RamadanService().getDayContent(day);
});

/// Provider for Esma of the day (from Ramadan content)
final ramadanEsmaProvider = FutureProvider<EsmaModel?>((ref) async {
  final content = await ref.watch(ramadanContentProvider.future);
  if (content == null) return null;

  final esmaList = await DataLoaderService().loadEsmaList();
  return esmaList.cast<EsmaModel?>().firstWhere(
    (e) => e?.id == content.esmaId,
    orElse: () => null,
  );
});

// ==================== PRAYER TIMES ====================

/// Provider for prayer times (fixed imsakiye for Helsinki/Espoo/Vantaa)
final prayerTimesProvider = Provider<PrayerTimes?>((ref) {
  final showRamadan = ref.watch(showRamadanModeProvider);
  if (!showRamadan) return null;

  return PrayerTimesService().getTodayTimes();
});

/// Provider for time until Iftar (updates every second)
final iftarCountdownProvider = StreamProvider<Duration>((ref) {
  final times = ref.watch(prayerTimesProvider);

  if (times == null) return Stream.value(Duration.zero);

  return Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    if (now.isAfter(times.maghrib)) {
      return Duration.zero;
    }
    return times.maghrib.difference(now);
  });
});

/// Provider for formatted iftar time
final formattedIftarTimeProvider = Provider<String>((ref) {
  final times = ref.watch(prayerTimesProvider);
  return times?.formattedMaghrib ?? '--:--';
});

/// Provider for formatted fajr/imsak time
final formattedImsakTimeProvider = Provider<String>((ref) {
  final times = ref.watch(prayerTimesProvider);
  return times?.formattedFajr ?? '--:--';
});

/// Provider for checking if currently fasting time
final isFastingTimeProvider = Provider<bool>((ref) {
  final times = ref.watch(prayerTimesProvider);
  return times?.isFastingTime ?? false;
});
