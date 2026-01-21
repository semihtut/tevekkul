import '../models/prayer_times_model.dart';

/// Service for prayer times - uses fixed imsakiye for Helsinki/Espoo/Vantaa
/// Ramadan 2026: 17 February - 18 March
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  // Ramadan 2026 dates for Helsinki/Espoo/Vantaa, Finland
  static final DateTime ramadanStart = DateTime(2026, 2, 17);
  static final DateTime ramadanEnd = DateTime(2026, 3, 18);

  // Day 1 times (17 Feb 2026)
  static const int _startImsakHour = 5;
  static const int _startImsakMinute = 16;
  static const int _startIftarHour = 17;
  static const int _startIftarMinute = 20;

  // Day 30 times (18 Mar 2026)
  static const int _endImsakHour = 3;
  static const int _endImsakMinute = 51;
  static const int _endIftarHour = 18;
  static const int _endIftarMinute = 33;

  // Total minutes change over 29 days
  // Imsak: 05:16 -> 03:51 = -85 minutes (decreasing)
  // Iftar: 17:20 -> 18:33 = +73 minutes (increasing)

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

  /// Get prayer times for a specific Ramadan day (1-30)
  PrayerTimes getTimesForDay(int day) {
    // Clamp day to valid range
    final clampedDay = day.clamp(1, 30);
    final dayIndex = clampedDay - 1; // 0-29

    // Calculate minutes from start
    const totalDays = 29; // 30 days = 29 intervals

    // Imsak calculation (decreasing from 05:16 to 03:51)
    const startImsakMinutes = _startImsakHour * 60 + _startImsakMinute; // 316
    const endImsakMinutes = _endImsakHour * 60 + _endImsakMinute; // 231
    const imsakChange = endImsakMinutes - startImsakMinutes; // -85
    final imsakMinutesToday = startImsakMinutes + (imsakChange * dayIndex / totalDays).round();
    final imsakHour = imsakMinutesToday ~/ 60;
    final imsakMinute = imsakMinutesToday % 60;

    // Iftar calculation (increasing from 17:20 to 18:33)
    const startIftarMinutes = _startIftarHour * 60 + _startIftarMinute; // 1040
    const endIftarMinutes = _endIftarHour * 60 + _endIftarMinute; // 1113
    const iftarChange = endIftarMinutes - startIftarMinutes; // 73
    final iftarMinutesToday = startIftarMinutes + (iftarChange * dayIndex / totalDays).round();
    final iftarHour = iftarMinutesToday ~/ 60;
    final iftarMinute = iftarMinutesToday % 60;

    // Calculate the actual date for this day
    final date = ramadanStart.add(Duration(days: dayIndex));

    return PrayerTimes(
      fajr: DateTime(date.year, date.month, date.day, imsakHour, imsakMinute),
      sunrise: DateTime(date.year, date.month, date.day, imsakHour + 1, 30), // Approximate
      dhuhr: DateTime(date.year, date.month, date.day, 12, 30), // Approximate
      asr: DateTime(date.year, date.month, date.day, 15, 0), // Approximate
      maghrib: DateTime(date.year, date.month, date.day, iftarHour, iftarMinute),
      isha: DateTime(date.year, date.month, date.day, iftarHour + 1, 30), // Approximate
      date: date,
    );
  }

  /// Get today's prayer times
  /// Returns times for day 1 if not during Ramadan (demo mode)
  PrayerTimes getTodayTimes() {
    final day = getRamadanDay();
    if (day == 0) {
      // Demo mode - return day 1 times but with today's date
      final today = DateTime.now();
      final times = getTimesForDay(1);
      return PrayerTimes(
        fajr: DateTime(today.year, today.month, today.day, times.fajr.hour, times.fajr.minute),
        sunrise: DateTime(today.year, today.month, today.day, times.sunrise.hour, times.sunrise.minute),
        dhuhr: DateTime(today.year, today.month, today.day, times.dhuhr.hour, times.dhuhr.minute),
        asr: DateTime(today.year, today.month, today.day, times.asr.hour, times.asr.minute),
        maghrib: DateTime(today.year, today.month, today.day, times.maghrib.hour, times.maghrib.minute),
        isha: DateTime(today.year, today.month, today.day, times.isha.hour, times.isha.minute),
        date: today,
      );
    }
    return getTimesForDay(day);
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
