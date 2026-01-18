import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../widgets/common/glass_container.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final double _compassHeading = 0;
  double _qiblaDirection = 0;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initCompass();
  }

  Future<void> _initCompass() async {
    // In a real app, we would:
    // 1. Request location permissions
    // 2. Get current location
    // 3. Calculate Qibla direction from current location
    // 4. Subscribe to compass updates

    // For now, simulate with placeholder values
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _hasPermission = true;
      _isLoading = false;
      // Placeholder Qibla direction (would be calculated from user's location)
      _qiblaDirection = 136.5; // Example: Qibla from Helsinki
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            children: [
              Text(
                'Kible Yonu',
                style: AppTypography.headingMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppConstants.spacingM),
              Text(
                'Telefonunuzu duz tutun',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const Spacer(),
              _buildCompass(isDark),
              const Spacer(),
              _buildInfoCard(isDark),
              const SizedBox(height: AppConstants.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(bool isDark) {
    if (_isLoading) {
      return SizedBox(
        width: 280,
        height: 280,
        child: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.accentDark : AppColors.primary,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return GlassContainer(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initCompass();
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final qiblaAngle = (_qiblaDirection - _compassHeading) * (math.pi / 180);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass background
          GlassContainer(
            borderRadius: BorderRadius.circular(140),
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _CompassPainter(
                  heading: _compassHeading,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          // Qibla indicator
          Transform.rotate(
            angle: qiblaAngle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Center point
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.accentDark : Colors.white,
                width: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.accentDark : AppColors.primary)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              Icons.explore_rounded,
              color: isDark ? AppColors.accentDark : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kible Yonu',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '${_qiblaDirection.toStringAsFixed(1)}°',
                  style: AppTypography.headingSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Pusula',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${_compassHeading.toStringAsFixed(0)}°',
                style: AppTypography.headingSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final bool isDark;

  _CompassPainter({
    required this.heading,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw compass ticks
    final tickPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.textPrimaryLight)
          .withOpacity(0.3)
      ..strokeWidth = 1;

    final majorTickPaint = Paint()
      ..color = isDark ? Colors.white : AppColors.textPrimaryLight
      ..strokeWidth = 2;

    for (var i = 0; i < 360; i += 10) {
      final angle = (i - heading) * (math.pi / 180) - math.pi / 2;
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 15.0 : 8.0;

      final start = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }

    // Draw cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - heading) * (math.pi / 180) - math.pi / 2;
      final textRadius = radius - 35;

      textPainter.text = TextSpan(
        text: directions[i],
        style: AppTypography.labelLarge.copyWith(
          color: directions[i] == 'N'
              ? Colors.red.shade400
              : (isDark ? Colors.white : AppColors.textPrimaryLight),
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + textRadius * math.cos(angle) - textPainter.width / 2,
        center.dy + textRadius * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return heading != oldDelegate.heading || isDark != oldDelegate.isDark;
  }
}
