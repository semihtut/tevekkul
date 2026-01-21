import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/heart_stage_model.dart';
import '../../providers/user_progress_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/heart/animated_heart.dart';
import '../../widgets/heart/ekg_line_painter.dart';

/// Header widget displaying the app title with navigation
class HeartSystemHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final bool isDark;

  const HeartSystemHeader({
    super.key,
    required this.onBackPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBackPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFF0D9488).withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF134E4A),
            ),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Soul',
              style: AppTypography.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: Text(
                'Count',
                style: AppTypography.headingMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Stage information card showing heart stage, BPM, and progress
class HeartStageInfoCard extends StatelessWidget {
  final HeartStageConfig stage;
  final int dhikrCount;
  final double progress;
  final bool isDark;
  final String lang;

  const HeartStageInfoCard({
    super.key,
    required this.stage,
    required this.dhikrCount,
    required this.progress,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stage.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                stage.getName(lang),
                style: AppTypography.headingSmall.copyWith(
                  color: stage.heartColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            '${stage.bpm} BPM',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: stage.heartColor,
              shadows: [
                Shadow(
                  color: stage.heartColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$dhikrCount / ${stage.maxDhikr} ${lang == 'en' ? 'dhikr' : (lang == 'fi' ? 'dhikr' : 'zikir')}',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : stage.heartColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(stage.heartColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stage.getDescription(lang),
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Animated heart container with EKG line background
class HeartAnimationContainer extends StatelessWidget {
  final HeartStageConfig stage;

  const HeartAnimationContainer({
    super.key,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: stage.heartColor.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // EKG Line in background
            Positioned.fill(
              child: Center(
                child: AnimatedEKGLine(
                  color: stage.heartColor,
                  bpm: stage.bpm,
                  height: 100,
                ),
              ),
            ),
            // Animated Heart in center
            Center(
              child: AnimatedHeart(
                stage: stage,
                size: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Statistics cards row displaying total dhikr, level, and streak
class HeartStatsRow extends ConsumerWidget {
  final dynamic progress;
  final bool isDark;
  final String lang;

  const HeartStatsRow({
    super.key,
    required this.progress,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: lang == 'en'
                ? 'Total Dhikr'
                : (lang == 'fi' ? 'Yhteensä' : 'Toplam Zikir'),
            value: '${progress.totalDhikrCount}',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: StatCard(
            label: lang == 'en'
                ? 'Heart Level'
                : (lang == 'fi' ? 'Sydäntaso' : 'Kalp Seviyesi'),
            value: '${progress.currentLevel}',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: StatCard(
            label: lang == 'en'
                ? 'Day Streak'
                : (lang == 'fi' ? 'Päiväputki' : 'Gün Serisi'),
            value: '${progress.currentStreak}',
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

/// Individual stat card with label and value
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spacingM,
        horizontal: AppConstants.spacingS,
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Dhikr action button with gradient background
class DhikrActionButton extends ConsumerWidget {
  final bool isDark;
  final String lang;

  const DhikrActionButton({
    super.key,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(userProgressProvider.notifier).incrementDhikr(1);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💚', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  lang == 'en'
                      ? 'Do Dhikr (+1)'
                      : (lang == 'fi' ? 'Tee Dhikr (+1)' : 'Zikir Yap (+1)'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated milestone celebration dialog
class MilestoneDialog extends StatefulWidget {
  final HeartStageConfig stage;
  final String lang;

  const MilestoneDialog({
    super.key,
    required this.stage,
    required this.lang,
  });

  @override
  State<MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<MilestoneDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    _controller.repeat(reverse: true);

    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.stage.heartColor.withValues(alpha: 0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing emoji
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Text(
                      widget.stage.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                widget.stage.getName(widget.lang),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.stage.heartColor,
                  shadows: [
                    Shadow(
                      color: widget.stage.heartColor.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.stage.getDescription(widget.lang),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.stage.bpm} BPM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.stage.heartColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
