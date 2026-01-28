import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/esma_model.dart';
import '../services/storage_service.dart';
import 'dart:math';

class EsmaState {
  final List<EsmaModel> esmaList;
  final EsmaModel? dailyEsma;
  final EsmaModel? surpriseEsma;
  final bool isLoading;

  const EsmaState({
    this.esmaList = const [],
    this.dailyEsma,
    this.surpriseEsma,
    this.isLoading = false,
  });

  EsmaState copyWith({
    List<EsmaModel>? esmaList,
    EsmaModel? dailyEsma,
    EsmaModel? surpriseEsma,
    bool? isLoading,
  }) {
    return EsmaState(
      esmaList: esmaList ?? this.esmaList,
      dailyEsma: dailyEsma ?? this.dailyEsma,
      surpriseEsma: surpriseEsma ?? this.surpriseEsma,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class EsmaNotifier extends StateNotifier<EsmaState> {
  EsmaNotifier() : super(const EsmaState());

  final _random = Random();

  void setEsmaList(List<EsmaModel> list) {
    // Load saved favorite IDs and apply to esmas
    final savedFavoriteIds = StorageService().loadEsmaFavorites();
    final esmasWithFavorites = list.map((e) {
      if (savedFavoriteIds.contains(e.id)) {
        return e.copyWith(isFavorite: true);
      }
      return e;
    }).toList();
    state = state.copyWith(esmaList: esmasWithFavorites);
  }

  void toggleFavorite(String esmaId) {
    final updatedEsmas = state.esmaList.map((e) {
      if (e.id == esmaId) {
        return e.copyWith(isFavorite: !e.isFavorite);
      }
      return e;
    }).toList();

    state = state.copyWith(esmaList: updatedEsmas);

    // Save favorites to persistent storage
    final favoriteIds = updatedEsmas
        .where((e) => e.isFavorite)
        .map((e) => e.id)
        .toList();
    StorageService().saveEsmaFavorites(favoriteIds);
  }

  void setDailyEsma(EsmaModel esma) {
    state = state.copyWith(dailyEsma: esma);
  }

  void generateSurpriseEsma() {
    if (state.esmaList.isEmpty) return;
    final index = _random.nextInt(state.esmaList.length);
    state = state.copyWith(surpriseEsma: state.esmaList[index]);
  }

  EsmaModel? getEsmaByAbjadValue(int value) {
    // Find esma with matching or closest abjad value
    if (state.esmaList.isEmpty) return null;

    // First try exact match
    final exactMatch = state.esmaList.where((e) => e.abjadValue == value).toList();
    if (exactMatch.isNotEmpty) {
      return exactMatch[_random.nextInt(exactMatch.length)];
    }

    // Find closest match
    EsmaModel? closest;
    int minDiff = 999999;
    for (final esma in state.esmaList) {
      final diff = (esma.abjadValue - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = esma;
      }
    }
    return closest;
  }

  List<EsmaModel> getEsmasByTheme(String theme) {
    return state.esmaList.where((e) => e.themes.contains(theme)).toList();
  }

  /// Search esmas by query (transliteration, meaning, arabic)
  List<EsmaModel> searchEsmas(String query, String lang) {
    if (query.isEmpty) return [];

    final normalizedQuery = query.toLowerCase().trim();

    return state.esmaList.where((esma) {
      // Search in transliteration (Ya Latif, Latif, etc.)
      final translitMatch = esma.transliteration.toLowerCase().contains(normalizedQuery);

      // Search in meaning
      final meaning = esma.getMeaning(lang).toLowerCase();
      final meaningMatch = meaning.contains(normalizedQuery);

      // Search in arabic
      final arabicMatch = esma.arabic.contains(query);

      // Search in purposes if available
      final purpose = esma.getPurpose(lang).toLowerCase();
      final purposeMatch = purpose.contains(normalizedQuery);

      return translitMatch || meaningMatch || arabicMatch || purposeMatch;
    }).toList();
  }

  /// Get similar esmas based on shared themes
  List<EsmaModel> getSimilarEsmas(EsmaModel esma, {int limit = 5}) {
    if (esma.themes.isEmpty) return [];

    // Score each esma by number of shared themes
    final scored = state.esmaList
        .where((e) => e.id != esma.id)
        .map((e) {
          final sharedThemes = e.themes.where((t) => esma.themes.contains(t)).length;
          return (esma: e, score: sharedThemes);
        })
        .where((item) => item.score > 0)
        .toList();

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(limit).map((item) => item.esma).toList();
  }

  /// Get esma by id
  EsmaModel? getEsmaById(String id) {
    try {
      return state.esmaList.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final esmaProvider = StateNotifierProvider<EsmaNotifier, EsmaState>((ref) {
  return EsmaNotifier();
});

final dailyEsmaProvider = Provider<EsmaModel?>((ref) {
  return ref.watch(esmaProvider).dailyEsma;
});

final surpriseEsmaProvider = Provider<EsmaModel?>((ref) {
  return ref.watch(esmaProvider).surpriseEsma;
});

final favoriteEsmasProvider = Provider<List<EsmaModel>>((ref) {
  final state = ref.watch(esmaProvider);
  return state.esmaList.where((e) => e.isFavorite).toList();
});

// Search state
class EsmaSearchState {
  final String query;
  final List<EsmaModel> results;
  final EsmaModel? selectedEsma;
  final List<EsmaModel> similarEsmas;

  const EsmaSearchState({
    this.query = '',
    this.results = const [],
    this.selectedEsma,
    this.similarEsmas = const [],
  });

  EsmaSearchState copyWith({
    String? query,
    List<EsmaModel>? results,
    EsmaModel? selectedEsma,
    List<EsmaModel>? similarEsmas,
    bool clearSelectedEsma = false,
  }) {
    return EsmaSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      selectedEsma: clearSelectedEsma ? null : (selectedEsma ?? this.selectedEsma),
      similarEsmas: similarEsmas ?? this.similarEsmas,
    );
  }
}

class EsmaSearchNotifier extends StateNotifier<EsmaSearchState> {
  final EsmaNotifier _esmaNotifier;
  final String _lang;

  EsmaSearchNotifier(this._esmaNotifier, this._lang) : super(const EsmaSearchState());

  void search(String query) {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: [], clearSelectedEsma: true, similarEsmas: []);
      return;
    }

    final results = _esmaNotifier.searchEsmas(query, _lang);
    state = state.copyWith(query: query, results: results);
  }

  void selectEsma(EsmaModel esma) {
    final similar = _esmaNotifier.getSimilarEsmas(esma);
    state = state.copyWith(selectedEsma: esma, similarEsmas: similar);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedEsma: true, similarEsmas: []);
  }

  void clear() {
    state = const EsmaSearchState();
  }
}

final esmaSearchProvider = StateNotifierProvider.family<EsmaSearchNotifier, EsmaSearchState, String>((ref, lang) {
  final esmaNotifier = ref.watch(esmaProvider.notifier);
  return EsmaSearchNotifier(esmaNotifier, lang);
});
