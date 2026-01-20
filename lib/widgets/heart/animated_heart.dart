import 'package:flutter/material.dart';
import '../../models/heart_stage_model.dart';

/// Animated beating heart widget that changes based on dhikr progress
class AnimatedHeart extends StatefulWidget {
  final HeartStageConfig stage;
  final double size;

  const AnimatedHeart({
    super.key,
    required this.stage,
    this.size = 120,
  });

  @override
  State<AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<AnimatedHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(AnimatedHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage.bpm != widget.stage.bpm) {
      _controller.duration = widget.stage.beatDuration;
      _scaleAnimation = _createScaleAnimation();
      _controller.reset();
      _controller.repeat();
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      duration: widget.stage.beatDuration,
      vsync: this,
    )..repeat();

    _scaleAnimation = _createScaleAnimation();
  }

  Animation<double> _createScaleAnimation() {
    return TweenSequence<double>([
      // Beat up
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.stage.beatScale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      // Beat down
      TweenSequenceItem(
        tween: Tween(begin: widget.stage.beatScale, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      // Small secondary beat
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.stage.beatScale * 0.5 + 0.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.stage.beatScale * 0.5 + 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      // Rest
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: widget.size * 1.5,
                  height: widget.size * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.stage.glowColor,
                        blurRadius: 30 * _scaleAnimation.value,
                        spreadRadius: 10 * _scaleAnimation.value,
                      ),
                    ],
                  ),
                ),
                // Heart icon
                Icon(
                  Icons.favorite,
                  size: widget.size,
                  color: widget.stage.heartColor,
                  shadows: [
                    Shadow(
                      color: widget.stage.heartColor.withValues(alpha: 0.8),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Mini version for app bar or small displays
class MiniAnimatedHeart extends StatefulWidget {
  final HeartStageConfig stage;
  final double size;

  const MiniAnimatedHeart({
    super.key,
    required this.stage,
    this.size = 24,
  });

  @override
  State<MiniAnimatedHeart> createState() => _MiniAnimatedHeartState();
}

class _MiniAnimatedHeartState extends State<MiniAnimatedHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.stage.beatDuration,
      vsync: this,
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(MiniAnimatedHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stage.bpm != widget.stage.bpm) {
      _controller.duration = widget.stage.beatDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.favorite,
            size: widget.size,
            color: widget.stage.heartColor,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
