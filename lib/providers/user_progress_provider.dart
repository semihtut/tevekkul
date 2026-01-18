import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress_model.dart';

class UserProgressNotifier extends StateNotifier<UserProgressModel> {
  UserProgressNotifier() : super(const UserProgressModel());

  void loadProgress(UserProgressModel progress) {
    state = progress;
  }

  void incrementDhikr(int count) {
    final today = DateTime.now();

    // Check if it's a new day
    final isNewDay = state.lastActiveDate == null ||
        state.lastActiveDate!.day != today.day ||
        state.lastActiveDate!.month != today.month ||
        state.lastActiveDate!.year != today.year;

    int newTodayCount = isNewDay ? count : state.todayDhikrCount + count;

    // Update weekly progress
    List<DailyProgress> updatedWeekly = [...state.weeklyProgress];
    final existingIndex = updatedWeekly.indexWhere(
      (p) =>
          p.date.year == today.year &&
          p.date.month == today.month &&
          p.date.day == today.day,
    );

    if (existingIndex >= 0) {
      updatedWeekly[existingIndex] = DailyProgress(
        date: today,
        count: updatedWeekly[existingIndex].count + count,
      );
    } else {
      updatedWeekly.add(DailyProgress(
        date: today,
        count: count,
      ));
      // Keep only last 7 days
      if (updatedWeekly.length > 7) {
        updatedWeekly = updatedWeekly.sublist(updatedWeekly.length - 7);
      }
    }

    // Calculate streak
    int newStreak = _calculateStreak(updatedWeekly, state.currentStreak, isNewDay);
    int newLongestStreak = newStreak > state.longestStreak ? newStreak : state.longestStreak;

    // Calculate XP
    int xpGained = count; // 1 XP per dhikr
    int newXp = state.currentXp + xpGained;
    int newLevel = state.currentLevel;
    int newXpForNext = state.xpForNextLevel;

    while (newXp >= newXpForNext) {
      newXp -= newXpForNext;
      newLevel++;
      newXpForNext = newLevel * 100; // Each level needs more XP
    }

    state = state.copyWith(
      totalDhikrCount: state.totalDhikrCount + count,
      todayDhikrCount: newTodayCount,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      weeklyProgress: updatedWeekly,
      lastActiveDate: today,
      currentLevel: newLevel,
      currentXp: newXp,
      xpForNextLevel: newXpForNext,
    );
  }

  int _calculateStreak(List<DailyProgress> weekly, int currentStreak, bool isNewDay) {
    if (weekly.isEmpty) return 0;

    final sorted = [...weekly]..sort((a, b) => b.date.compareTo(a.date));

    // If continuing same day, keep current streak
    if (!isNewDay && currentStreak > 0) return currentStreak;

    // Check if yesterday was active
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    bool hadActivityYesterday = sorted.any((p) =>
        p.date.year == yesterday.year &&
        p.date.month == yesterday.month &&
        p.date.day == yesterday.day &&
        p.count > 0);

    if (isNewDay) {
      return hadActivityYesterday ? currentStreak + 1 : 1;
    }

    return currentStreak;
  }

  void addBadge(Badge badge) {
    if (!state.earnedBadges.any((b) => b.id == badge.id)) {
      state = state.copyWith(
        earnedBadges: [...state.earnedBadges, badge],
      );
    }
  }

  void resetDaily() {
    state = state.copyWith(todayDhikrCount: 0);
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressModel>((ref) {
  return UserProgressNotifier();
});

final todayProgressProvider = Provider<double>((ref) {
  return ref.watch(userProgressProvider).todayProgressPercent;
});

final streakProvider = Provider<int>((ref) {
  return ref.watch(userProgressProvider).currentStreak;
});

final levelProvider = Provider<int>((ref) {
  return ref.watch(userProgressProvider).currentLevel;
});
