import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/heart_stage_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_progress_provider.dart';
import 'heart_system_widgets.dart';

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
                HeartSystemHeader(
                  onBackPressed: () => Navigator.pop(context),
                  isDark: isDark,
                ),
                const SizedBox(height: AppConstants.spacingL),
                HeartStageInfoCard(
                  stage: stage,
                  dhikrCount: todayDhikr,
                  progress: stageProgress,
                  isDark: isDark,
                  lang: lang,
                ),
                const SizedBox(height: AppConstants.spacingL),
                Expanded(
                  child: HeartAnimationContainer(stage: stage),
                ),
                const SizedBox(height: AppConstants.spacingL),
                HeartStatsRow(
                  progress: progress,
                  isDark: isDark,
                  lang: lang,
                ),
                const SizedBox(height: AppConstants.spacingL),
                DhikrActionButton(
                  isDark: isDark,
                  lang: lang,
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
      builder: (context) => MilestoneDialog(stage: stage, lang: lang),
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}
