import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/esma_model.dart';
import '../models/mood_model.dart';

class DataLoaderService {
  static final DataLoaderService _instance = DataLoaderService._internal();
  factory DataLoaderService() => _instance;
  DataLoaderService._internal();

  List<EsmaModel>? _cachedEsmaList;
  List<MoodModel>? _cachedMoodList;

  Future<List<EsmaModel>> loadEsmaList() async {
    if (_cachedEsmaList != null) return _cachedEsmaList!;

    try {
      final jsonString = await rootBundle.loadString('data/asma_ul_husna_complete.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> esmaData = jsonData['asma_ul_husna'] ?? [];
      _cachedEsmaList = esmaData.map((e) => EsmaModel.fromJson(e as Map<String, dynamic>)).toList();
      return _cachedEsmaList!;
    } catch (e) {
      print('Error loading esma data: $e');
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
      print('Error loading mood data: $e');
      return [];
    }
  }

  void clearCache() {
    _cachedEsmaList = null;
    _cachedMoodList = null;
  }
}
