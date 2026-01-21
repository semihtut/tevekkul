import 'package:flutter_test/flutter_test.dart';
import 'package:soulcount/models/dhikr_model.dart';

void main() {
  group('DhikrModel Tests', () {
    test('DhikrModel creates with required fields', () {
      final dhikr = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {
          'tr': 'Allah\'ı tüm eksikliklerden tenzih ederim',
          'en': 'Glory be to Allah',
          'fi': 'Ylistys Allahille'
        },
      );

      expect(dhikr.id, 'test_1');
      expect(dhikr.arabic, 'سبحان الله');
      expect(dhikr.transliteration, 'Subhanallah');
      expect(dhikr.meaning['tr'], 'Allah\'ı tüm eksikliklerden tenzih ederim');
      expect(dhikr.defaultTarget, 33); // Default value
      expect(dhikr.isFavorite, false); // Default value
      expect(dhikr.totalCount, 0); // Default value
      expect(dhikr.isCustom, false); // Default value
    });

    test('DhikrModel getMeaning returns correct translation', () {
      final dhikr = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {
          'tr': 'Türkçe anlamı',
          'en': 'English meaning',
          'fi': 'Suomalainen merkitys'
        },
      );

      expect(dhikr.getMeaning('tr'), 'Türkçe anlamı');
      expect(dhikr.getMeaning('en'), 'English meaning');
      expect(dhikr.getMeaning('fi'), 'Suomalainen merkitys');
    });

    test('DhikrModel getMeaning falls back to Turkish', () {
      final dhikr = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {
          'tr': 'Türkçe anlamı',
          'en': 'English meaning',
        },
      );

      // Request non-existent language, should fall back to Turkish
      expect(dhikr.getMeaning('de'), 'Türkçe anlamı');
    });

    test('DhikrModel getMeaning returns empty string if no translations', () {
      final dhikr = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {},
      );

      expect(dhikr.getMeaning('tr'), '');
    });

    test('DhikrModel copyWith creates new instance with updated fields', () {
      final original = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {'tr': 'Test'},
        defaultTarget: 33,
        isFavorite: false,
        totalCount: 0,
      );

      final updated = original.copyWith(
        isFavorite: true,
        totalCount: 100,
      );

      expect(updated.id, original.id);
      expect(updated.arabic, original.arabic);
      expect(updated.isFavorite, true);
      expect(updated.totalCount, 100);
      expect(original.isFavorite, false); // Original unchanged
      expect(original.totalCount, 0); // Original unchanged
    });

    test('DhikrModel toJson serializes correctly', () {
      final dhikr = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {'tr': 'Test'},
        defaultTarget: 33,
        isFavorite: true,
        totalCount: 100,
        note: 'Test note',
        createdAt: DateTime(2024, 1, 1),
        isCustom: false,
      );

      final json = dhikr.toJson();

      expect(json['id'], 'test_1');
      expect(json['arabic'], 'سبحان الله');
      expect(json['transliteration'], 'Subhanallah');
      expect(json['meaning'], {'tr': 'Test'});
      expect(json['defaultTarget'], 33);
      expect(json['isFavorite'], true);
      expect(json['totalCount'], 100);
      expect(json['note'], 'Test note');
      expect(json['createdAt'], isNotNull);
      expect(json['isCustom'], false);
    });

    test('DhikrModel fromJson deserializes correctly', () {
      final json = {
        'id': 'test_1',
        'arabic': 'سبحان الله',
        'transliteration': 'Subhanallah',
        'meaning': {'tr': 'Test'},
        'defaultTarget': 33,
        'isFavorite': true,
        'totalCount': 100,
        'note': 'Test note',
        'createdAt': '2024-01-01T00:00:00.000',
        'isCustom': false,
      };

      final dhikr = DhikrModel.fromJson(json);

      expect(dhikr.id, 'test_1');
      expect(dhikr.arabic, 'سبحان الله');
      expect(dhikr.transliteration, 'Subhanallah');
      expect(dhikr.meaning['tr'], 'Test');
      expect(dhikr.defaultTarget, 33);
      expect(dhikr.isFavorite, true);
      expect(dhikr.totalCount, 100);
      expect(dhikr.note, 'Test note');
      expect(dhikr.createdAt, isNotNull);
      expect(dhikr.isCustom, false);
    });

    test('DhikrModel fromJson handles missing optional fields', () {
      final json = {
        'id': 'test_1',
        'arabic': 'سبحان الله',
        'transliteration': 'Subhanallah',
        'meaning': {'tr': 'Test'},
      };

      final dhikr = DhikrModel.fromJson(json);

      expect(dhikr.id, 'test_1');
      expect(dhikr.defaultTarget, 33); // Default
      expect(dhikr.isFavorite, false); // Default
      expect(dhikr.totalCount, 0); // Default
      expect(dhikr.note, null);
      expect(dhikr.createdAt, null);
      expect(dhikr.isCustom, false); // Default
    });

    test('DhikrModel JSON serialization round-trip', () {
      final original = DhikrModel(
        id: 'test_1',
        arabic: 'سبحان الله',
        transliteration: 'Subhanallah',
        meaning: {'tr': 'Test', 'en': 'Test EN'},
        defaultTarget: 33,
        isFavorite: true,
        totalCount: 100,
        note: 'Test note',
        createdAt: DateTime(2024, 1, 1),
        isCustom: false,
      );

      final json = original.toJson();
      final restored = DhikrModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.arabic, original.arabic);
      expect(restored.transliteration, original.transliteration);
      expect(restored.meaning, original.meaning);
      expect(restored.defaultTarget, original.defaultTarget);
      expect(restored.isFavorite, original.isFavorite);
      expect(restored.totalCount, original.totalCount);
      expect(restored.note, original.note);
      expect(restored.isCustom, original.isCustom);
    });

    test('DhikrModel fromMoodDhikr factory creates correct dhikr', () {
      // Mock MoodDhikrModel structure
      final mockMoodDhikr = _MockMoodDhikr(
        arabic: 'لا حول ولا قوة إلا بالله',
        transliteration: 'La hawla wa la quwwata illa billah',
        meanings: {
          'tr': 'Güç ve kuvvet ancak Allah\'tandır',
          'en': 'There is no power except with Allah',
        },
        recommendedCount: 100,
        source: 'Hadith reference',
      );

      final dhikr = DhikrModel.fromMoodDhikr(mockMoodDhikr);

      expect(dhikr.id, contains('mood_dhikr_'));
      expect(dhikr.arabic, mockMoodDhikr.arabic);
      expect(dhikr.transliteration, mockMoodDhikr.transliteration);
      expect(dhikr.meaning, mockMoodDhikr.meanings);
      expect(dhikr.defaultTarget, mockMoodDhikr.recommendedCount);
      expect(dhikr.note, mockMoodDhikr.source);
      expect(dhikr.isCustom, false);
      expect(dhikr.isFavorite, false);
      expect(dhikr.totalCount, 0);
      expect(dhikr.createdAt, isNotNull);
    });

    test('DhikrModel fromEsma factory creates correct dhikr', () {
      // Mock EsmaModel structure
      final mockEsma = _MockEsma(
        order: 1,
        arabic: 'الرحمن',
        transliteration: 'Ar-Rahman',
        meaning: {
          'tr': 'Sonsuz merhametli',
          'en': 'The Most Merciful',
        },
        suggestedCounts: [99, 100, 1000],
      );

      final dhikr = DhikrModel.fromEsma(mockEsma);

      expect(dhikr.id, 'esma_1_ar-rahman');
      expect(dhikr.arabic, mockEsma.arabic);
      expect(dhikr.transliteration, mockEsma.transliteration);
      expect(dhikr.meaning, mockEsma.meaning);
      expect(dhikr.defaultTarget, 99); // First suggested count
      expect(dhikr.note, 'Esma-ul Husna #1');
      expect(dhikr.isCustom, false);
      expect(dhikr.isFavorite, false);
      expect(dhikr.totalCount, 0);
      expect(dhikr.createdAt, isNotNull);
    });

    test('DhikrModel fromEsma handles empty suggestedCounts', () {
      final mockEsma = _MockEsma(
        order: 1,
        arabic: 'الرحمن',
        transliteration: 'Ar-Rahman',
        meaning: {'tr': 'Test'},
        suggestedCounts: [],
      );

      final dhikr = DhikrModel.fromEsma(mockEsma);

      expect(dhikr.defaultTarget, 99); // Default when no suggestions
    });
  });
}

// Mock classes for testing factory methods
class _MockMoodDhikr {
  final String arabic;
  final String transliteration;
  final Map<String, String> meanings;
  final int recommendedCount;
  final String source;

  _MockMoodDhikr({
    required this.arabic,
    required this.transliteration,
    required this.meanings,
    required this.recommendedCount,
    required this.source,
  });
}

class _MockEsma {
  final int order;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final List<int> suggestedCounts;

  _MockEsma({
    required this.order,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.suggestedCounts,
  });
}
