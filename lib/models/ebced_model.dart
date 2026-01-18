class EbcedResult {
  final String name;
  final int totalValue;
  final int digitSum;
  final List<LetterValue> letterBreakdown;
  final EsmaRecommendation? primaryEsma;
  final EsmaRecommendation? secondaryEsma;
  final String matchMethod;

  const EbcedResult({
    required this.name,
    required this.totalValue,
    required this.digitSum,
    required this.letterBreakdown,
    this.primaryEsma,
    this.secondaryEsma,
    this.matchMethod = 'range_match',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalValue': totalValue,
      'digitSum': digitSum,
      'letterBreakdown': letterBreakdown.map((e) => e.toJson()).toList(),
      'primaryEsma': primaryEsma?.toJson(),
      'secondaryEsma': secondaryEsma?.toJson(),
      'matchMethod': matchMethod,
    };
  }
}

class LetterValue {
  final String letter;
  final int value;

  const LetterValue({
    required this.letter,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'value': value,
    };
  }
}

class EsmaRecommendation {
  final String id;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final int abjadValue;
  final List<int> recommendedCounts;

  const EsmaRecommendation({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.abjadValue,
    this.recommendedCounts = const [],
  });

  String getMeaning(String languageCode) {
    return meaning[languageCode] ?? meaning['tr'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabic': arabic,
      'transliteration': transliteration,
      'meaning': meaning,
      'abjadValue': abjadValue,
      'recommendedCounts': recommendedCounts,
    };
  }

  factory EsmaRecommendation.fromJson(Map<String, dynamic> json) {
    return EsmaRecommendation(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: Map<String, String>.from(json['meaning'] as Map? ?? {}),
      abjadValue: json['abjadValue'] as int? ?? json['abjad_value'] as int? ?? 0,
      recommendedCounts: (json['recommendedCounts'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}

// Ebced letter mapping for Turkish
class EbcedMapping {
  static const Map<String, int> turkishValues = {
    'a': 1,
    'b': 2,
    'c': 3,
    'ç': 3,
    'd': 4,
    'e': 5,
    'f': 80,
    'g': 20,
    'ğ': 1000,
    'h': 8,
    'ı': 10,
    'i': 10,
    'j': 3,
    'k': 20,
    'l': 30,
    'm': 40,
    'n': 50,
    'o': 6,
    'ö': 6,
    'p': 2,
    'r': 200,
    's': 60,
    'ş': 300,
    't': 400,
    'u': 6,
    'ü': 6,
    'v': 6,
    'y': 10,
    'z': 7,
  };

  static const Map<String, int> englishValues = {
    'a': 1,
    'b': 2,
    'c': 3,
    'd': 4,
    'e': 5,
    'f': 80,
    'g': 20,
    'h': 8,
    'i': 10,
    'j': 3,
    'k': 20,
    'l': 30,
    'm': 40,
    'n': 50,
    'o': 6,
    'p': 2,
    'q': 100,
    'r': 200,
    's': 60,
    't': 400,
    'u': 6,
    'v': 6,
    'w': 6,
    'x': 60,
    'y': 10,
    'z': 7,
  };

  static int getValue(String letter, {bool useTurkish = true}) {
    final lowerLetter = letter.toLowerCase();
    if (useTurkish && turkishValues.containsKey(lowerLetter)) {
      return turkishValues[lowerLetter]!;
    }
    return englishValues[lowerLetter] ?? 0;
  }

  static int calculateDigitSum(int value) {
    int sum = value;
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }
}
