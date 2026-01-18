class MoodModel {
  final String id;
  final String emoji;
  final Map<String, String> label; // tr, en, fi
  final Map<String, String> description; // tr, en, fi
  final List<String> suggestedDhikrIds;
  final List<String> suggestedEsmaIds;
  final List<AyahReference> ayahReferences;
  final Map<String, String> reflectionPrompts; // tr, en, fi

  const MoodModel({
    required this.id,
    required this.emoji,
    required this.label,
    this.description = const {},
    this.suggestedDhikrIds = const [],
    this.suggestedEsmaIds = const [],
    this.ayahReferences = const [],
    this.reflectionPrompts = const {},
  });

  String getLabel(String languageCode) {
    return label[languageCode] ?? label['tr'] ?? '';
  }

  String getDescription(String languageCode) {
    return description[languageCode] ?? description['tr'] ?? '';
  }

  String getReflectionPrompt(String languageCode) {
    return reflectionPrompts[languageCode] ?? reflectionPrompts['tr'] ?? '';
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    // Get emoji from icon field or use default
    String emoji = '😊';
    if (json['emoji'] != null) {
      emoji = json['emoji'] as String;
    } else if (json['icon'] != null) {
      // Map icon names to emojis
      const iconMap = {
        'cloud-rain': '😰',
        'heart-crack': '😢',
        'hands-praying': '🤲',
        'sun': '😊',
        'sparkles': '✨',
        'heart': '❤️',
        'fire': '🔥',
        'leaf': '🌿',
        'star': '⭐',
        'moon': '🌙',
        'cloud': '☁️',
        'bolt': '⚡',
        'peace': '☮️',
        'smile': '😊',
        'frown': '😔',
        'meh': '😐',
        'angry': '😠',
        'tired': '😴',
        'confused': '😕',
        'hopeful': '🙏',
      };
      emoji = iconMap[json['icon']] ?? '😊';
    }

    return MoodModel(
      id: json['id'] as String,
      emoji: emoji,
      label: _parseLocalizedMap(json['labels'] ?? json['label']),
      description: _parseLocalizedMap(json['descriptions'] ?? json['description'] ?? {}),
      suggestedDhikrIds: (json['recommended_dhikr_suggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['suggested_dhikr_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      suggestedEsmaIds: (json['suggested_esma_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ayahReferences: (json['ayah_references'] as List<dynamic>?)
              ?.map((e) => AyahReference.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reflectionPrompts: _parseLocalizedMap(json['reflection_prompts'] ?? {}),
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

class AyahReference {
  final String surah;
  final int ayahStart;
  final int? ayahEnd;
  final Map<String, String> themeNote; // tr, en, fi
  final bool needsTextVerification;

  const AyahReference({
    required this.surah,
    required this.ayahStart,
    this.ayahEnd,
    this.themeNote = const {},
    this.needsTextVerification = true,
  });

  String getThemeNote(String languageCode) {
    return themeNote[languageCode] ?? themeNote['tr'] ?? '';
  }

  String get reference {
    if (ayahEnd != null && ayahEnd != ayahStart) {
      return '$surah:$ayahStart-$ayahEnd';
    }
    return '$surah:$ayahStart';
  }

  factory AyahReference.fromJson(Map<String, dynamic> json) {
    // Handle surah as either String or int
    String surahStr;
    if (json['surah'] is int) {
      surahStr = json['surah_name'] as String? ?? 'Surah ${json['surah']}';
    } else {
      surahStr = json['surah'] as String? ?? '';
    }

    return AyahReference(
      surah: surahStr,
      ayahStart: json['ayah'] as int? ?? json['ayah_start'] as int,
      ayahEnd: json['ayah_end'] as int?,
      themeNote: _parseLocalizedMap(json['theme_notes'] ?? json['theme_note'] ?? {}),
      needsTextVerification: json['needs_text_verification'] as bool? ?? true,
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
