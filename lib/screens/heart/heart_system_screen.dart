import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/heart_stage_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/heart/animated_heart.dart';
import '../../widgets/heart/ekg_line_painter.dart';

class HeartSystemScreen extends ConsumerStatefulWidget {
  const HeartSystemScreen({super.key});

  @override
  ConsumerState<HeartSystemScreen> createState() => _HeartSystemScreenState();
}

class _HeartSystemScreenState extends ConsumerState<HeartSystemScreen> {
  HeartStageConfig? _previousStage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(userProgressProvider);
    final lang = ref.watch(languageProvider);
    final todayDhikr = progress.todayDhikrCount;
    final stage = HeartStageConfigs.getStageForDhikr(todayDhikr);
    final stageProgress = HeartStageConfigs.getStageProgress(todayDhikr);

    // Check for milestone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousStage != null && _previousStage!.stage != stage.stage) {
        _showMilestone(context, stage, lang);
      }
      _previousStage = stage;
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                )
              : AppColors.backgroundGradientLight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              children: [
                _buildHeader(context, isDark, lang),
                const SizedBox(height: AppConstants.spacingL),
                _buildStageInfo(stage, todayDhikr, stageProgress, isDark, lang),
                const SizedBox(height: AppConstants.spacingL),
                Expanded(
                  child: _buildHeartContainer(stage, isDark),
                ),
                const SizedBox(height: AppConstants.spacingL),
                _buildStats(progress, isDark, lang),
                const SizedBox(height: AppConstants.spacingL),
                _buildDhikrButton(context, isDark, lang),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, String lang) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
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
              'Qalb',
              style: AppTypography.headingMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: Text(
                'Hz',
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

  Widget _buildStageInfo(
    HeartStageConfig stage,
    int dhikrCount,
    double progress,
    bool isDark,
    String lang,
  ) {
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

  Widget _buildHeartContainer(HeartStageConfig stage, bool isDark) {
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

  Widget _buildStats(dynamic progress, bool isDark, String lang) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            lang == 'en'
                ? 'Total Dhikr'
                : (lang == 'fi' ? 'Yhteensä' : 'Toplam Zikir'),
            '${progress.totalDhikrCount}',
            isDark,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            lang == 'en'
                ? 'Heart Level'
                : (lang == 'fi' ? 'Sydäntaso' : 'Kalp Seviyesi'),
            '${progress.currentLevel}',
            isDark,
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: _buildStatCard(
            lang == 'en'
                ? 'Day Streak'
                : (lang == 'fi' ? 'Päiväputki' : 'Gün Serisi'),
            '${progress.currentStreak}',
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, bool isDark) {
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

  Widget _buildDhikrButton(BuildContext context, bool isDark, String lang) {
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

  void _showMilestone(
      BuildContext context, HeartStageConfig stage, String lang) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => _MilestoneDialog(stage: stage, lang: lang),
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}

class _MilestoneDialog extends StatefulWidget {
  final HeartStageConfig stage;
  final String lang;

  const _MilestoneDialog({required this.stage, required this.lang});

  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog>
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
