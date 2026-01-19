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
