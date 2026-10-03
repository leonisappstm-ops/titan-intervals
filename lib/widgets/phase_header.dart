import 'package:flutter/material.dart';
import '../models/workout_phase.dart';

class PhaseHeader extends StatelessWidget {
  final WorkoutPhase currentPhase;
  final int currentCycle;
  final int totalCycles;
  final String formattedElapsed;
  final String formattedTotal;
  final double overallProgress;
  final ({WorkoutPhase phase, int seconds, String label}) nextPhaseInfo;

  const PhaseHeader({
    super.key,
    required this.currentPhase,
    required this.currentCycle,
    required this.totalCycles,
    required this.formattedElapsed,
    required this.formattedTotal,
    required this.overallProgress,
    required this.nextPhaseInfo,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = currentPhase.primaryColor;

    return Column(
      children: [
        // Top stats bar: Round & Total Workout Elapsed
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Round Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2536),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    'ROUND $currentCycle OF $totalCycles',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            // Elapsed / Total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2536),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    '$formattedElapsed / $formattedTotal',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Overall workout progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: const Color(0xFF1E2536),
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),

        // Motivational Subtitle
        Text(
          currentPhase.motivationalSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 14),

        // "Up Next" preview card
        if (currentPhase != WorkoutPhase.completed)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF181E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'UP NEXT: ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: nextPhaseInfo.phase.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  nextPhaseInfo.label.toUpperCase(),
                  style: TextStyle(
                    color: nextPhaseInfo.phase.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (nextPhaseInfo.seconds > 0) ...[
                  const SizedBox(width: 6),
                  Text(
                    '(${nextPhaseInfo.seconds}s)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
