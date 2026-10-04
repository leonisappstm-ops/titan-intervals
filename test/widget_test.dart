import 'package:flutter_test/flutter_test.dart';
import 'package:gym_interval_timer/main.dart';
import 'package:gym_interval_timer/models/user_account.dart';
import 'package:gym_interval_timer/models/workout_phase.dart';
import 'package:gym_interval_timer/models/workout_routine.dart';
import 'package:gym_interval_timer/services/auth_service.dart';
import 'package:gym_interval_timer/services/timer_controller.dart';

void main() {
  group('WorkoutRoutine and Timer Logic Tests', () {
    test('Calculates Tabata total duration accurately', () {
      const tabata = WorkoutRoutine(
        id: 'test_tabata',
        name: 'Test Tabata',
        description: 'Test',
        prepareSeconds: 10,
        workSeconds: 20,
        restSeconds: 10,
        sets: 8,
        cycles: 1,
      );

      expect(tabata.totalDurationSeconds, 240);
      expect(tabata.formattedTotalDuration, '4m');
    });

    test('TimerController transitions properly between prepare and work', () {
      const testRoutine = WorkoutRoutine(
        id: 'test',
        name: 'Test Routine',
        description: 'Testing',
        prepareSeconds: 2,
        workSeconds: 5,
        restSeconds: 3,
        sets: 2,
        cycles: 1,
      );

      final controller = TimerController(routine: testRoutine);
      expect(controller.currentPhase, WorkoutPhase.prepare);
      expect(controller.phaseRemainingSeconds, 2);

      controller.skipNext();
      expect(controller.currentPhase, WorkoutPhase.work);
      expect(controller.currentSet, 1);
      expect(controller.phaseRemainingSeconds, 5);

      controller.skipNext();
      expect(controller.currentPhase, WorkoutPhase.rest);
      expect(controller.phaseRemainingSeconds, 3);

      controller.skipNext();
      expect(controller.currentPhase, WorkoutPhase.work);
      expect(controller.currentSet, 2);

      controller.skipNext();
      expect(controller.currentPhase, WorkoutPhase.completed);
      expect(controller.isFinished, isTrue);

      controller.dispose();
    });
  });

  group('UserAccount and AuthService Tests', () {
    test('UserAccount serialization and deserialization works', () {
      final account = UserAccount(
        id: 'u_123',
        email: 'alex@gym.com',
        displayName: 'Alex',
        authProvider: 'email',
        createdAt: DateTime(2026, 1, 1),
        customRoutines: [
          const WorkoutRoutine(
            id: 'cr_1',
            name: 'Custom Burn',
            description: 'My custom routine',
            workSeconds: 30,
            restSeconds: 15,
            sets: 6,
          ),
        ],
        workoutHistory: [
          WorkoutLog(
            id: 'l_1',
            routineId: 'cr_1',
            routineName: 'Custom Burn',
            durationSeconds: 300,
            setsCompleted: 6,
            caloriesBurned: 55,
            completedAt: DateTime(2026, 1, 2),
          ),
        ],
      );

      final json = account.toJson();
      final restored = UserAccount.fromJson(json);

      expect(restored.id, 'u_123');
      expect(restored.email, 'alex@gym.com');
      expect(restored.displayName, 'Alex');
      expect(restored.customRoutines.length, 1);
      expect(restored.customRoutines.first.name, 'Custom Burn');
      expect(restored.workoutHistory.length, 1);
      expect(restored.totalWorkoutsCompleted, 1);
      expect(restored.totalActiveMinutes, 5);
      expect(restored.totalCaloriesBurned, 55);
    });

    test('AuthService signup, signin, custom routine, and logging flow', () async {
      final auth = AuthService();
      await auth.initialize();

      // Sign up with standalone email
      final testEmail = 'runner_${DateTime.now().millisecondsSinceEpoch}@titan.fit';
      final signedUp = await auth.signUpWithEmail(testEmail, 'pass123', 'Runner Max');
      expect(signedUp, isTrue);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUser?.displayName, 'Runner Max');

      // Save custom routine to this account
      const customRoutine = WorkoutRoutine(
        id: 'custom_hiit_test',
        name: 'Sprint Test',
        description: 'Test workout',
        workSeconds: 25,
        restSeconds: 10,
        sets: 4,
        tag: 'CUSTOM',
      );
      await auth.saveCustomRoutine(customRoutine);
      expect(auth.customRoutines.length, 1);
      expect(auth.customRoutines.first.name, 'Sprint Test');

      // Record workout log
      await auth.recordWorkoutLog(
        WorkoutLog(
          id: 'log_test_1',
          routineId: customRoutine.id,
          routineName: customRoutine.name,
          durationSeconds: 140,
          setsCompleted: 4,
          caloriesBurned: 25,
          completedAt: DateTime.now(),
        ),
      );
      expect(auth.workoutHistory.length, 1);

      // Sign in with Google (different account)
      await auth.signInWithGoogle(email: 'google.pro@gmail.com', name: 'Google Pro');
      expect(auth.currentUser?.authProvider, 'google');
      expect(auth.currentUser?.email, 'google.pro@gmail.com');

      // Sign in with Facebook
      await auth.signInWithFacebook(name: 'Fit Influencer');
      expect(auth.currentUser?.authProvider, 'facebook');
      expect(auth.currentUser?.displayName, 'Fit Influencer');

      // Sign out
      await auth.signOut();
      expect(auth.isLoggedIn, isFalse);

      // Sign back in with email
      final signedIn = await auth.signInWithEmail(testEmail, 'pass123');
      expect(signedIn, isTrue);
      expect(auth.currentUser?.displayName, 'Runner Max');
      // Verifies custom routine was preserved!
      expect(auth.customRoutines.length, 1);
      expect(auth.customRoutines.first.name, 'Sprint Test');
      expect(auth.workoutHistory.length, 1);
    });
  });

  group('Widget Tests', () {
    testWidgets('App renders AuthScreen or HomeScreen depending on auth state', (WidgetTester tester) async {
      await tester.pumpWidget(const GymIntervalTimerApp());
      await tester.pumpAndSettle();

      // Since user is logged in from above test, Home Screen is shown
      expect(find.text('TITAN INTERVALS'), findsOneWidget);
    });
  });
}
