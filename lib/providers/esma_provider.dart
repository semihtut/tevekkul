import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/esma_model.dart';
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
    state = state.copyWith(esmaList: list);
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
