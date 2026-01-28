import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/situation_model.dart';
import '../services/data_loader_service.dart';

/// State for situation-based prayers
class SituationState {
  final List<SituationCategory> categories;
  final SituationCategory? selectedCategory;
  final Situation? selectedSituation;
  final bool isLoading;

  const SituationState({
    this.categories = const [],
    this.selectedCategory,
    this.selectedSituation,
    this.isLoading = false,
  });

  SituationState copyWith({
    List<SituationCategory>? categories,
    SituationCategory? selectedCategory,
    Situation? selectedSituation,
    bool? isLoading,
    bool clearCategory = false,
    bool clearSituation = false,
  }) {
    return SituationState(
      categories: categories ?? this.categories,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSituation: clearSituation ? null : (selectedSituation ?? this.selectedSituation),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier for managing situation state
class SituationNotifier extends StateNotifier<SituationState> {
  SituationNotifier() : super(const SituationState());

  /// Load all situation categories
  Future<void> loadCategories() async {
    if (state.categories.isNotEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final categories = await DataLoaderService().loadSituationCategories();
      state = state.copyWith(
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Select a category
  void selectCategory(SituationCategory category) {
    state = state.copyWith(
      selectedCategory: category,
      clearSituation: true,
    );
  }

  /// Select a situation
  void selectSituation(Situation situation) {
    state = state.copyWith(selectedSituation: situation);
  }

  /// Clear all selections
  void clearSelection() {
    state = state.copyWith(
      clearCategory: true,
      clearSituation: true,
    );
  }

  /// Clear only situation selection
  void clearSituationSelection() {
    state = state.copyWith(clearSituation: true);
  }
}

/// Main situation provider
final situationProvider = StateNotifierProvider<SituationNotifier, SituationState>((ref) {
  return SituationNotifier();
});

/// Provider to load situation categories (async)
final situationCategoriesProvider = FutureProvider<List<SituationCategory>>((ref) async {
  return await DataLoaderService().loadSituationCategories();
});

/// Selected category provider (derived)
final selectedCategoryProvider = Provider<SituationCategory?>((ref) {
  return ref.watch(situationProvider).selectedCategory;
});

/// Selected situation provider (derived)
final selectedSituationProvider = Provider<Situation?>((ref) {
  return ref.watch(situationProvider).selectedSituation;
});
