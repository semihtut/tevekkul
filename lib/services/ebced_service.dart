/// Ebced-i Kebir (Ottoman Abjad Numeral System) Calculator
///
/// This service calculates the numerical value of names/words
/// according to the Ebced system used in Islamic tradition.
class EbcedService {
  static final EbcedService _instance = EbcedService._internal();
  factory EbcedService() => _instance;
  EbcedService._internal();

  /// Ebced-i Kebir values for Arabic letters
  static const Map<String, int> _arabicEbced = {
    '\u0627': 1,    // Alif - ا
    '\u0628': 2,    // Ba - ب
    '\u062C': 3,    // Jim - ج
    '\u062F': 4,    // Dal - د
    '\u0647': 5,    // Ha - ه
    '\u0648': 6,    // Waw - و
    '\u0632': 7,    // Zayn - ز
    '\u062D': 8,    // Hha - ح
    '\u0637': 9,    // Tta - ط
    '\u064A': 10,   // Ya - ي
    '\u0643': 20,   // Kaf - ك
    '\u0644': 30,   // Lam - ل
    '\u0645': 40,   // Mim - م
    '\u0646': 50,   // Nun - ن
    '\u0633': 60,   // Sin - س
    '\u0639': 70,   // Ayn - ع
    '\u0641': 80,   // Fa - ف
    '\u0635': 90,   // Sad - ص
    '\u0642': 100,  // Qaf - ق
    '\u0631': 200,  // Ra - ر
    '\u0634': 300,  // Shin - ش
    '\u062A': 400,  // Ta - ت
    '\u062B': 500,  // Tha - ث
    '\u062E': 600,  // Kha - خ
    '\u0630': 700,  // Dhal - ذ
    '\u0636': 800,  // Dad - ض
    '\u0638': 900,  // Zha - ظ
    '\u063A': 1000, // Ghayn - غ
    // Additional forms
    '\u0623': 1,    // Alif with hamza above - أ
    '\u0625': 1,    // Alif with hamza below - إ
    '\u0622': 1,    // Alif with madda - آ
    '\u0649': 10,   // Alif maksura - ى
    '\u0629': 5,    // Ta marbuta - ة
    '\u0624': 6,    // Waw with hamza - ؤ
    '\u0626': 10,   // Ya with hamza - ئ
  };

  /// Turkish/Latin letter mappings to Arabic equivalents
  static const Map<String, String> _turkishToArabic = {
    'a': '\u0627', 'A': '\u0627',
    'b': '\u0628', 'B': '\u0628',
    'c': '\u062C', 'C': '\u062C',
    'd': '\u062F', 'D': '\u062F',
    'e': '\u0647', 'E': '\u0647',
    'f': '\u0641', 'F': '\u0641',
    'g': '\u063A', 'G': '\u063A',
    'h': '\u062D', 'H': '\u062D',
    'i': '\u064A', 'I': '\u064A',
    'j': '\u062C', 'J': '\u062C',
    'k': '\u0643', 'K': '\u0643',
    'l': '\u0644', 'L': '\u0644',
    'm': '\u0645', 'M': '\u0645',
    'n': '\u0646', 'N': '\u0646',
    'o': '\u0648', 'O': '\u0648',
    'p': '\u0628', 'P': '\u0628', // P maps to Ba
    'q': '\u0642', 'Q': '\u0642',
    'r': '\u0631', 'R': '\u0631',
    's': '\u0633', 'S': '\u0633',
    't': '\u062A', 'T': '\u062A',
    'u': '\u0648', 'U': '\u0648',
    'v': '\u0648', 'V': '\u0648', // V maps to Waw
    'w': '\u0648', 'W': '\u0648',
    'x': '\u0633', 'X': '\u0633', // X maps to Sin
    'y': '\u064A', 'Y': '\u064A',
    'z': '\u0632', 'Z': '\u0632',
    // Turkish special characters
    '\u00E7': '\u062C', '\u00C7': '\u062C', // c cedilla
    '\u011F': '\u063A', '\u011E': '\u063A', // g breve
    '\u0131': '\u064A', '\u0130': '\u064A', // dotless i / I with dot
    '\u00F6': '\u0648', '\u00D6': '\u0648', // o umlaut
    '\u015F': '\u0634', '\u015E': '\u0634', // s cedilla -> Shin
    '\u00FC': '\u0648', '\u00DC': '\u0648', // u umlaut
  };

  /// Calculate the Ebced value of a text
  int calculate(String text) {
    int total = 0;
    final normalizedText = _normalizeText(text);

    for (int i = 0; i < normalizedText.length; i++) {
      final char = normalizedText[i];

      // Check if it's an Arabic letter
      if (_arabicEbced.containsKey(char)) {
        total += _arabicEbced[char]!;
      }
      // Check if it's a Turkish/Latin letter
      else if (_turkishToArabic.containsKey(char)) {
        final arabicChar = _turkishToArabic[char]!;
        total += _arabicEbced[arabicChar] ?? 0;
      }
    }

    return total;
  }

  /// Calculate and return detailed breakdown
  Map<String, dynamic> calculateDetailed(String text) {
    final List<Map<String, dynamic>> breakdown = [];
    int total = 0;
    final normalizedText = _normalizeText(text);

    for (int i = 0; i < normalizedText.length; i++) {
      final char = normalizedText[i];
      int value = 0;
      String? arabicChar;

      if (_arabicEbced.containsKey(char)) {
        value = _arabicEbced[char]!;
        arabicChar = char;
      } else if (_turkishToArabic.containsKey(char)) {
        arabicChar = _turkishToArabic[char]!;
        value = _arabicEbced[arabicChar] ?? 0;
      }

      if (value > 0) {
        breakdown.add({
          'original': char,
          'arabic': arabicChar,
          'value': value,
        });
        total += value;
      }
    }

    return {
      'text': text,
      'total': total,
      'breakdown': breakdown,
    };
  }

  /// Normalize text for calculation
  String _normalizeText(String text) {
    // Remove spaces, numbers, and punctuation
    return text.replaceAll(RegExp(r'[\s\d\p{P}]', unicode: true), '');
  }

  /// Get the digital root (reduce to single digit by summing)
  int getDigitalRoot(int number) {
    while (number > 9) {
      int sum = 0;
      while (number > 0) {
        sum += number % 10;
        number ~/= 10;
      }
      number = sum;
    }
    return number;
  }

  /// Get recommended Esma indices based on Ebced value
  List<int> getRecommendedEsmaIndices(int ebcedValue) {
    // Various methods to find related Esma
    final indices = <int>[];

    // Direct match (modulo 99 for 99 names)
    indices.add((ebcedValue % 99));

    // Digital root
    final root = getDigitalRoot(ebcedValue);
    indices.add(root);

    // Sum of digits
    int sum = 0;
    int temp = ebcedValue;
    while (temp > 0) {
      sum += temp % 10;
      temp ~/= 10;
    }
    if (sum <= 99 && !indices.contains(sum)) {
      indices.add(sum);
    }

    return indices.where((i) => i > 0 && i <= 99).toList();
  }

  /// Check if a value matches an Esma's Abjad value
  bool matchesEsmaValue(int ebcedValue, int esmaAbjadValue) {
    // Direct match
    if (ebcedValue == esmaAbjadValue) return true;

    // Modulo match
    if (ebcedValue % esmaAbjadValue == 0) return true;
    if (esmaAbjadValue % ebcedValue == 0) return true;

    // Digital root match
    if (getDigitalRoot(ebcedValue) == getDigitalRoot(esmaAbjadValue)) {
      return true;
    }

    return false;
  }
}
