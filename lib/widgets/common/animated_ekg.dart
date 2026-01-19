import 'package:flutter/material.dart';

/// Animated EKG heartbeat widget that can be used throughout the app
class AnimatedEkg extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  final Duration beatDuration;
  final bool animate;

  const AnimatedEkg({
    super.key,
    this.width = 120,
    this.height = 60,
    this.color,
    this.beatDuration = const Duration(milliseconds: 1500),
    this.animate = true,
  });

  @override
  State<AnimatedEkg> createState() => _AnimatedEkgState();
}

class _AnimatedEkgState extends State<AnimatedEkg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.beatDuration,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedEkg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? const Color(0xFF2DD4BF) // lightTealColor
        : const Color(0xFF0D9488); // tealColor

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _AnimatedEkgPainter(
              color: widget.color ?? defaultColor,
              progress: _animation.value,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedEkgPainter extends CustomPainter {
  final Color color;
  final double progress;

  _AnimatedEkgPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Glow effect paint
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = _createEkgPath(size);

    // Calculate the portion of the path to draw based on progress
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;

    // Draw trail (fading effect)
    final trailLength = pathLength * 0.3; // Trail is 30% of total length
    final currentPosition = progress * pathLength;

    // Draw the glowing trail
    final trailStart = (currentPosition - trailLength).clamp(0.0, pathLength);
    final trailPath = pathMetrics.extractPath(trailStart, currentPosition);
    canvas.drawPath(trailPath, glowPaint);

    // Draw the main EKG line (full path with lower opacity)
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, bgPaint);

    // Draw the active portion with full opacity
    canvas.drawPath(trailPath, paint);

    // Draw a glowing dot at the current position
    final tangent = pathMetrics.getTangentForOffset(currentPosition);
    if (tangent != null) {
      // Pulse effect based on position (stronger at spike)
      final pulseIntensity = _getPulseIntensity(progress);

      // Outer glow
      canvas.drawCircle(
        tangent.position,
        4 + (pulseIntensity * 3),
        Paint()
          ..color = color.withValues(alpha: 0.3 * pulseIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Inner dot
      canvas.drawCircle(
        tangent.position,
        2.5 + (pulseIntensity * 1.5),
        Paint()..color = color,
      );
    }
  }

  Path _createEkgPath(Size size) {
    final path = Path();
    final centerY = size.height / 2;

    // EKG heartbeat pattern
    path.moveTo(0, centerY);
    path.lineTo(size.width * 0.2, centerY);
    path.lineTo(size.width * 0.25, centerY - 5);
    path.lineTo(size.width * 0.3, centerY);
    path.lineTo(size.width * 0.35, centerY);
    // Main spike (QRS complex)
    path.lineTo(size.width * 0.4, centerY + 8);
    path.lineTo(size.width * 0.45, centerY - size.height * 0.7);
    path.lineTo(size.width * 0.5, centerY + size.height * 0.3);
    path.lineTo(size.width * 0.55, centerY);
    // T wave
    path.lineTo(size.width * 0.65, centerY);
    path.lineTo(size.width * 0.7, centerY - 10);
    path.lineTo(size.width * 0.8, centerY);
    path.lineTo(size.width, centerY);

    return path;
  }

  double _getPulseIntensity(double progress) {
    // Spike is at around 45% of the path (the big peak)
    const spikePosition = 0.45;
    const spikeWidth = 0.15;

    final distance = (progress - spikePosition).abs();
    if (distance < spikeWidth) {
      return 1.0 - (distance / spikeWidth);
    }
    return 0.3; // Base intensity
  }

  @override
  bool shouldRepaint(covariant _AnimatedEkgPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Mini version of the animated EKG for app bar
class MiniAnimatedEkg extends StatefulWidget {
  final double width;
  final double height;
  final Color? color;
  final bool animate;

  const MiniAnimatedEkg({
    super.key,
    this.width = 32,
    this.height = 20,
    this.color,
    this.animate = true,
  });

  @override
  State<MiniAnimatedEkg> createState() => _MiniAnimatedEkgState();
}

class _MiniAnimatedEkgState extends State<MiniAnimatedEkg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MiniAnimatedEkg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? const Color(0xFF2DD4BF)
        : const Color(0xFF0D9488);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: _MiniAnimatedEkgPainter(
              color: widget.color ?? defaultColor,
              progress: _animation.value,
            ),
          ),
        );
      },
    );
  }
}

class _MiniAnimatedEkgPainter extends CustomPainter {
  final Color color;
  final double progress;

  _MiniAnimatedEkgPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createMiniEkgPath(size);

    // Background path with low opacity
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, bgPaint);

    // Animated portion
    final pathMetrics = path.computeMetrics().first;
    final pathLength = pathMetrics.length;
    final trailLength = pathLength * 0.4;
    final currentPosition = progress * pathLength;
    final trailStart = (currentPosition - trailLength).clamp(0.0, pathLength);

    final trailPath = pathMetrics.extractPath(trailStart, currentPosition);
    canvas.drawPath(trailPath, paint);

    // Glowing dot
    final tangent = pathMetrics.getTangentForOffset(currentPosition);
    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        2,
        Paint()..color = color,
      );
    }
  }

  Path _createMiniEkgPath(Size size) {
    final path = Path();
    final centerY = size.height / 2;

    path.moveTo(0, centerY);
    path.lineTo(size.width * 0.2, centerY);
    // Main spike
    path.lineTo(size.width * 0.35, centerY + 3);
    path.lineTo(size.width * 0.45, centerY - size.height * 0.6);
    path.lineTo(size.width * 0.55, centerY + size.height * 0.3);
    path.lineTo(size.width * 0.65, centerY);
    path.lineTo(size.width, centerY);

    return path;
  }

  @override
  bool shouldRepaint(covariant _MiniAnimatedEkgPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
