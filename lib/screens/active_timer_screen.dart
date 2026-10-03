import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/workout_phase.dart';
import '../models/workout_routine.dart';
import '../services/ad_service.dart';
import '../services/auth_service.dart';
import '../services/timer_controller.dart';
import '../widgets/circular_timer_ring.dart';
import '../widgets/phase_header.dart';
import '../widgets/timer_controls.dart';
import 'workout_complete_screen.dart';

class ActiveTimerScreen extends StatefulWidget {
  final WorkoutRoutine routine;

  const ActiveTimerScreen({
    super.key,
    required this.routine,
  });

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  late TimerController _controller;
  bool _hasLoggedWorkout = false;

  @override
  void initState() {
    super.initState();
    _controller = TimerController(routine: widget.routine);
    AdService().loadInterstitialAd();
    // Auto-start workout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.start();
    });
  }

  void _recordSessionIfFinished() {
    if (_controller.isFinished && !_hasLoggedWorkout) {
      _hasLoggedWorkout = true;
      final totalSets = widget.routine.sets * widget.routine.cycles;
      final estimatedCalories = (_controller.totalElapsedSeconds / 60 * 11).round();

      AuthService().recordWorkoutLog(
        WorkoutLog(
          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
          routineId: widget.routine.id,
          routineName: widget.routine.name,
          durationSeconds: _controller.totalElapsedSeconds,
          setsCompleted: totalSets,
          caloriesBurned: estimatedCalories,
          completedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    if (_controller.isFinished || !_controller.isRunning) {
      return true;
    }

    _controller.pause();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Pause & Exit Workout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your active workout session will end. Are you sure you want to stop?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              _controller.resume();
            },
            child: const Text('RESUME', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('EXIT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isFinished) {
          _recordSessionIfFinished();

          return WorkoutCompleteScreen(
            routine: widget.routine,
            totalElapsedSeconds: _controller.totalElapsedSeconds,
            onRestart: () {
              setState(() {
                _hasLoggedWorkout = false;
              });
              _controller.reset();
              _controller.start();
            },
            onHome: () {
              Navigator.of(context).pop();
            },
          );
        }

        final currentPhase = _controller.currentPhase;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            final shouldPop = await _confirmExit();
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0C1017),
            body: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.1,
                  colors: [
                    currentPhase.darkGlowColor,
                    const Color(0xFF0C1017),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top App Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                                onPressed: () async {
                                  final shouldPop = await _confirmExit();
                                  if (shouldPop && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                tooltip: 'Exit Workout',
                              ),
                              Text(
                                widget.routine.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _controller.soundService.isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.soundService.toggleMute();
                                  });
                                },
                                tooltip: _controller.soundService.isMuted ? 'Unmute Sound' : 'Mute Sound',
                              ),
                            ],
                          ),

                          // Phase Header & Stats
                          PhaseHeader(
                            currentPhase: currentPhase,
                            currentCycle: _controller.currentCycle,
                            totalCycles: widget.routine.cycles,
                            formattedElapsed: _controller.formattedTotalElapsed,
                            formattedTotal: widget.routine.formattedTotalDuration,
                            overallProgress: _controller.overallProgress,
                            nextPhaseInfo: _controller.nextPhaseInfo,
                          ),

                          // Hero Circular Timer Ring
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularTimerRing(
                              progress: _controller.phaseProgress,
                              formattedTime: _controller.formattedPhaseTime,
                              currentPhase: currentPhase,
                              currentSet: _controller.currentSet,
                              totalSets: widget.routine.sets,
                              remainingSeconds: _controller.phaseRemainingSeconds,
                              totalSeconds: _controller.phaseTotalSeconds,
                              isPaused: _controller.isPaused,
                              isRunning: _controller.isRunning,
                            ),
                          ),

                          // Controls Deck
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: TimerControls(
                              isRunning: _controller.isRunning,
                              isPaused: _controller.isPaused,
                              currentPhase: currentPhase,
                              isMuted: _controller.soundService.isMuted,
                              onTogglePlayPause: _controller.togglePlayPause,
                              onSkipNext: _controller.skipNext,
                              onSkipPrevious: _controller.skipPrevious,
                              onReset: () {
                                _showResetConfirmation();
                              },
                              onToggleMute: () {
                                setState(() {
                                  _controller.soundService.toggleMute();
                                });
                              },
                              onAdjustTime: (delta) {
                                _controller.adjustTime(delta);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showResetConfirmation() {
    _controller.pause();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restart Routine?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('This will reset your workout to the beginning.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.resume();
            },
            child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.reset();
              _controller.start();
            },
            child: const Text('RESTART', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
