/// Model for Ramadan daily content
class RamadanDayContent {
  final int day;
  final Map<String, String> theme;
  final RamadanAyah ayah;
  final String esmaId;

  const RamadanDayContent({
    required this.day,
    required this.theme,
    required this.ayah,
    required this.esmaId,
  });

  String getTheme(String languageCode) {
    return theme[languageCode] ?? theme['tr'] ?? '';
  }

  factory RamadanDayContent.fromJson(Map<String, dynamic> json) {
    return RamadanDayContent(
      day: json['day'] as int,
      theme: _parseLocalizedMap(json['theme']),
      ayah: RamadanAyah.fromJson(json['ayah'] as Map<String, dynamic>),
      esmaId: json['esma_id'] as String,
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

/// Model for Ramadan daily ayah
class RamadanAyah {
  final String reference;
  final String arabic;
  final Map<String, String> translation;

  const RamadanAyah({
    required this.reference,
    required this.arabic,
    required this.translation,
  });

  String getTranslation(String languageCode) {
    return translation[languageCode] ?? translation['tr'] ?? '';
  }

  factory RamadanAyah.fromJson(Map<String, dynamic> json) {
    return RamadanAyah(
      reference: json['reference'] as String,
      arabic: json['arabic'] as String,
      translation: _parseLocalizedMap(json['translation']),
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

/// Container for all Ramadan content
class RamadanContent {
  final List<RamadanDayContent> days;

  const RamadanContent({required this.days});

  factory RamadanContent.fromJson(Map<String, dynamic> json) {
    final content = json['ramadan_content'] as Map<String, dynamic>;
    final daysList = content['days'] as List<dynamic>;
    return RamadanContent(
      days: daysList
          .map((e) => RamadanDayContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  RamadanDayContent? getDay(int day) {
    if (day < 1 || day > days.length) return null;
    return days.firstWhere((d) => d.day == day, orElse: () => days[0]);
  }
}
