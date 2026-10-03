import 'package:flutter/material.dart';
import '../models/workout_routine.dart';
import '../services/auth_service.dart';
import 'active_timer_screen.dart';

class CustomWorkoutScreen extends StatefulWidget {
  final WorkoutRoutine? initialRoutine;

  const CustomWorkoutScreen({super.key, this.initialRoutine});

  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  late String _routineId;
  bool _isEditingExistingCustom = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _descController;

  int _prepareSeconds = 10;
  int _workSeconds = 30;
  int _restSeconds = 15;
  int _sets = 8;
  int _cycles = 1;
  int _cycleRestSeconds = 60;
  int _cooldownSeconds = 0;
  Color _accentColor = const Color(0xFF00FFA3);
  String _tag = 'CUSTOM';

  final List<Color> _availableColors = const [
    Color(0xFF00FFA3), // Mint Neon
    Color(0xFF00B0FF), // Electric Blue
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF1744), // Crimson Red
    Color(0xFF7C4DFF), // Purple
    Color(0xFFFFD600), // Amber Gold
  ];

  final List<String> _tags = const ['HIIT', 'TABATA', 'BOXING', 'EMOM', 'CORE', 'CUSTOM'];

  @override
  void initState() {
    super.initState();
    final r = widget.initialRoutine;
    if (r != null) {
      final isCustom = AuthService().customRoutines.any((cr) => cr.id == r.id);
      _isEditingExistingCustom = isCustom;
      _routineId = isCustom ? r.id : 'custom_${DateTime.now().millisecondsSinceEpoch}';
      _nameController = TextEditingController(
        text: isCustom ? r.name : '${r.name} (Custom)',
      );
      _descController = TextEditingController(text: r.description);
      _prepareSeconds = r.prepareSeconds;
      _workSeconds = r.workSeconds;
      _restSeconds = r.restSeconds;
      _sets = r.sets;
      _cycles = r.cycles;
      _cycleRestSeconds = r.cycleRestSeconds;
      _cooldownSeconds = r.cooldownSeconds;
      _accentColor = r.accentColor;
      _tag = r.tag;
    } else {
      _routineId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      _nameController = TextEditingController(text: 'Custom Power Interval');
      _descController = TextEditingController(text: 'Tailored high-intensity workout session.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  WorkoutRoutine _buildRoutine() {
    return WorkoutRoutine(
      id: _routineId,
      name: _nameController.text.trim().isEmpty ? 'Custom Interval' : _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? 'Custom Interval routine' : _descController.text.trim(),
      prepareSeconds: _prepareSeconds,
      workSeconds: _workSeconds,
      restSeconds: _restSeconds,
      sets: _sets,
      cycles: _cycles,
      cycleRestSeconds: _cycleRestSeconds,
      cooldownSeconds: _cooldownSeconds,
      accentColor: _accentColor,
      tag: _tag,
    );
  }

  Future<void> _saveRoutine({bool startAfterSave = false}) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final routine = _buildRoutine();
      await AuthService().saveCustomRoutine(routine);

      if (!mounted) return;

      if (startAfterSave) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ActiveTimerScreen(routine: routine),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: _accentColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"${routine.name}" saved!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF141D2B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _accentColor.withValues(alpha: 0.35)),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save routine: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoutine = _buildRoutine();

    final screenTitle = widget.initialRoutine != null
        ? (_isEditingExistingCustom ? 'EDIT ROUTINE' : 'CUSTOMIZE TEMPLATE')
        : 'CREATE ROUTINE';

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D131F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          screenTitle,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: TextButton.icon(
                onPressed: _isSaving ? null : () => _saveRoutine(startAfterSave: false),
                icon: _isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00FFA3)),
                      )
                    : const Icon(Icons.check_rounded, color: Color(0xFF00FFA3), size: 18),
                label: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Color(0xFF00FFA3),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFA3).withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            children: [
              // Scrollable Options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  children: [
                    // Workout Name Input
                    _buildSectionTitle('ROUTINE NAME'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF121824),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2838)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2838)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _accentColor, width: 1.5),
                        ),
                        hintText: 'e.g. HIIT Abs & Cardio',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Workout Description Input
                    _buildSectionTitle('DESCRIPTION / FOCUS'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF121824),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2838)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1E2838)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _accentColor, width: 1.5),
                        ),
                        hintText: 'e.g. High intensity interval circuit targeting stamina and core strength',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Color & Tag selectors
                    _buildSectionTitle('TAG & ACCENT COLOR'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Tag Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121824),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E2838)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _tag,
                                dropdownColor: const Color(0xFF121824),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                items: _tags.map((t) {
                                  return DropdownMenuItem(value: t, child: Text(t));
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _tag = v);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Color picker dots
                        Row(
                          children: _availableColors.map((c) {
                            final isSelected = _accentColor.toARGB32() == c.toARGB32();
                            return GestureDetector(
                              onTap: () => setState(() => _accentColor = c),
                              child: Container(
                                margin: const EdgeInsets.only(left: 6),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: c.withValues(alpha: 0.6),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stepper: Work Duration
                    _buildStepper(
                      title: 'WORK DURATION',
                      subtitle: 'High intensity interval time',
                      icon: Icons.bolt,
                      iconColor: const Color(0xFF00FFA3),
                      value: _workSeconds,
                      unit: 'sec',
                      step: 5,
                      min: 5,
                      max: 300,
                      onChanged: (v) => setState(() => _workSeconds = v),
                    ),
                    const SizedBox(height: 12),

                    // Stepper: Rest Duration
                    _buildStepper(
                      title: 'REST DURATION',
                      subtitle: 'Active recovery between sets',
                      icon: Icons.self_improvement,
                      iconColor: const Color(0xFF00B0FF),
                      value: _restSeconds,
                      unit: 'sec',
                      step: 5,
                      min: 0,
                      max: 180,
                      onChanged: (v) => setState(() => _restSeconds = v),
                    ),
                    const SizedBox(height: 12),

                    // Stepper: Sets per Round
                    _buildStepper(
                      title: 'SETS PER ROUND',
                      subtitle: 'Number of work intervals in a cycle',
                      icon: Icons.repeat,
                      iconColor: Colors.white70,
                      value: _sets,
                      unit: 'sets',
                      step: 1,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setState(() => _sets = v),
                    ),
                    const SizedBox(height: 12),

                    // Stepper: Rounds / Cycles
                    _buildStepper(
                      title: 'ROUNDS / CYCLES',
                      subtitle: 'Repeats of the full set circuit',
                      icon: Icons.refresh,
                      iconColor: const Color(0xFF7C4DFF),
                      value: _cycles,
                      unit: 'rounds',
                      step: 1,
                      min: 1,
                      max: 10,
                      onChanged: (v) => setState(() => _cycles = v),
                    ),
                    const SizedBox(height: 12),

                    // Stepper: Round Rest (if rounds > 1)
                    if (_cycles > 1) ...[
                      _buildStepper(
                        title: 'REST BETWEEN ROUNDS',
                        subtitle: 'Longer break between circuits',
                        icon: Icons.hotel,
                        iconColor: const Color(0xFF7C4DFF),
                        value: _cycleRestSeconds,
                        unit: 'sec',
                        step: 5,
                        min: 10,
                        max: 300,
                        onChanged: (v) => setState(() => _cycleRestSeconds = v),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Stepper: Prepare Time
                    _buildStepper(
                      title: 'PREPARATION TIME',
                      subtitle: 'Countdown before first interval',
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFFFFB300),
                      value: _prepareSeconds,
                      unit: 'sec',
                      step: 5,
                      min: 5,
                      max: 60,
                      onChanged: (v) => setState(() => _prepareSeconds = v),
                    ),
                    const SizedBox(height: 12),

                    // Stepper: Cooldown Time
                    _buildStepper(
                      title: 'COOLDOWN TIME',
                      subtitle: 'Post-workout stretch & recovery',
                      icon: Icons.ac_unit_rounded,
                      iconColor: const Color(0xFF00E5FF),
                      value: _cooldownSeconds,
                      unit: 'sec',
                      step: 5,
                      min: 0,
                      max: 300,
                      onChanged: (v) => setState(() => _cooldownSeconds = v),
                    ),
                  ],
                ),
              ),

              // Bottom Action Dock: Duration, Save Routine & Save & Start
              Container(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D131F),
                  border: Border(top: BorderSide(color: Color(0xFF1E2838))),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total Duration Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL WORKOUT TIME',
                            style: TextStyle(
                              color: Color(0xFF8E9CAE),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              currentRoutine.formattedTotalDuration,
                              style: TextStyle(
                                color: _accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Two Action Buttons: Save Routine (without starting) & Save and Start
                      Row(
                        children: [
                          // 1. SAVE ROUTINE ONLY
                          Expanded(
                            flex: 5,
                            child: OutlinedButton.icon(
                              onPressed: _isSaving ? null : () => _saveRoutine(startAfterSave: false),
                              icon: const Icon(Icons.bookmark_outline_rounded, size: 20),
                              label: const Text(
                                'SAVE ROUTINE',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF273549),
                                  width: 1.5,
                                ),
                                backgroundColor: const Color(0xFF141D2B),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. SAVE & START WORKOUT
                          Expanded(
                            flex: 6,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : () => _saveRoutine(startAfterSave: true),
                              icon: const Icon(Icons.play_arrow_rounded, size: 22),
                              label: const Text(
                                'SAVE & START',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF8E9CAE),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStepper({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required int value,
    required String unit,
    required int step,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF121824),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2838)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8E9CAE),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Decrement
          IconButton(
            onPressed: value > min ? () => onChanged(value - step < min ? min : value - step) : null,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
          ),
          // Value
          SizedBox(
            width: 58,
            child: Text(
              '$value $unit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          // Increment
          IconButton(
            onPressed: value < max ? () => onChanged(value + step > max ? max : value + step) : null,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
