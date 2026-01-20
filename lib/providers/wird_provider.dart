import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/wird_model.dart';
import '../models/dhikr_model.dart';
import '../models/esma_model.dart';
import '../services/storage_service.dart';

class WirdState {
  final List<WirdItem> items;
  final bool isLoading;
  final DateTime? lastReset;

  const WirdState({
    this.items = const [],
    this.isLoading = false,
    this.lastReset,
  });

  WirdState copyWith({
    List<WirdItem>? items,
    bool? isLoading,
    DateTime? lastReset,
  }) {
    return WirdState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      lastReset: lastReset ?? this.lastReset,
    );
  }

  DailyWirdSummary get summary {
    final totalItems = items.length;
    final completedItems = items.where((item) => item.isCompleted).length;
    final totalTarget = items.fold<int>(0, (sum, item) => sum + item.targetCount);
    final totalProgress = items.fold<int>(0, (sum, item) => sum + item.currentCount);

    return DailyWirdSummary(
      totalItems: totalItems,
      completedItems: completedItems,
      totalTarget: totalTarget,
      totalProgress: totalProgress,
    );
  }
}

class WirdNotifier extends StateNotifier<WirdState> {
  WirdNotifier() : super(const WirdState()) {
    _loadFromStorage();
  }

  final _uuid = const Uuid();
  final _storage = StorageService();

  Future<void> _loadFromStorage() async {
    state = state.copyWith(isLoading: true);

    final savedItems = _storage.loadWirdItems();
    final lastReset = _storage.getWirdLastReset();

    final items = savedItems.map((json) => WirdItem.fromJson(json)).toList();

    state = state.copyWith(
      items: items,
      lastReset: lastReset,
      isLoading: false,
    );
  }

  Future<void> _saveToStorage() async {
    final jsonItems = state.items.map((item) => item.toJson()).toList();
    await _storage.saveWirdItems(jsonItems);
  }

  Future<void> addDhikrToWird(DhikrModel dhikr, {int? customTarget}) async {
    // Aynı dhikr zaten varsa ekleme
    if (state.items.any((item) => item.dhikrId == dhikr.id && item.type == 'dhikr')) {
      return;
    }

    final newItem = WirdItem(
      id: _uuid.v4(),
      dhikrId: dhikr.id,
      type: 'dhikr',
      arabic: dhikr.arabic,
      transliteration: dhikr.transliteration,
      meaning: dhikr.meaning,
      targetCount: customTarget ?? dhikr.defaultTarget,
      addedAt: DateTime.now(),
    );

    state = state.copyWith(items: [...state.items, newItem]);
    await _saveToStorage();
  }

  Future<void> addEsmaToWird(EsmaModel esma, {int? customTarget}) async {
    final esmaId = 'esma_${esma.id}';

    // Aynı esma zaten varsa ekleme
    if (state.items.any((item) => item.dhikrId == esmaId && item.type == 'esma')) {
      return;
    }

    final newItem = WirdItem(
      id: _uuid.v4(),
      dhikrId: esmaId,
      type: 'esma',
      arabic: esma.arabic,
      transliteration: esma.transliteration,
      meaning: {
        'tr': esma.getMeaning('tr'),
        'en': esma.getMeaning('en'),
        'fi': esma.getMeaning('fi'),
      },
      targetCount: customTarget ?? esma.abjadValue,
      addedAt: DateTime.now(),
    );

    state = state.copyWith(items: [...state.items, newItem]);
    await _saveToStorage();
  }

  Future<void> removeFromWird(String itemId) async {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
    await _saveToStorage();
  }

  Future<void> updateProgress(String itemId, int count) async {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          currentCount: count,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    await _saveToStorage();
  }

  Future<void> incrementProgress(String itemId) async {
    final item = state.items.firstWhere((i) => i.id == itemId);
    if (item.currentCount < item.targetCount) {
      await updateProgress(itemId, item.currentCount + 1);
    }
  }

  Future<void> resetItem(String itemId) async {
    await updateProgress(itemId, 0);
  }

  Future<void> resetAllItems() async {
    final updatedItems = state.items.map((item) {
      return item.copyWith(
        currentCount: 0,
        lastUpdated: DateTime.now(),
      );
    }).toList();

    state = state.copyWith(
      items: updatedItems,
      lastReset: DateTime.now(),
    );
    await _saveToStorage();
    await _storage.saveWirdLastReset(DateTime.now());
  }

  Future<void> updateTargetCount(String itemId, int newTarget) async {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          targetCount: newTarget,
          lastUpdated: DateTime.now(),
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    await _saveToStorage();
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    final items = List<WirdItem>.from(state.items);
    if (newIndex > oldIndex) newIndex--;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    state = state.copyWith(items: items);
    await _saveToStorage();
  }

  bool isInWird(String dhikrId, String type) {
    final checkId = type == 'esma' ? 'esma_$dhikrId' : dhikrId;
    return state.items.any((item) => item.dhikrId == checkId && item.type == type);
  }
}

final wirdProvider = StateNotifierProvider<WirdNotifier, WirdState>((ref) {
  return WirdNotifier();
});

final wirdSummaryProvider = Provider<DailyWirdSummary>((ref) {
  return ref.watch(wirdProvider).summary;
});

final wirdItemsProvider = Provider<List<WirdItem>>((ref) {
  return ref.watch(wirdProvider).items;
});

final isInWirdProvider = Provider.family<bool, ({String id, String type})>((ref, params) {
  final wirdState = ref.watch(wirdProvider);
  final checkId = params.type == 'esma' ? 'esma_${params.id}' : params.id;
  return wirdState.items.any((item) => item.dhikrId == checkId && item.type == params.type);
});
