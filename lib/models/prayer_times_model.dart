/// Model for prayer times from Aladhan API
class PrayerTimes {
  final DateTime fajr;      // Imsak (start of fasting)
  final DateTime sunrise;   // Sunrise
  final DateTime dhuhr;     // Noon prayer
  final DateTime asr;       // Afternoon prayer
  final DateTime maghrib;   // Iftar (breaking fast)
  final DateTime isha;      // Night prayer
  final DateTime date;      // Date of these times

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  /// Parse time string "HH:mm" to DateTime for given date
  static DateTime _parseTime(String time, DateTime date) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// Parse date string "DD-MM-YYYY" to DateTime
  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[2]),  // year
      int.parse(parts[1]),  // month
      int.parse(parts[0]),  // day
    );
  }

  factory PrayerTimes.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final dateInfo = json['date'] as Map<String, dynamic>;
    final gregorian = dateInfo['gregorian'] as Map<String, dynamic>;
    final dateStr = gregorian['date'] as String;
    final date = _parseDate(dateStr);

    // Extract just the time part (HH:mm) - some responses include timezone info
    String extractTime(String timeStr) {
      // Handle formats like "05:42 (EET)" or just "05:42"
      return timeStr.split(' ').first.split('(').first.trim();
    }

    return PrayerTimes(
      fajr: _parseTime(extractTime(timings['Fajr'] as String), date),
      sunrise: _parseTime(extractTime(timings['Sunrise'] as String), date),
      dhuhr: _parseTime(extractTime(timings['Dhuhr'] as String), date),
      asr: _parseTime(extractTime(timings['Asr'] as String), date),
      maghrib: _parseTime(extractTime(timings['Maghrib'] as String), date),
      isha: _parseTime(extractTime(timings['Isha'] as String), date),
      date: date,
    );
  }

  /// Format time as "HH:mm"
  String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted Imsak time
  String get formattedFajr => formatTime(fajr);

  /// Get formatted Iftar time
  String get formattedMaghrib => formatTime(maghrib);

  /// Get duration until Iftar
  Duration get timeUntilIftar {
    final now = DateTime.now();
    if (now.isAfter(maghrib)) {
      return Duration.zero;
    }
    return maghrib.difference(now);
  }

  /// Check if it's currently fasting time (after Fajr, before Maghrib)
  bool get isFastingTime {
    final now = DateTime.now();
    return now.isAfter(fajr) && now.isBefore(maghrib);
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'date': date.toIso8601String(),
    };
  }

  /// Create from cached JSON
  factory PrayerTimes.fromCachedJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: DateTime.parse(json['fajr'] as String),
      sunrise: DateTime.parse(json['sunrise'] as String),
      dhuhr: DateTime.parse(json['dhuhr'] as String),
      asr: DateTime.parse(json['asr'] as String),
      maghrib: DateTime.parse(json['maghrib'] as String),
      isha: DateTime.parse(json['isha'] as String),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
