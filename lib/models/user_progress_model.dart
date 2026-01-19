class UserProgressModel {
  final int currentStreak;
  final int longestStreak;
  final int totalDhikrCount;
  final int todayDhikrCount;
  final DateTime? lastActiveDate;
  final List<DailyProgress> weeklyProgress;
  final List<DailyProgress> monthlyProgress; // Last 30 days
  final List<Badge> earnedBadges;
  final int currentLevel;
  final int currentXp;
  final int xpForNextLevel;

  const UserProgressModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalDhikrCount = 0,
    this.todayDhikrCount = 0,
    this.lastActiveDate,
    this.weeklyProgress = const [],
    this.monthlyProgress = const [],
    this.earnedBadges = const [],
    this.currentLevel = 1,
    this.currentXp = 0,
    this.xpForNextLevel = 100,
  });

  // Get this week's total
  int get weeklyTotal {
    return weeklyProgress.fold(0, (sum, p) => sum + p.count);
  }

  // Get this month's total
  int get monthlyTotal {
    return monthlyProgress.fold(0, (sum, p) => sum + p.count);
  }

  // Get average dhikr per day this week
  double get weeklyAverage {
    if (weeklyProgress.isEmpty) return 0;
    return weeklyTotal / weeklyProgress.length;
  }

  // Get average dhikr per day this month
  double get monthlyAverage {
    if (monthlyProgress.isEmpty) return 0;
    return monthlyTotal / monthlyProgress.length;
  }

  // Get max dhikr in a single day
  int get maxDailyDhikr {
    if (monthlyProgress.isEmpty) return 0;
    return monthlyProgress.map((p) => p.count).reduce((a, b) => a > b ? a : b);
  }

  // Get active days this month
  int get activeDaysThisMonth {
    return monthlyProgress.where((p) => p.count > 0).length;
  }

  double get todayProgressPercent {
    const dailyGoal = 100; // Default daily goal
    return (todayDhikrCount / dailyGoal).clamp(0.0, 1.0);
  }

  double get levelProgressPercent {
    if (xpForNextLevel == 0) return 1.0;
    return (currentXp / xpForNextLevel).clamp(0.0, 1.0);
  }

  UserProgressModel copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalDhikrCount,
    int? todayDhikrCount,
    DateTime? lastActiveDate,
    List<DailyProgress>? weeklyProgress,
    List<DailyProgress>? monthlyProgress,
    List<Badge>? earnedBadges,
    int? currentLevel,
    int? currentXp,
    int? xpForNextLevel,
  }) {
    return UserProgressModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDhikrCount: totalDhikrCount ?? this.totalDhikrCount,
      todayDhikrCount: todayDhikrCount ?? this.todayDhikrCount,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      currentLevel: currentLevel ?? this.currentLevel,
      currentXp: currentXp ?? this.currentXp,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalDhikrCount': totalDhikrCount,
      'todayDhikrCount': todayDhikrCount,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'weeklyProgress': weeklyProgress.map((e) => e.toJson()).toList(),
      'monthlyProgress': monthlyProgress.map((e) => e.toJson()).toList(),
      'earnedBadges': earnedBadges.map((e) => e.toJson()).toList(),
      'currentLevel': currentLevel,
      'currentXp': currentXp,
      'xpForNextLevel': xpForNextLevel,
    };
  }

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalDhikrCount: json['totalDhikrCount'] as int? ?? 0,
      todayDhikrCount: json['todayDhikrCount'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>?)
              ?.map((e) => DailyProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyProgress: (json['monthlyProgress'] as List<dynamic>?)
              ?.map((e) => DailyProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      earnedBadges: (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentLevel: json['currentLevel'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpForNextLevel: json['xpForNextLevel'] as int? ?? 100,
    );
  }
}

class DailyProgress {
  final DateTime date;
  final int count;
  final bool isActive;

  const DailyProgress({
    required this.date,
    required this.count,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
      'isActive': isActive,
    };
  }

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class Badge {
  final String id;
  final Map<String, String> name; // tr, en, fi
  final Map<String, String> description; // tr, en, fi
  final String icon;
  final DateTime? earnedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.earnedAt,
  });

  String getName(String languageCode) {
    return name[languageCode] ?? name['tr'] ?? '';
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['tr'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: Map<String, String>.from(json['name'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      icon: json['icon'] as String,
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'] as String)
          : null,
    );
  }
}
