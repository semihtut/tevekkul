import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/app_typography.dart';
import '../../models/user_progress_model.dart';

/// Animated bar chart for weekly/monthly progress
class AnimatedBarChart extends StatefulWidget {
  final List<DailyProgress> data;
  final bool isDark;
  final String lang;
  final bool isWeekly;

  const AnimatedBarChart({
    super.key,
    required this.data,
    required this.isDark,
    required this.lang,
    this.isWeekly = true,
  });

  @override
  State<AnimatedBarChart> createState() => _AnimatedBarChartState();
}

class _AnimatedBarChartState extends State<AnimatedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = widget.data.isEmpty
        ? 100
        : widget.data.map((p) => p.count).reduce((a, b) => a > b ? a : b);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.isWeekly ? 150 : 120),
          painter: _BarChartPainter(
            data: widget.data,
            maxCount: maxCount > 0 ? maxCount : 100,
            progress: _animation.value,
            isDark: widget.isDark,
            lang: widget.lang,
            isWeekly: widget.isWeekly,
          ),
        );
      },
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<DailyProgress> data;
  final int maxCount;
  final double progress;
  final bool isDark;
  final String lang;
  final bool isWeekly;

  _BarChartPainter({
    required this.data,
    required this.maxCount,
    required this.progress,
    required this.isDark,
    required this.lang,
    required this.isWeekly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = isWeekly ? 28.0 : 8.0;
    final spacing = isWeekly
        ? (size.width - (7 * barWidth)) / 8
        : (size.width - (30 * barWidth)) / 31;
    final chartHeight = size.height - 30;

    // Draw bars
    final itemCount = isWeekly ? 7 : math.min(30, data.length);

    for (int i = 0; i < itemCount; i++) {
      final dayData = i < data.length ? data[i] : null;
      final count = dayData?.count ?? 0;
      final barHeight = maxCount > 0
          ? (count / maxCount) * chartHeight * progress
          : 0.0;

      final x = spacing + i * (barWidth + spacing);
      final y = chartHeight - barHeight;

      // Bar gradient
      if (count > 0) {
        final gradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: isDark
              ? [AppColors.accentDark, AppColors.accentDark.withValues(alpha: 0.6)]
              : [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
        );

        final rect = Rect.fromLTWH(x, y, barWidth, barHeight.clamp(4.0, chartHeight));
        paint.shader = gradient.createShader(rect);

        final rrect = RRect.fromRectAndRadius(
          rect,
          const Radius.circular(4),
        );
        canvas.drawRRect(rrect, paint);
        paint.shader = null;
      } else {
        // Empty bar placeholder
        paint.color = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1);
        final rect = Rect.fromLTWH(x, chartHeight - 4, barWidth, 4);
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
        canvas.drawRRect(rrect, paint);
      }
    }

    // Draw day labels for weekly view
    if (isWeekly) {
      final days = lang == 'en'
          ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
          : (lang == 'fi'
              ? ['M', 'T', 'K', 'T', 'P', 'L', 'S']
              : ['P', 'S', 'Ç', 'P', 'C', 'C', 'P']);

      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      for (int i = 0; i < 7; i++) {
        final x = spacing + i * (barWidth + spacing) + barWidth / 2;

        textPainter.text = TextSpan(
          text: days[i],
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, chartHeight + 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.data != data ||
        oldDelegate.isDark != isDark;
  }
}

/// Circular progress chart for overall statistics
class CircularStatsChart extends StatefulWidget {
  final double value;
  final String label;
  final String centerText;
  final Color color;
  final bool isDark;

  const CircularStatsChart({
    super.key,
    required this.value,
    required this.label,
    required this.centerText,
    required this.color,
    required this.isDark,
  });

  @override
  State<CircularStatsChart> createState() => _CircularStatsChartState();
}

class _CircularStatsChartState extends State<CircularStatsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _CircularChartPainter(
                  value: widget.value * _animation.value,
                  color: widget.color,
                  isDark: widget.isDark,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.centerText,
                    style: AppTypography.headingSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: widget.isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularChartPainter extends CustomPainter {
  final double value;
  final Color color;
  final bool isDark;

  _CircularChartPainter({
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;

    // Background arc
    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * value.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularChartPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

/// Mini sparkline chart for quick stats
class SparklineChart extends StatelessWidget {
  final List<int> data;
  final Color color;
  final double height;

  const SparklineChart({
    super.key,
    required this.data,
    required this.color,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: _SparklinePainter(
          data: data,
          color: color,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> data;
  final Color color;

  _SparklinePainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) return;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] / maxVal * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Fill area
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}

/// Statistics summary card
class StatsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final List<int>? sparklineData;

  const StatsSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    this.sparklineData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.2),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              if (sparklineData != null && sparklineData!.isNotEmpty)
                SizedBox(
                  width: 60,
                  height: 24,
                  child: SparklineChart(
                    data: sparklineData!,
                    color: color,
                    height: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
