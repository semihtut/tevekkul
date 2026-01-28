import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../config/app_typography.dart';

class WeeklyCalendar extends StatelessWidget {
  final DateTime? streakStart;
  final bool isDark;
  final String lang;

  const WeeklyCalendar({
    super.key,
    required this.streakStart,
    required this.isDark,
    required this.lang,
  });

  List<String> get _dayLabels {
    if (lang == 'tr') {
      return ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    } else if (lang == 'fi') {
      return ['Ma', 'Ti', 'Ke', 'To', 'Pe', 'La', 'Su'];
    }
    return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get start of current week (Monday)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    // Calculate which days are "clean" based on streak start
    List<bool> cleanDays = List.filled(7, false);
    if (streakStart != null) {
      final start = DateTime(streakStart!.year, streakStart!.month, streakStart!.day);
      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        // Day is clean if it's on or after streak start AND on or before today
        cleanDays[i] = !day.isBefore(start) && !day.isAfter(today);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang == 'tr' ? 'Bu Hafta' : lang == 'fi' ? 'Tämä viikko' : 'This Week',
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final day = weekStart.add(Duration(days: index));
              final isToday = day.isAtSameMomentAs(today);
              final isClean = cleanDays[index];
              final isFuture = day.isAfter(today);

              return _buildDayItem(
                _dayLabels[index],
                isClean: isClean,
                isToday: isToday,
                isFuture: isFuture,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(
    String label, {
    required bool isClean,
    required bool isToday,
    required bool isFuture,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isClean
                ? AppColors.primary
                : isFuture
                    ? Colors.transparent
                    : isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
            border: isToday
                ? Border.all(
                    color: AppColors.primary,
                    width: 2,
                  )
                : isFuture
                    ? Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
          ),
          child: Center(
            child: isClean
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : isFuture
                    ? null
                    : Icon(
                        Icons.close,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.4),
                        size: 16,
                      ),
          ),
        ),
      ],
    );
  }
}
