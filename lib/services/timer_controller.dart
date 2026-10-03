import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_phase.dart';
import '../models/workout_routine.dart';
import 'sound_service.dart';

class TimerController extends ChangeNotifier {
  WorkoutRoutine routine;
  final SoundService soundService = SoundService();

  WorkoutPhase _currentPhase = WorkoutPhase.prepare;
  int _currentSet = 1;
  int _currentCycle = 1;

  int _phaseRemainingSeconds = 0;
  int _phaseTotalSeconds = 0;
  int _totalElapsedSeconds = 0;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isFinished = false;

  Timer? _ticker;

  TimerController({required this.routine}) {
    _initTimer();
  }

  WorkoutPhase get currentPhase => _currentPhase;
  int get currentSet => _currentSet;
  int get currentCycle => _currentCycle;
  int get phaseRemainingSeconds => _phaseRemainingSeconds;
  int get phaseTotalSeconds => _phaseTotalSeconds;
  int get totalElapsedSeconds => _totalElapsedSeconds;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get isFinished => _isFinished;

  double get phaseProgress {
    if (_phaseTotalSeconds <= 0) return 0.0;
    final progress = (_phaseTotalSeconds - _phaseRemainingSeconds) / _phaseTotalSeconds;
    return progress.clamp(0.0, 1.0);
  }

  double get overallProgress {
    final total = routine.totalDurationSeconds;
    if (total <= 0) return 0.0;
    return (_totalElapsedSeconds / total).clamp(0.0, 1.0);
  }

  String get formattedPhaseTime {
    final mins = _phaseRemainingSeconds ~/ 60;
    final secs = _phaseRemainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get formattedTotalElapsed {
    final mins = _totalElapsedSeconds ~/ 60;
    final secs = _totalElapsedSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _initTimer() {
    _currentCycle = 1;
    _currentSet = 1;
    _totalElapsedSeconds = 0;
    _isFinished = false;

    if (routine.prepareSeconds > 0) {
      _currentPhase = WorkoutPhase.prepare;
      _phaseTotalSeconds = routine.prepareSeconds;
      _phaseRemainingSeconds = routine.prepareSeconds;
    } else {
      _currentPhase = WorkoutPhase.work;
      _phaseTotalSeconds = routine.workSeconds;
      _phaseRemainingSeconds = routine.workSeconds;
    }
  }

  void start() {
    if (_isFinished) {
      _initTimer();
    }
    _isRunning = true;
    _isPaused = false;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (!_isRunning || !_isPaused) return;
    _isPaused = false;
    _startTicker();
    notifyListeners();
  }

  void togglePlayPause() {
    if (!_isRunning) {
      start();
    } else if (_isPaused) {
      resume();
    } else {
      pause();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (_isPaused || !_isRunning || _isFinished) return;

    _totalElapsedSeconds++;

    if (_phaseRemainingSeconds > 1) {
      _phaseRemainingSeconds--;
      if (_phaseRemainingSeconds <= 3 && _phaseRemainingSeconds >= 1) {
        soundService.playCountdownBeep(_phaseRemainingSeconds);
      }
      notifyListeners();
    } else {
      // Transitioning phase
      _advancePhase();
    }
  }

  void _advancePhase() {
    switch (_currentPhase) {
      case WorkoutPhase.prepare:
        _currentPhase = WorkoutPhase.work;
        _phaseTotalSeconds = routine.workSeconds;
        _phaseRemainingSeconds = routine.workSeconds;
        soundService.playWorkStart();
        break;

      case WorkoutPhase.work:
        if (_currentSet < routine.sets) {
          if (routine.restSeconds > 0) {
            _currentPhase = WorkoutPhase.rest;
            _phaseTotalSeconds = routine.restSeconds;
            _phaseRemainingSeconds = routine.restSeconds;
            soundService.playRestStart();
          } else {
            _currentSet++;
            _phaseTotalSeconds = routine.workSeconds;
            _phaseRemainingSeconds = routine.workSeconds;
            soundService.playWorkStart();
          }
        } else {
          // Finished all sets in this cycle
          if (_currentCycle < routine.cycles) {
            if (routine.cycleRestSeconds > 0) {
              _currentPhase = WorkoutPhase.cycleRest;
              _phaseTotalSeconds = routine.cycleRestSeconds;
              _phaseRemainingSeconds = routine.cycleRestSeconds;
              soundService.playCycleRestStart();
            } else {
              _currentCycle++;
              _currentSet = 1;
              _currentPhase = WorkoutPhase.work;
              _phaseTotalSeconds = routine.workSeconds;
              _phaseRemainingSeconds = routine.workSeconds;
              soundService.playWorkStart();
            }
          } else {
            // All cycles complete
            if (routine.cooldownSeconds > 0) {
              _currentPhase = WorkoutPhase.cooldown;
              _phaseTotalSeconds = routine.cooldownSeconds;
              _phaseRemainingSeconds = routine.cooldownSeconds;
              soundService.playRestStart();
            } else {
              _completeWorkout();
              return;
            }
          }
        }
        break;

      case WorkoutPhase.rest:
        _currentSet++;
        _currentPhase = WorkoutPhase.work;
        _phaseTotalSeconds = routine.workSeconds;
        _phaseRemainingSeconds = routine.workSeconds;
        soundService.playWorkStart();
        break;

      case WorkoutPhase.cycleRest:
        _currentCycle++;
        _currentSet = 1;
        _currentPhase = WorkoutPhase.work;
        _phaseTotalSeconds = routine.workSeconds;
        _phaseRemainingSeconds = routine.workSeconds;
        soundService.playWorkStart();
        break;

      case WorkoutPhase.cooldown:
        _completeWorkout();
        return;

      case WorkoutPhase.completed:
        return;
    }

    notifyListeners();
  }

  void _completeWorkout() {
    _currentPhase = WorkoutPhase.completed;
    _phaseRemainingSeconds = 0;
    _isFinished = true;
    _isRunning = false;
    _ticker?.cancel();
    soundService.playWorkoutComplete();
    notifyListeners();
  }

  /// Skip to next interval or set immediately
  void skipNext() {
    if (_isFinished) return;
    _advancePhase();
  }

  /// Rewind or restart the current phase
  void skipPrevious() {
    if (_isFinished) return;
    if (_currentPhase == WorkoutPhase.work && _currentSet > 1) {
      _currentSet--;
      _phaseTotalSeconds = routine.workSeconds;
      _phaseRemainingSeconds = routine.workSeconds;
    } else if (_currentPhase == WorkoutPhase.rest) {
      _currentPhase = WorkoutPhase.work;
      _phaseTotalSeconds = routine.workSeconds;
      _phaseRemainingSeconds = routine.workSeconds;
    } else {
      _phaseRemainingSeconds = _phaseTotalSeconds;
    }
    notifyListeners();
  }

  /// Add or subtract seconds on the fly (+10s / -10s)
  void adjustTime(int deltaSeconds) {
    if (_isFinished) return;
    final newTime = _phaseRemainingSeconds + deltaSeconds;
    if (newTime > 0) {
      _phaseRemainingSeconds = newTime;
      if (_phaseRemainingSeconds > _phaseTotalSeconds) {
        _phaseTotalSeconds = _phaseRemainingSeconds;
      }
      notifyListeners();
    }
  }

  /// Reset to routine start
  void reset() {
    _ticker?.cancel();
    _isRunning = false;
    _isPaused = false;
    _initTimer();
    notifyListeners();
  }

  /// Compute next phase information for preview badge
  ({WorkoutPhase phase, int seconds, String label}) get nextPhaseInfo {
    switch (_currentPhase) {
      case WorkoutPhase.prepare:
        return (phase: WorkoutPhase.work, seconds: routine.workSeconds, label: 'Work (Set 1)');
      case WorkoutPhase.work:
        if (_currentSet < routine.sets) {
          if (routine.restSeconds > 0) {
            return (phase: WorkoutPhase.rest, seconds: routine.restSeconds, label: 'Rest');
          }
          return (phase: WorkoutPhase.work, seconds: routine.workSeconds, label: 'Work (Set ${_currentSet + 1})');
        } else if (_currentCycle < routine.cycles) {
          if (routine.cycleRestSeconds > 0) {
            return (phase: WorkoutPhase.cycleRest, seconds: routine.cycleRestSeconds, label: 'Round Rest');
          }
          return (phase: WorkoutPhase.work, seconds: routine.workSeconds, label: 'Round ${_currentCycle + 1} Work');
        } else if (routine.cooldownSeconds > 0) {
          return (phase: WorkoutPhase.cooldown, seconds: routine.cooldownSeconds, label: 'Cool Down');
        }
        return (phase: WorkoutPhase.completed, seconds: 0, label: 'Workout Finished');

      case WorkoutPhase.rest:
        return (phase: WorkoutPhase.work, seconds: routine.workSeconds, label: 'Work (Set ${_currentSet + 1})');

      case WorkoutPhase.cycleRest:
        return (phase: WorkoutPhase.work, seconds: routine.workSeconds, label: 'Round ${_currentCycle + 1} Set 1');

      case WorkoutPhase.cooldown:
        return (phase: WorkoutPhase.completed, seconds: 0, label: 'Workout Finished');

      case WorkoutPhase.completed:
        return (phase: WorkoutPhase.completed, seconds: 0, label: 'Done');
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
