class WirdItem {
  final String id;
  final String dhikrId; // İlişkili dhikr veya esma ID'si
  final String type; // 'dhikr' veya 'esma'
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final int targetCount; // Hedef sayı
  final int currentCount; // Mevcut ilerleme
  final DateTime addedAt; // Virde eklenme tarihi
  final DateTime? lastUpdated; // Son güncelleme

  const WirdItem({
    required this.id,
    required this.dhikrId,
    required this.type,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.targetCount,
    this.currentCount = 0,
    required this.addedAt,
    this.lastUpdated,
  });

  String getMeaning(String languageCode) {
    return meaning[languageCode] ?? meaning['tr'] ?? '';
  }

  bool get isCompleted => currentCount >= targetCount;

  double get progress => targetCount > 0 ? currentCount / targetCount : 0;

  int get remaining => targetCount - currentCount;

  WirdItem copyWith({
    String? id,
    String? dhikrId,
    String? type,
    String? arabic,
    String? transliteration,
    Map<String, String>? meaning,
    int? targetCount,
    int? currentCount,
    DateTime? addedAt,
    DateTime? lastUpdated,
  }) {
    return WirdItem(
      id: id ?? this.id,
      dhikrId: dhikrId ?? this.dhikrId,
      type: type ?? this.type,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      addedAt: addedAt ?? this.addedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dhikrId': dhikrId,
      'type': type,
      'arabic': arabic,
      'transliteration': transliteration,
      'meaning': meaning,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'addedAt': addedAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory WirdItem.fromJson(Map<String, dynamic> json) {
    return WirdItem(
      id: json['id'] as String,
      dhikrId: json['dhikrId'] as String,
      type: json['type'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: Map<String, String>.from(json['meaning'] as Map),
      targetCount: json['targetCount'] as int,
      currentCount: json['currentCount'] as int? ?? 0,
      addedAt: DateTime.parse(json['addedAt'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }
}

/// Günlük Vird özet bilgisi
class DailyWirdSummary {
  final int totalItems;
  final int completedItems;
  final int totalTarget;
  final int totalProgress;

  const DailyWirdSummary({
    required this.totalItems,
    required this.completedItems,
    required this.totalTarget,
    required this.totalProgress,
  });

  double get overallProgress => totalTarget > 0 ? totalProgress / totalTarget : 0;

  bool get isAllCompleted => completedItems == totalItems && totalItems > 0;
}
