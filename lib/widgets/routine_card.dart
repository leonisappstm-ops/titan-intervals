import 'package:flutter/material.dart';
import '../models/workout_routine.dart';
import '../services/settings_service.dart';

class RoutineCard extends StatelessWidget {
  final WorkoutRoutine routine;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onStart,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SettingsService().currentTheme;
    final isGreen = routine.tag == 'TABATA' || routine.accentColor == const Color(0xFF00FFA3) || routine.accentColor == const Color(0xFF00E676);
    final isOrange = routine.tag == 'HIIT' || routine.accentColor == const Color(0xFFFF5722);

    final Color buttonColor = isGreen
        ? theme.primary
        : (isOrange ? const Color(0xFFFF5722) : routine.accentColor);

    final Color buttonTextColor = isGreen ? theme.onPrimary : Colors.white;

    final Color tagBg = isGreen
        ? theme.primary.withValues(alpha: 0.15)
        : (isOrange ? const Color(0xFF2E170E) : routine.accentColor.withValues(alpha: 0.15));
    final Color tagBorder = isGreen
        ? theme.primary.withValues(alpha: 0.35)
        : (isOrange ? const Color(0xFF4A2314) : routine.accentColor.withValues(alpha: 0.35));
    final Color tagText = isGreen
        ? theme.primary
        : (isOrange ? const Color(0xFFFF5722) : routine.accentColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onStart,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Tag, Duration Pill, and Edit icon
                Row(
                  children: [
                    // Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tagBorder),
                      ),
                      child: Text(
                        routine.tag,
                        style: TextStyle(
                          color: tagText,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Duration Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF182232),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF223044)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF8D9AA8)),
                          const SizedBox(width: 5),
                          Text(
                            routine.formattedTotalDuration,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Edit button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onEdit,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.tune_rounded, size: 20, color: Color(0xFF8D9AA8)),
                        ),
                      ),
                    ),

                    if (onDelete != null) ...[
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Routine Title
                Text(
                  routine.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  routine.description,
                  style: const TextStyle(
                    color: Color(0xFF8E9CAE),
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // Breakdown pills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMetricPill(
                      icon: Icons.bolt_rounded,
                      text: '${routine.workSeconds}s WORK',
                      iconColor: const Color(0xFF00FFA3),
                      textColor: const Color(0xFF00FFA3),
                      bgColor: const Color(0xFF0B2322),
                      borderColor: const Color(0xFF10473E),
                    ),
                    _buildMetricPill(
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      text: '${routine.restSeconds}s REST',
                      iconColor: const Color(0xFF00D2FF),
                      textColor: const Color(0xFF00D2FF),
                      bgColor: const Color(0xFF0C2533),
                      borderColor: const Color(0xFF134055),
                    ),
                    _buildMetricPill(
                      icon: Icons.sync_rounded,
                      text: '${routine.sets} SETS',
                      iconColor: const Color(0xFF8E9CAE),
                      textColor: const Color(0xFFCBD5E1),
                      bgColor: const Color(0xFF182232),
                      borderColor: const Color(0xFF233246),
                    ),
                    if (routine.cycles > 1)
                      _buildMetricPill(
                        icon: Icons.sync_rounded,
                        text: '${routine.cycles} ROUNDS',
                        iconColor: const Color(0xFFC084FC),
                        textColor: const Color(0xFFC084FC),
                        bgColor: const Color(0xFF221636),
                        borderColor: const Color(0xFF3E2368),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Start Workout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 22, color: buttonTextColor),
                        const SizedBox(width: 8),
                        Text(
                          'START ROUTINE',
                          style: TextStyle(
                            color: buttonTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
