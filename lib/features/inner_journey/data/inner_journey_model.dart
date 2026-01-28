/// Enum for struggle type selection
enum StruggleType {
  habit,    // A habit (smoking, etc.)
  sin,      // A sin (haram actions)
  thought,  // A thought pattern
  unspecified,
}

/// Record of a slip/relapse event
class SlipRecord {
  final DateTime date;
  final String? trigger;
  final int streakBroken;

  const SlipRecord({
    required this.date,
    this.trigger,
    required this.streakBroken,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'trigger': trigger,
    'streakBroken': streakBroken,
  };

  factory SlipRecord.fromJson(Map<String, dynamic> json) => SlipRecord(
    date: DateTime.parse(json['date'] as String),
    trigger: json['trigger'] as String?,
    streakBroken: json['streakBroken'] as int,
  );
}

/// Main data model for Inner Journey feature
class InnerJourneyData {
  final bool isEnabled;
  final DateTime? journeyStartDate;
  final DateTime? currentStreakStart;
  final int currentStreak;
  final int bestStreak;
  final int totalCleanDays;
  final int battlesWon;  // "I Overcame It" count
  final StruggleType struggleType;
  final List<SlipRecord> slipHistory;
  final Map<String, int> triggerCounts;  // trigger -> count

  const InnerJourneyData({
    this.isEnabled = false,
    this.journeyStartDate,
    this.currentStreakStart,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCleanDays = 0,
    this.battlesWon = 0,
    this.struggleType = StruggleType.unspecified,
    this.slipHistory = const [],
    this.triggerCounts = const {},
  });

  /// Calculate current streak based on streak start date
  int get calculatedStreak {
    if (currentStreakStart == null) return 0;
    final now = DateTime.now();
    final start = DateTime(
      currentStreakStart!.year,
      currentStreakStart!.month,
      currentStreakStart!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(start).inDays;
  }

  /// Get message based on current streak
  String getStreakMessage(String lang) {
    final streak = calculatedStreak;

    if (streak == 0) {
      return lang == 'tr'
          ? 'Yolculuğun başlıyor. Adım adım.'
          : lang == 'fi'
              ? 'Matkasi alkaa. Askel kerrallaan.'
              : 'Your journey begins. One day at a time.';
    } else if (streak <= 7) {
      return lang == 'tr'
          ? 'Yolculuğun başlıyor. Adım adım.'
          : lang == 'fi'
              ? 'Matkasi alkaa. Askel kerrallaan.'
              : 'Your journey begins. One day at a time.';
    } else if (streak <= 30) {
      return lang == 'tr'
          ? 'Güçlü kal. Yeni alışkanlıklar oluşturuyorsun.'
          : lang == 'fi'
              ? 'Pysy vahvana. Rakennat uusia tapoja.'
              : 'Stay strong. You\'re building new habits.';
    } else if (streak <= 90) {
      return lang == 'tr'
          ? 'MaşaAllah! Sabrın ilham verici.'
          : lang == 'fi'
              ? 'MashaAllah! Kärsivällisyytesi on inspiroivaa.'
              : 'MashaAllah! Your patience is inspiring.';
    } else {
      return lang == 'tr'
          ? 'SubhanAllah! Dönüşümü başardın.'
          : lang == 'fi'
              ? 'SubhanAllah! Olet muuttunut.'
              : 'SubhanAllah! You\'ve transformed.';
    }
  }

  /// Get message after a slip
  String getSlipMessage(String lang) {
    return lang == 'tr'
        ? 'Her evliyanın bir geçmişi var. Tekrar kalk.'
        : lang == 'fi'
            ? 'Jokaisella pyhimyksellä on menneisyys. Nouse uudelleen.'
            : 'Every saint has a past. Rise again.';
  }

  /// Get top triggers sorted by frequency
  List<MapEntry<String, int>> get topTriggers {
    final entries = triggerCounts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(3).toList();
  }

  /// Calculate trigger percentages
  Map<String, double> get triggerPercentages {
    final total = triggerCounts.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return {};
    return triggerCounts.map((key, value) => MapEntry(key, (value / total) * 100));
  }

  InnerJourneyData copyWith({
    bool? isEnabled,
    DateTime? journeyStartDate,
    DateTime? currentStreakStart,
    int? currentStreak,
    int? bestStreak,
    int? totalCleanDays,
    int? battlesWon,
    StruggleType? struggleType,
    List<SlipRecord>? slipHistory,
    Map<String, int>? triggerCounts,
  }) {
    return InnerJourneyData(
      isEnabled: isEnabled ?? this.isEnabled,
      journeyStartDate: journeyStartDate ?? this.journeyStartDate,
      currentStreakStart: currentStreakStart ?? this.currentStreakStart,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCleanDays: totalCleanDays ?? this.totalCleanDays,
      battlesWon: battlesWon ?? this.battlesWon,
      struggleType: struggleType ?? this.struggleType,
      slipHistory: slipHistory ?? this.slipHistory,
      triggerCounts: triggerCounts ?? this.triggerCounts,
    );
  }

  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
    'journeyStartDate': journeyStartDate?.toIso8601String(),
    'currentStreakStart': currentStreakStart?.toIso8601String(),
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'totalCleanDays': totalCleanDays,
    'battlesWon': battlesWon,
    'struggleType': struggleType.index,
    'slipHistory': slipHistory.map((e) => e.toJson()).toList(),
    'triggerCounts': triggerCounts,
  };

  factory InnerJourneyData.fromJson(Map<String, dynamic> json) {
    return InnerJourneyData(
      isEnabled: json['isEnabled'] as bool? ?? false,
      journeyStartDate: json['journeyStartDate'] != null
          ? DateTime.parse(json['journeyStartDate'] as String)
          : null,
      currentStreakStart: json['currentStreakStart'] != null
          ? DateTime.parse(json['currentStreakStart'] as String)
          : null,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalCleanDays: json['totalCleanDays'] as int? ?? 0,
      battlesWon: json['battlesWon'] as int? ?? 0,
      struggleType: StruggleType.values[json['struggleType'] as int? ?? 3],
      slipHistory: (json['slipHistory'] as List<dynamic>?)
          ?.map((e) => SlipRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      triggerCounts: (json['triggerCounts'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
    );
  }

  /// Create initial data when journey starts
  factory InnerJourneyData.initial({
    required StruggleType struggleType,
  }) {
    final now = DateTime.now();
    return InnerJourneyData(
      isEnabled: true,
      journeyStartDate: now,
      currentStreakStart: now,
      currentStreak: 0,
      bestStreak: 0,
      totalCleanDays: 0,
      battlesWon: 0,
      struggleType: struggleType,
      slipHistory: [],
      triggerCounts: {},
    );
  }
}

/// Milestone definitions
class JourneyMilestone {
  final int day;
  final String titleKey;
  final String iconEmoji;

  const JourneyMilestone({
    required this.day,
    required this.titleKey,
    required this.iconEmoji,
  });

  bool isAchieved(int currentStreak) => currentStreak >= day;
}

/// Predefined milestones
const journeyMilestones = [
  JourneyMilestone(day: 1, titleKey: 'milestone_day_1', iconEmoji: '🌱'),
  JourneyMilestone(day: 7, titleKey: 'milestone_day_7', iconEmoji: '🌿'),
  JourneyMilestone(day: 21, titleKey: 'milestone_day_21', iconEmoji: '🌳'),
  JourneyMilestone(day: 40, titleKey: 'milestone_day_40', iconEmoji: '💪'),
  JourneyMilestone(day: 90, titleKey: 'milestone_day_90', iconEmoji: '🏆'),
];

/// Trigger options for slip recording
const triggerOptions = [
  'late_night',
  'stress',
  'loneliness',
  'boredom',
  'anxiety',
  'other',
];
