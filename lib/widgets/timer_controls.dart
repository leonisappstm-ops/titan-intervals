import 'package:flutter/material.dart';
import '../models/workout_phase.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final WorkoutPhase currentPhase;
  final bool isMuted;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onSkipNext;
  final VoidCallback onSkipPrevious;
  final VoidCallback onReset;
  final VoidCallback onToggleMute;
  final Function(int) onAdjustTime;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.currentPhase,
    required this.isMuted,
    required this.onTogglePlayPause,
    required this.onSkipNext,
    required this.onSkipPrevious,
    required this.onReset,
    required this.onToggleMute,
    required this.onAdjustTime,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = currentPhase.primaryColor;
    final isPlaying = isRunning && !isPaused;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick +/- 10s Adjust buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAdjustButton('-10s', () => onAdjustTime(-10)),
            const SizedBox(width: 16),
            _buildAdjustButton('+10s', () => onAdjustTime(10)),
          ],
        ),
        const SizedBox(height: 20),

        // Primary Control Deck
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sound Mute Toggle
            IconButton(
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: isMuted ? Colors.white38 : Colors.white70,
              ),
              onPressed: onToggleMute,
              tooltip: isMuted ? 'Unmute Sound' : 'Mute Sound',
            ),
            const SizedBox(width: 10),

            // Previous / Rewind Set
            _buildCircleIconButton(
              icon: Icons.replay_10_rounded,
              tooltip: 'Rewind Interval',
              onPressed: onSkipPrevious,
              size: 50,
              backgroundColor: const Color(0xFF1E2536),
              iconColor: Colors.white,
            ),
            const SizedBox(width: 12),

            // Giant Play / Pause Button
            GestureDetector(
              onTap: onTogglePlayPause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: isPlaying ? 0.6 : 0.3),
                      blurRadius: isPlaying ? 24 : 12,
                      spreadRadius: isPlaying ? 3 : 1,
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 44,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Next / Skip Set
            _buildCircleIconButton(
              icon: Icons.forward_10_rounded,
              tooltip: 'Skip to Next Interval',
              onPressed: onSkipNext,
              size: 50,
              backgroundColor: const Color(0xFF1E2536),
              iconColor: Colors.white,
            ),
            const SizedBox(width: 10),

            // Reset / Stop Button
            IconButton(
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              onPressed: onReset,
              tooltip: 'Reset Workout',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdjustButton(String label, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2536),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required double size,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
      ),
    );
  }
}
