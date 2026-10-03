import 'package:flutter/material.dart';

class WorkoutRoutine {
  final String id;
  final String name;
  final String description;
  final int prepareSeconds;
  final int workSeconds;
  final int restSeconds;
  final int sets;
  final int cycles;
  final int cycleRestSeconds;
  final int cooldownSeconds;
  final Color accentColor;
  final String tag;

  const WorkoutRoutine({
    required this.id,
    required this.name,
    required this.description,
    this.prepareSeconds = 10,
    required this.workSeconds,
    required this.restSeconds,
    required this.sets,
    this.cycles = 1,
    this.cycleRestSeconds = 60,
    this.cooldownSeconds = 0,
    this.accentColor = const Color(0xFF00E676),
    this.tag = 'HIIT',
  });

  /// Calculates total active workout duration in seconds
  int get totalDurationSeconds {
    if (sets <= 0 || cycles <= 0) return 0;
    
    // Per round duration:
    // (sets * work) + ((sets - 1) * rest)
    final roundActive = (sets * workSeconds) + ((sets > 1 ? sets - 1 : 0) * restSeconds);
    
    // Total for all rounds + cycle breaks in between
    final allRounds = (roundActive * cycles) + ((cycles > 1 ? cycles - 1 : 0) * cycleRestSeconds);
    
    return prepareSeconds + allRounds + cooldownSeconds;
  }

  String get formattedTotalDuration {
    final total = totalDurationSeconds;
    final mins = total ~/ 60;
    final secs = total % 60;
    if (mins == 0) return '${secs}s';
    if (secs == 0) return '${mins}m';
    return '${mins}m ${secs}s';
  }

  WorkoutRoutine copyWith({
    String? id,
    String? name,
    String? description,
    int? prepareSeconds,
    int? workSeconds,
    int? restSeconds,
    int? sets,
    int? cycles,
    int? cycleRestSeconds,
    int? cooldownSeconds,
    Color? accentColor,
    String? tag,
  }) {
    return WorkoutRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      prepareSeconds: prepareSeconds ?? this.prepareSeconds,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      sets: sets ?? this.sets,
      cycles: cycles ?? this.cycles,
      cycleRestSeconds: cycleRestSeconds ?? this.cycleRestSeconds,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      accentColor: accentColor ?? this.accentColor,
      tag: tag ?? this.tag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'prepareSeconds': prepareSeconds,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'sets': sets,
      'cycles': cycles,
      'cycleRestSeconds': cycleRestSeconds,
      'cooldownSeconds': cooldownSeconds,
      'accentColor': accentColor.toARGB32(),
      'tag': tag,
    };
  }

  factory WorkoutRoutine.fromJson(Map<String, dynamic> json) {
    return WorkoutRoutine(
      id: json['id'] as String? ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Custom Routine',
      description: json['description'] as String? ?? '',
      prepareSeconds: json['prepareSeconds'] as int? ?? 10,
      workSeconds: json['workSeconds'] as int? ?? 30,
      restSeconds: json['restSeconds'] as int? ?? 15,
      sets: json['sets'] as int? ?? 8,
      cycles: json['cycles'] as int? ?? 1,
      cycleRestSeconds: json['cycleRestSeconds'] as int? ?? 60,
      cooldownSeconds: json['cooldownSeconds'] as int? ?? 0,
      accentColor: Color(json['accentColor'] as int? ?? 0xFF00E676),
      tag: json['tag'] as String? ?? 'CUSTOM',
    );
  }

  static List<WorkoutRoutine> get presets => [
        const WorkoutRoutine(
          id: 'tabata',
          name: 'Classic Tabata',
          description: 'High intensity 20s sprint followed by 10s rest. 8 brutal sets to maximum VO2.',
          prepareSeconds: 10,
          workSeconds: 20,
          restSeconds: 10,
          sets: 8,
          cycles: 1,
          cycleRestSeconds: 60,
          cooldownSeconds: 0,
          accentColor: Color(0xFF00FFA3),
          tag: 'TABATA',
        ),
        const WorkoutRoutine(
          id: 'hiit_blast',
          name: 'HIIT Full Body Blast',
          description: '40s work intervals paired with 20s recovery across 2 intensive rounds.',
          prepareSeconds: 10,
          workSeconds: 40,
          restSeconds: 20,
          sets: 6,
          cycles: 2,
          cycleRestSeconds: 60,
          cooldownSeconds: 30,
          accentColor: Color(0xFFFF5722),
          tag: 'HIIT',
        ),
        const WorkoutRoutine(
          id: 'boxing_rounds',
          name: 'Championship Boxing',
          description: 'Authentic 3-minute championship rounds with 1-minute corner rest.',
          prepareSeconds: 15,
          workSeconds: 180,
          restSeconds: 60,
          sets: 5,
          cycles: 1,
          cycleRestSeconds: 60,
          cooldownSeconds: 60,
          accentColor: Color(0xFFFF1744),
          tag: 'BOXING',
        ),
        const WorkoutRoutine(
          id: 'emom_10',
          name: 'EMOM 10-Minute Engine',
          description: 'Every Minute On the Minute. 50s work, 10s transition over 10 consecutive sets.',
          prepareSeconds: 10,
          workSeconds: 50,
          restSeconds: 10,
          sets: 10,
          cycles: 1,
          cycleRestSeconds: 0,
          cooldownSeconds: 0,
          accentColor: Color(0xFF00B0FF),
          tag: 'EMOM',
        ),
        const WorkoutRoutine(
          id: 'core_crusher',
          name: 'Abs & Core Inferno',
          description: 'Focused 30s tension sets with quick 15s recovery for sculpted abs.',
          prepareSeconds: 10,
          workSeconds: 30,
          restSeconds: 15,
          sets: 8,
          cycles: 1,
          cycleRestSeconds: 45,
          cooldownSeconds: 15,
          accentColor: Color(0xFFFFD600),
          tag: 'CORE',
        ),
      ];
}
