import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/workout_phase.dart';

class CircularTimerRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0 (fallback progress)
  final String formattedTime;
  final WorkoutPhase currentPhase;
  final int currentSet;
  final int totalSets;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isPaused;
  final bool isRunning;

  const CircularTimerRing({
    super.key,
    required this.progress,
    required this.formattedTime,
    required this.currentPhase,
    required this.currentSet,
    required this.totalSets,
    required this.remainingSeconds,
    this.totalSeconds = 0,
    this.isPaused = false,
    this.isRunning = true,
  });

  @override
  State<CircularTimerRing> createState() => _CircularTimerRingState();
}

class _CircularTimerRingState extends State<CircularTimerRing> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  WorkoutPhase? _lastPhase;
  int? _lastSet;
  int? _lastRemainingSeconds;
  double _lastTarget = 0.0;

  double _calculateTargetProgress() {
    if (widget.currentPhase == WorkoutPhase.completed) {
      return 1.0;
    }
    final total = widget.totalSeconds > 0 ? widget.totalSeconds : 1;
    final remaining = widget.remainingSeconds;

    if (remaining <= 0) return 1.0;

    // Elapsed seconds completed prior to this current 1-second interval
    final elapsed = (total - remaining).clamp(0, total);

    // Target to achieve by the end of this 1-second tick:
    // e.g. when remaining == total (start of phase), target = 1 / total
    // when remaining == 1 (last second of phase), target = (total - 1 + 1) / total = 1.0 (full 360°)
    final target = (elapsed + 1) / total;
    return target.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _lastPhase = widget.currentPhase;
    _lastSet = widget.currentSet;
    _lastRemainingSeconds = widget.remainingSeconds;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    final initialTarget = _calculateTargetProgress();
    _lastTarget = initialTarget;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: initialTarget,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.linear));

    if (widget.isRunning && !widget.isPaused) {
      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CircularTimerRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle pause / resume
    if (widget.isPaused && !oldWidget.isPaused) {
      _progressController.stop();
    } else if (!widget.isPaused && oldWidget.isPaused && widget.isRunning) {
      _progressController.forward();
    }

    final phaseChanged = widget.currentPhase != _lastPhase;
    final setChanged = widget.currentSet != _lastSet;
    final remainingChanged = widget.remainingSeconds != _lastRemainingSeconds;

    if (phaseChanged || setChanged) {
      // Brand new phase or set: start fresh from 0.0
      _lastPhase = widget.currentPhase;
      _lastSet = widget.currentSet;
      _lastRemainingSeconds = widget.remainingSeconds;

      _progressController.stop();
      _progressController.reset();

      final newTarget = _calculateTargetProgress();
      _lastTarget = newTarget;

      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: newTarget,
      ).animate(CurvedAnimation(parent: _progressController, curve: Curves.linear));

      if (widget.isRunning && !widget.isPaused) {
        _progressController.forward();
      }
    } else if (remainingChanged) {
      _lastRemainingSeconds = widget.remainingSeconds;
      final newTarget = _calculateTargetProgress();
      final currentAnimatedValue = _progressAnimation.value;

      final total = widget.totalSeconds > 0 ? widget.totalSeconds : 1;
      final isBigJump = (newTarget - _lastTarget).abs() > (1.5 / total);

      _progressController.stop();
      _progressController.reset();

      final startVal = isBigJump
          ? ((total - widget.remainingSeconds).clamp(0, total) / total)
          : currentAnimatedValue;

      _lastTarget = newTarget;

      _progressAnimation = Tween<double>(
        begin: startVal,
        end: newTarget,
      ).animate(CurvedAnimation(parent: _progressController, curve: Curves.linear));

      if (widget.isRunning && !widget.isPaused) {
        _progressController.forward();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgentCountdown = widget.remainingSeconds <= 3 && widget.remainingSeconds > 0;
    final primaryColor = widget.currentPhase.primaryColor;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _progressAnimation]),
      builder: (context, child) {
        final scale = isUrgentCountdown ? _pulseAnimation.value : 1.0;
        final animatedProgress = _progressAnimation.value;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Custom painted neon smooth progress ring
                CustomPaint(
                  size: const Size(290, 290),
                  painter: _TimerRingPainter(
                    progress: animatedProgress,
                    color: primaryColor,
                    isUrgent: isUrgentCountdown,
                  ),
                ),

                // Center Content: Time & Phase
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Phase Name Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.5), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.currentPhase.icon, size: 16, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            widget.currentPhase.displayName,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Giant Countdown Digits
                    Text(
                      widget.formattedTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 66,
                        fontWeight: FontWeight.w900,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.7),
                            blurRadius: isUrgentCountdown ? 24 : 12,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Set counter
                    if (widget.currentPhase != WorkoutPhase.completed)
                      Text(
                        'SET ${widget.currentSet} OF ${widget.totalSets}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
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
}

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isUrgent;

  _TimerRingPainter({
    required this.progress,
    required this.color,
    required this.isUrgent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const strokeWidth = 14.0;

    // Track Paint (Dark Ring Background)
    final trackPaint = Paint()
      ..color = const Color(0xFF161F2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // Glowing Neon Active Arc
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    if (isUrgent) {
      activePaint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);
    }

    const startAngle = -math.pi / 2;
    final clampedProgress = progress.clamp(0.0, 1.0);

    if (clampedProgress >= 0.999) {
      // 100% Full Complete 360-degree circle
      canvas.drawCircle(center, radius, activePaint);
    } else {
      final sweepAngle = 2 * math.pi * clampedProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );

      // Glowing bead at the tip of the moving arc for fluid motion
      if (clampedProgress > 0.005 && clampedProgress < 0.998) {
        final currentAngle = startAngle + sweepAngle;
        final headX = center.dx + radius * math.cos(currentAngle);
        final headY = center.dy + radius * math.sin(currentAngle);
        final tipCenter = Offset(headX, headY);

        // Outer soft glow
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(tipCenter, strokeWidth / 2 + 1, glowPaint);

        // Bright white accent bead
        final innerDotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(tipCenter, strokeWidth / 3.5, innerDotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isUrgent != isUrgent;
  }
}
