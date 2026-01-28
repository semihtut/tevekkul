import 'package:adhan/adhan.dart' as adhan;
import '../models/city_model.dart';
import '../models/prayer_times_model.dart';

/// Service for prayer times - uses adhan package for calculations
/// Ramadan 2026: 17 February - 18 March
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  // Ramadan 2026 dates
  static final DateTime ramadanStart = DateTime(2026, 2, 17);
  static final DateTime ramadanEnd = DateTime(2026, 3, 18);

  /// Get Ramadan day number (1-30) for given date
  /// Returns 0 if not during Ramadan
  int getRamadanDay([DateTime? date]) {
    final checkDate = date ?? DateTime.now();
    final today = DateTime(checkDate.year, checkDate.month, checkDate.day);
    final start = DateTime(ramadanStart.year, ramadanStart.month, ramadanStart.day);
    final end = DateTime(ramadanEnd.year, ramadanEnd.month, ramadanEnd.day);

    if (today.isBefore(start) || today.isAfter(end)) {
      return 0;
    }

    return today.difference(start).inDays + 1;
  }

  /// Check if given date is during Ramadan
  bool isRamadan([DateTime? date]) {
    return getRamadanDay(date) > 0;
  }

  /// Calculate prayer times for a specific city and date using adhan package
  PrayerTimes calculateTimes(PrayerCity city, [DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateComponents = adhan.DateComponents(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final params = city.calculationParameters;

    // Adjust for high latitudes (important for Finland, Latvia)
    if (city.latitude > 55) {
      params.highLatitudeRule = adhan.HighLatitudeRule.twilight_angle;
    }

    final prayerTimes = adhan.PrayerTimes(
      city.coordinates,
      dateComponents,
      params,
    );

    return PrayerTimes(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      date: DateTime(targetDate.year, targetDate.month, targetDate.day),
    );
  }

  /// Get prayer times for a specific Ramadan day (1-30) for a city
  PrayerTimes getTimesForDay(int day, PrayerCity city) {
    // Clamp day to valid range
    final clampedDay = day.clamp(1, 30);
    final dayIndex = clampedDay - 1; // 0-29

    // Calculate the actual date for this day
    final date = ramadanStart.add(Duration(days: dayIndex));

    return calculateTimes(city, date);
  }

  /// Get today's prayer times for a city
  /// Returns times for day 1 if not during Ramadan (demo mode)
  PrayerTimes getTodayTimes(PrayerCity city) {
    final day = getRamadanDay();
    if (day == 0) {
      // Demo mode - calculate for today's date
      return calculateTimes(city);
    }
    return getTimesForDay(day, city);
  }

  /// Format duration as "Xs Ydk" (hours and minutes)
  static String formatDuration(Duration duration, String lang) {
    if (duration.isNegative || duration == Duration.zero) {
      return lang == 'en' ? 'Now' : (lang == 'fi' ? 'Nyt' : 'Şimdi');
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      final hourUnit = lang == 'en' ? 'h' : (lang == 'fi' ? 't' : 's');
      final minUnit = lang == 'en' ? 'm' : (lang == 'fi' ? 'min' : 'dk');
      return '$hours$hourUnit $minutes$minUnit';
    } else {
      final minUnit = lang == 'en' ? 'min' : (lang == 'fi' ? 'min' : 'dk');
      return '$minutes $minUnit';
    }
  }
}
