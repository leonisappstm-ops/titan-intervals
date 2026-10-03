import 'workout_routine.dart';

class WorkoutLog {
  final String id;
  final String routineId;
  final String routineName;
  final int durationSeconds;
  final int setsCompleted;
  final int caloriesBurned;
  final DateTime completedAt;

  const WorkoutLog({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.durationSeconds,
    required this.setsCompleted,
    required this.caloriesBurned,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'routineId': routineId,
        'routineName': routineName,
        'durationSeconds': durationSeconds,
        'setsCompleted': setsCompleted,
        'caloriesBurned': caloriesBurned,
        'completedAt': completedAt.toIso8601String(),
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String,
        routineId: json['routineId'] as String? ?? 'custom',
        routineName: json['routineName'] as String? ?? 'Workout',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        setsCompleted: json['setsCompleted'] as int? ?? 0,
        caloriesBurned: json['caloriesBurned'] as int? ?? 0,
        completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ?? DateTime.now(),
      );

  String get formattedDuration {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    if (mins == 0) return '${secs}s';
    return '${mins}m ${secs}s';
  }
}

class UserAccount {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String authProvider; // 'google', 'facebook', 'instagram', 'email', 'guest'
  final DateTime createdAt;
  final List<WorkoutRoutine> customRoutines;
  final List<WorkoutLog> workoutHistory;

  const UserAccount({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.authProvider,
    required this.createdAt,
    this.customRoutines = const [],
    this.workoutHistory = const [],
  });

  int get totalWorkoutsCompleted => workoutHistory.length;

  int get totalActiveMinutes {
    final totalSecs = workoutHistory.fold<int>(0, (sum, log) => sum + log.durationSeconds);
    return totalSecs ~/ 60;
  }

  int get totalCaloriesBurned {
    return workoutHistory.fold<int>(0, (sum, log) => sum + log.caloriesBurned);
  }

  UserAccount copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? authProvider,
    DateTime? createdAt,
    List<WorkoutRoutine>? customRoutines,
    List<WorkoutLog>? workoutHistory,
  }) {
    return UserAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      customRoutines: customRoutines ?? this.customRoutines,
      workoutHistory: workoutHistory ?? this.workoutHistory,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'authProvider': authProvider,
        'createdAt': createdAt.toIso8601String(),
        'customRoutines': customRoutines.map((r) => r.toJson()).toList(),
        'workoutHistory': workoutHistory.map((l) => l.toJson()).toList(),
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Athlete',
      photoUrl: json['photoUrl'] as String?,
      authProvider: json['authProvider'] as String? ?? 'email',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      customRoutines: (json['customRoutines'] as List<dynamic>?)
              ?.map((r) => WorkoutRoutine.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      workoutHistory: (json['workoutHistory'] as List<dynamic>?)
              ?.map((l) => WorkoutLog.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
