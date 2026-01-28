/// Daily wisdom content for Inner Journey
class JourneyWisdom {
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;  // tr, en, fi
  final String source;
  final String type;  // 'ayah', 'hadith', 'dua'
  final Map<String, String> practicalTip;  // tr, en, fi
  final String dhikr;
  final int dhikrCount;

  const JourneyWisdom({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
    required this.type,
    required this.practicalTip,
    required this.dhikr,
    required this.dhikrCount,
  });

  String getMeaning(String lang) => meaning[lang] ?? meaning['en'] ?? '';
  String getTip(String lang) => practicalTip[lang] ?? practicalTip['en'] ?? '';

  factory JourneyWisdom.fromJson(Map<String, dynamic> json) => JourneyWisdom(
    arabic: json['arabic'] as String,
    transliteration: json['transliteration'] as String,
    meaning: Map<String, String>.from(json['meaning'] as Map),
    source: json['source'] as String,
    type: json['type'] as String,
    practicalTip: Map<String, String>.from(json['practicalTip'] as Map),
    dhikr: json['dhikr'] as String,
    dhikrCount: json['dhikrCount'] as int,
  );

  Map<String, dynamic> toJson() => {
    'arabic': arabic,
    'transliteration': transliteration,
    'meaning': meaning,
    'source': source,
    'type': type,
    'practicalTip': practicalTip,
    'dhikr': dhikr,
    'dhikrCount': dhikrCount,
  };
}

/// Emergency dhikr for struggling moments
class EmergencyDhikr {
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final int count;
  final String source;

  const EmergencyDhikr({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.count,
    required this.source,
  });

  String getMeaning(String lang) => meaning[lang] ?? meaning['en'] ?? '';

  factory EmergencyDhikr.fromJson(Map<String, dynamic> json) => EmergencyDhikr(
    arabic: json['arabic'] as String,
    transliteration: json['transliteration'] as String,
    meaning: Map<String, String>.from(json['meaning'] as Map),
    count: json['count'] as int,
    source: json['source'] as String,
  );
}

/// Tawbah dua for slip flow
class TawbahDua {
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final String source;

  const TawbahDua({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
  });

  String getMeaning(String lang) => meaning[lang] ?? meaning['en'] ?? '';

  factory TawbahDua.fromJson(Map<String, dynamic> json) => TawbahDua(
    arabic: json['arabic'] as String,
    transliteration: json['transliteration'] as String,
    meaning: Map<String, String>.from(json['meaning'] as Map),
    source: json['source'] as String,
  );
}
