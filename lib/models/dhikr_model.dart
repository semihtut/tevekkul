class DhikrModel {
  final String id;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning; // tr, en, fi
  final int defaultTarget;
  final bool isFavorite;
  final int totalCount;
  final String? note;
  final DateTime? createdAt;
  final bool isCustom;

  const DhikrModel({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.defaultTarget = 33,
    this.isFavorite = false,
    this.totalCount = 0,
    this.note,
    this.createdAt,
    this.isCustom = false,
  });

  String getMeaning(String languageCode) {
    return meaning[languageCode] ?? meaning['tr'] ?? '';
  }

  DhikrModel copyWith({
    String? id,
    String? arabic,
    String? transliteration,
    Map<String, String>? meaning,
    int? defaultTarget,
    bool? isFavorite,
    int? totalCount,
    String? note,
    DateTime? createdAt,
    bool? isCustom,
  }) {
    return DhikrModel(
      id: id ?? this.id,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      isFavorite: isFavorite ?? this.isFavorite,
      totalCount: totalCount ?? this.totalCount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'transliteration': transliteration,
      'meaning': meaning,
      'defaultTarget': defaultTarget,
      'isFavorite': isFavorite,
      'totalCount': totalCount,
      'note': note,
      'createdAt': createdAt?.toIso8601String(),
      'isCustom': isCustom,
    };
  }

  factory DhikrModel.fromJson(Map<String, dynamic> json) {
    return DhikrModel(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: Map<String, String>.from(json['meaning'] as Map),
      defaultTarget: json['defaultTarget'] as int? ?? 33,
      isFavorite: json['isFavorite'] as bool? ?? false,
      totalCount: json['totalCount'] as int? ?? 0,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}
