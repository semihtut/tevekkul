class EsmaModel {
  final String id;
  final int order;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning; // tr, en, fi
  final int abjadValue;
  final bool needsVerification;
  final double confidence;
  final List<String> themes;
  final List<int> suggestedCounts;
  final Map<String, String> reflectionPrompts; // tr, en, fi

  const EsmaModel({
    required this.id,
    required this.order,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.abjadValue,
    this.needsVerification = true,
    this.confidence = 0.9,
    this.themes = const [],
    this.suggestedCounts = const [99, 100],
    this.reflectionPrompts = const {},
  });

  String getMeaning(String languageCode) {
    return meaning[languageCode] ?? meaning['tr'] ?? '';
  }

  String getReflectionPrompt(String languageCode) {
    return reflectionPrompts[languageCode] ?? reflectionPrompts['tr'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'arabic': arabic,
      'transliteration': transliteration,
      'meaning': meaning,
      'abjad_value': abjadValue,
      'needs_verification': needsVerification,
      'confidence': confidence,
      'themes': themes,
      'suggested_counts': suggestedCounts,
      'reflection_prompts': reflectionPrompts,
    };
  }

  factory EsmaModel.fromJson(Map<String, dynamic> json) {
    return EsmaModel(
      id: json['id'] as String,
      order: json['order'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: _parseLocalizedMap(json['meanings'] ?? json['meaning']),
      abjadValue: json['abjad_value'] as int,
      needsVerification: json['needs_verification'] as bool? ?? true,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.9,
      themes: (json['themes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      suggestedCounts: (json['suggested_counts'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [99, 100],
      reflectionPrompts:
          _parseLocalizedMap(json['reflection_prompts'] ?? {}),
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
