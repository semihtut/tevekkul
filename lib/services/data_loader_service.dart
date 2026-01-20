import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/esma_model.dart';
import '../models/mood_model.dart';
import '../models/mood_dhikr_model.dart';

class DataLoaderService {
  static final DataLoaderService _instance = DataLoaderService._internal();
  factory DataLoaderService() => _instance;
  DataLoaderService._internal();

  List<EsmaModel>? _cachedEsmaList;
  List<MoodModel>? _cachedMoodList;
  Map<String, Map<String, String>>? _cachedPurposes;
  Map<String, MoodDhikrModel>? _cachedMoodDhikr;

  Future<Map<String, Map<String, String>>> _loadPurposes() async {
    if (_cachedPurposes != null) return _cachedPurposes!;

    try {
      final jsonString = await rootBundle.loadString('data/esma_purposes_trilingual.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cachedPurposes = jsonData.map((key, value) => MapEntry(
        key,
        (value as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString())),
      ));
      return _cachedPurposes!;
    } catch (e) {
      debugPrint('Error loading purposes data: $e');
      return {};
    }
  }

  Future<List<EsmaModel>> loadEsmaList() async {
    if (_cachedEsmaList != null) return _cachedEsmaList!;

    try {
      final jsonString = await rootBundle.loadString('data/asma_ul_husna_complete.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final purposes = await _loadPurposes();

      final List<dynamic> esmaData = jsonData['entries'] ?? jsonData['asma_ul_husna'] ?? [];
      _cachedEsmaList = esmaData.map((e) {
        final esma = EsmaModel.fromJson(e as Map<String, dynamic>);
        // Match purpose by transliteration
        final purpose = purposes[esma.transliteration] ?? {};
        return esma.copyWith(purposes: purpose);
      }).toList();
      return _cachedEsmaList!;
    } catch (e) {
      debugPrint('Error loading esma data: $e');
      return [];
    }
  }

  Future<List<MoodModel>> loadMoodList() async {
    if (_cachedMoodList != null) return _cachedMoodList!;

    try {
      final jsonString = await rootBundle.loadString('data/moods_extended.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> moodData = jsonData['moods'] ?? [];
      _cachedMoodList = moodData.map((e) => MoodModel.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedMoodList!;
    } catch (e) {
      debugPrint('Error loading mood data: $e');
      return [];
    }
  }

  /// Load mood-specific dhikr recommendations
  Future<Map<String, MoodDhikrModel>> loadMoodDhikrRecommendations() async {
    if (_cachedMoodDhikr != null) return _cachedMoodDhikr!;

    try {
      final jsonString = await rootBundle.loadString('data/mood_dhikr_recommendations.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final Map<String, dynamic> dhikrData = jsonData['dhikr_recommendations'] ?? {};
      _cachedMoodDhikr = dhikrData.map((moodId, data) {
        final primaryDhikr = data['primary_dhikr'] as Map<String, dynamic>;
        return MapEntry(moodId, MoodDhikrModel.fromJson(primaryDhikr));
      });
      return _cachedMoodDhikr!;
    } catch (e) {
      debugPrint('Error loading mood dhikr data: $e');
      return {};
    }
  }

  /// Get dhikr recommendation for a specific mood
  Future<MoodDhikrModel?> getDhikrForMood(String moodId) async {
    final dhikrMap = await loadMoodDhikrRecommendations();
    return dhikrMap[moodId];
  }

  void clearCache() {
    _cachedEsmaList = null;
    _cachedMoodList = null;
    _cachedMoodDhikr = null;
  }
}
