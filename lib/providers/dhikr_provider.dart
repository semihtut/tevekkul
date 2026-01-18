import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dhikr_model.dart';

class DhikrState {
  final List<DhikrModel> dhikrs;
  final DhikrModel? selectedDhikr;
  final int currentCount;
  final int targetCount;
  final bool isLoading;

  const DhikrState({
    this.dhikrs = const [],
    this.selectedDhikr,
    this.currentCount = 0,
    this.targetCount = 33,
    this.isLoading = false,
  });

  DhikrState copyWith({
    List<DhikrModel>? dhikrs,
    DhikrModel? selectedDhikr,
    int? currentCount,
    int? targetCount,
    bool? isLoading,
  }) {
    return DhikrState(
      dhikrs: dhikrs ?? this.dhikrs,
      selectedDhikr: selectedDhikr ?? this.selectedDhikr,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DhikrNotifier extends StateNotifier<DhikrState> {
  DhikrNotifier() : super(const DhikrState());

  void setDhikrs(List<DhikrModel> dhikrs) {
    state = state.copyWith(dhikrs: dhikrs);
  }

  void selectDhikr(DhikrModel dhikr) {
    state = state.copyWith(
      selectedDhikr: dhikr,
      currentCount: 0,
    );
  }

  void setTarget(int target) {
    state = state.copyWith(targetCount: target);
  }

  void increment() {
    final newCount = state.currentCount + 1;
    state = state.copyWith(currentCount: newCount);

    // Update dhikr total count if selected
    if (state.selectedDhikr != null) {
      final updatedDhikr = state.selectedDhikr!.copyWith(
        totalCount: state.selectedDhikr!.totalCount + 1,
      );
      final updatedDhikrs = state.dhikrs.map((d) {
        return d.id == updatedDhikr.id ? updatedDhikr : d;
      }).toList();
      state = state.copyWith(
        selectedDhikr: updatedDhikr,
        dhikrs: updatedDhikrs,
      );
    }
  }

  void reset() {
    state = state.copyWith(currentCount: 0);
  }

  void toggleFavorite(String dhikrId) {
    final updatedDhikrs = state.dhikrs.map((d) {
      if (d.id == dhikrId) {
        return d.copyWith(isFavorite: !d.isFavorite);
      }
      return d;
    }).toList();

    DhikrModel? updatedSelected;
    if (state.selectedDhikr?.id == dhikrId) {
      updatedSelected = state.selectedDhikr!.copyWith(
        isFavorite: !state.selectedDhikr!.isFavorite,
      );
    }

    state = state.copyWith(
      dhikrs: updatedDhikrs,
      selectedDhikr: updatedSelected ?? state.selectedDhikr,
    );
  }

  List<DhikrModel> get favorites {
    return state.dhikrs.where((d) => d.isFavorite).toList();
  }
}

final dhikrProvider = StateNotifierProvider<DhikrNotifier, DhikrState>((ref) {
  return DhikrNotifier();
});

final favoriteDhikrsProvider = Provider<List<DhikrModel>>((ref) {
  final state = ref.watch(dhikrProvider);
  return state.dhikrs.where((d) => d.isFavorite).toList();
});
