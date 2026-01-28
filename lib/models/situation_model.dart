// Model classes for situation-based prayers (Duruma Özel Dualar)

class SituationCategory {
  final String id;
  final String emoji;
  final Map<String, String> label;
  final List<Situation> situations;

  const SituationCategory({
    required this.id,
    required this.emoji,
    required this.label,
    required this.situations,
  });

  String getLabel(String languageCode) {
    return label[languageCode] ?? label['tr'] ?? '';
  }

  factory SituationCategory.fromJson(Map<String, dynamic> json) {
    return SituationCategory(
      id: json['id'] as String,
      emoji: json['emoji'] as String? ?? '📿',
      label: _parseLocalizedMap(json['label']),
      situations: (json['situations'] as List<dynamic>?)
              ?.map((e) => Situation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static Map<String, String> _parseLocalizedMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}

class Situation {
  final String id;
  final String emoji;
  final Map<String, String> label;
  final Map<String, String> description;
  final List<SituationDua> dualar;

  const Situation({
    required this.id,
    required this.emoji,
    required this.label,
    this.description = const {},
    required this.dualar,
  });

  String getLabel(String languageCode) {
    return label[languageCode] ?? label['tr'] ?? '';
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['tr'] ?? '';
  }

  factory Situation.fromJson(Map<String, dynamic> json) {
    return Situation(
      id: json['id'] as String,
      emoji: json['emoji'] as String? ?? '🤲',
      label: _parseLocalizedMap(json['label']),
      description: _parseLocalizedMap(json['description']),
      dualar: (json['dualar'] as List<dynamic>?)
              ?.map((e) => SituationDua.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static Map<String, String> _parseLocalizedMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}

class SituationDua {
  final String id;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final String source;
  final String sourceType; // 'hadith' | 'quran'
  final int? recommendedCount;
  final Map<String, String> note;

  const SituationDua({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
    this.sourceType = 'hadith',
    this.recommendedCount,
    this.note = const {},
  });

  String getMeaning(String languageCode) {
    return meaning[languageCode] ?? meaning['tr'] ?? '';
  }

  String getNote(String languageCode) {
    return note[languageCode] ?? note['tr'] ?? '';
  }

  bool get hasNote => note.isNotEmpty;

  factory SituationDua.fromJson(Map<String, dynamic> json) {
    return SituationDua(
      id: json['id'] as String,
      arabic: json['arabic'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaning: _parseLocalizedMap(json['meaning']),
      source: json['source'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? 'hadith',
      recommendedCount: json['recommended_count'] as int?,
      note: _parseLocalizedMap(json['note']),
    );
  }

  static Map<String, String> _parseLocalizedMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}
