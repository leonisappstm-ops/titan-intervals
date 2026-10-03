import 'package:flutter/material.dart';

enum WorkoutPhase {
  prepare,
  work,
  rest,
  cycleRest,
  cooldown,
  completed,
}

extension WorkoutPhaseExtension on WorkoutPhase {
  String get displayName {
    switch (this) {
      case WorkoutPhase.prepare:
        return 'GET READY';
      case WorkoutPhase.work:
        return 'WORK';
      case WorkoutPhase.rest:
        return 'REST';
      case WorkoutPhase.cycleRest:
        return 'ROUND REST';
      case WorkoutPhase.cooldown:
        return 'COOL DOWN';
      case WorkoutPhase.completed:
        return 'FINISHED';
    }
  }

  String get motivationalSubtitle {
    switch (this) {
      case WorkoutPhase.prepare:
        return 'Get in position & focus';
      case WorkoutPhase.work:
        return 'Push your limits! Full intensity!';
      case WorkoutPhase.rest:
        return 'Catch your breath & recover';
      case WorkoutPhase.cycleRest:
        return 'Deep breaths. Next round is coming';
      case WorkoutPhase.cooldown:
        return 'Lower your heart rate';
      case WorkoutPhase.completed:
        return 'Incredible effort! You crushed it!';
    }
  }

  Color get primaryColor {
    switch (this) {
      case WorkoutPhase.prepare:
        return const Color(0xFFFFB300); // Amber
      case WorkoutPhase.work:
        return const Color(0xFF00E676); // Neon Green
      case WorkoutPhase.rest:
        return const Color(0xFF00B0FF); // Electric Cyan
      case WorkoutPhase.cycleRest:
        return const Color(0xFF7C4DFF); // Deep Violet
      case WorkoutPhase.cooldown:
        return const Color(0xFF00BFA5); // Teal
      case WorkoutPhase.completed:
        return const Color(0xFFFFD700); // Gold
    }
  }

  Color get darkGlowColor {
    switch (this) {
      case WorkoutPhase.prepare:
        return const Color(0x33FFB300);
      case WorkoutPhase.work:
        return const Color(0x3300E676);
      case WorkoutPhase.rest:
        return const Color(0x3300B0FF);
      case WorkoutPhase.cycleRest:
        return const Color(0x337C4DFF);
      case WorkoutPhase.cooldown:
        return const Color(0x3300BFA5);
      case WorkoutPhase.completed:
        return const Color(0x33FFD700);
    }
  }

  IconData get icon {
    switch (this) {
      case WorkoutPhase.prepare:
        return Icons.timer_outlined;
      case WorkoutPhase.work:
        return Icons.bolt;
      case WorkoutPhase.rest:
        return Icons.self_improvement;
      case WorkoutPhase.cycleRest:
        return Icons.hotel;
      case WorkoutPhase.cooldown:
        return Icons.ac_unit;
      case WorkoutPhase.completed:
        return Icons.emoji_events;
    }
  }
}
