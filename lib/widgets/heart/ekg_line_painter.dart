import 'package:flutter/material.dart';

/// Custom painter that draws an animated EKG/ECG heartbeat line
class EKGLinePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final int bpm;
  final double animationValue; // 0.0 to 1.0 for scrolling effect

  EKGLinePainter({
    required this.color,
    required this.amplitude,
    required this.bpm,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = _createEKGPath(size);

    // Draw glow first
    canvas.drawPath(path, glowPaint);
    // Draw main line
    canvas.drawPath(path, paint);
  }

  Path _createEKGPath(Size size) {
    final path = Path();
    const segments = 3;
    final segmentWidth = size.width / segments;
    final centerY = size.height / 2;
    final amp = amplitude.clamp(10.0, 40.0);

    // Offset for animation scrolling effect
    final offset = animationValue * segmentWidth;

    path.moveTo(-offset, centerY);

    for (int i = 0; i <= segments; i++) {
      final baseX = i * segmentWidth - offset;

      // Flat line start
      path.lineTo(baseX + segmentWidth * 0.3, centerY);

      // P wave (small bump before QRS)
      path.quadraticBezierTo(
        baseX + segmentWidth * 0.35,
        centerY - amp * 0.25,
        baseX + segmentWidth * 0.4,
        centerY,
      );

      // Flat before QRS
      path.lineTo(baseX + segmentWidth * 0.45, centerY);

      // QRS complex (the main spike)
      // Q wave (small dip)
      path.lineTo(baseX + segmentWidth * 0.48, centerY);
      path.lineTo(baseX + segmentWidth * 0.49, centerY + amp * 0.2);

      // R wave (big spike up)
      path.lineTo(baseX + segmentWidth * 0.52, centerY - amp);

      // S wave (dip below baseline)
      path.lineTo(baseX + segmentWidth * 0.55, centerY + amp * 0.3);
      path.lineTo(baseX + segmentWidth * 0.57, centerY);

      // Flat after QRS (ST segment)
      path.lineTo(baseX + segmentWidth * 0.62, centerY);

      // T wave (recovery bump)
      path.quadraticBezierTo(
        baseX + segmentWidth * 0.68,
        centerY - amp * 0.4,
        baseX + segmentWidth * 0.75,
        centerY,
      );

      // Flat to end (baseline)
      path.lineTo(baseX + segmentWidth, centerY);
    }

    return path;
  }

  @override
  bool shouldRepaint(EKGLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.bpm != bpm ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Widget that wraps the EKG painter with animation
class AnimatedEKGLine extends StatefulWidget {
  final Color color;
  final int bpm;
  final double height;

  const AnimatedEKGLine({
    super.key,
    required this.color,
    required this.bpm,
    this.height = 100,
  });

  @override
  State<AnimatedEKGLine> createState() => _AnimatedEKGLineState();
}

class _AnimatedEKGLineState extends State<AnimatedEKGLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (60000 / widget.bpm).round()),
      vsync: this,
    )..repeat();
  }

  @override
  void didUpdateWidget(AnimatedEKGLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _controller.duration = Duration(milliseconds: (60000 / widget.bpm).round());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: EKGLinePainter(
              color: widget.color,
              amplitude: widget.bpm / 3,
              bpm: widget.bpm,
              animationValue: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Static EKG line (no animation) for use in cards/thumbnails
class StaticEKGLine extends StatelessWidget {
  final Color color;
  final int bpm;
  final double height;

  const StaticEKGLine({
    super.key,
    required this.color,
    required this.bpm,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: EKGLinePainter(
          color: color,
          amplitude: bpm / 3,
          bpm: bpm,
          animationValue: 0,
        ),
        size: Size.infinite,
      ),
    );
  }
}
