import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';
import 'dart:math';

class MoodState {
  final List<MoodModel> moods;
  final MoodModel? selectedMood;
  final AyahReference? recommendedAyah;
  final bool isLoading;

  const MoodState({
    this.moods = const [],
    this.selectedMood,
    this.recommendedAyah,
    this.isLoading = false,
  });

  MoodState copyWith({
    List<MoodModel>? moods,
    MoodModel? selectedMood,
    AyahReference? recommendedAyah,
    bool? isLoading,
  }) {
    return MoodState(
      moods: moods ?? this.moods,
      selectedMood: selectedMood ?? this.selectedMood,
      recommendedAyah: recommendedAyah ?? this.recommendedAyah,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MoodNotifier extends StateNotifier<MoodState> {
  MoodNotifier() : super(const MoodState());

  final _random = Random();

  void setMoods(List<MoodModel> moods) {
    state = state.copyWith(moods: moods);
  }

  void selectMood(MoodModel mood) {
    state = state.copyWith(selectedMood: mood);
    _generateRecommendation();
  }

  void _generateRecommendation() {
    final mood = state.selectedMood;
    if (mood == null || mood.ayahReferences.isEmpty) return;

    final index = _random.nextInt(mood.ayahReferences.length);
    state = state.copyWith(recommendedAyah: mood.ayahReferences[index]);
  }

  void refreshRecommendation() {
    _generateRecommendation();
  }

  void clearSelection() {
    state = const MoodState();
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  return MoodNotifier();
});

final selectedMoodProvider = Provider<MoodModel?>((ref) {
  return ref.watch(moodProvider).selectedMood;
});

final recommendedAyahProvider = Provider<AyahReference?>((ref) {
  return ref.watch(moodProvider).recommendedAyah;
});
