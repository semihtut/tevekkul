/// Model for mood-specific dhikr recommendations
class MoodDhikrModel {
  final String arabic;
  final String transliteration;
  final Map<String, String> meanings; // tr, en, fi
  final int recommendedCount;
  final String source;
  final Map<String, String> notes; // tr, en, fi

  const MoodDhikrModel({
    required this.arabic,
    required this.transliteration,
    required this.meanings,
    required this.recommendedCount,
    required this.source,
    this.notes = const {},
  });

  String getMeaning(String languageCode) {
    return meanings[languageCode] ?? meanings['tr'] ?? '';
  }

  String getNote(String languageCode) {
    return notes[languageCode] ?? notes['tr'] ?? '';
  }

  factory MoodDhikrModel.fromJson(Map<String, dynamic> json) {
    return MoodDhikrModel(
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meanings: _parseLocalizedMap(json['meanings']),
      recommendedCount: json['recommended_count'] as int,
      source: json['source'] as String? ?? '',
      notes: _parseLocalizedMap(json['notes'] ?? {}),
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
