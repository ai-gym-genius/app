// Mock workout data generator for testing and prototyping
// --------------------------------------------------------
// Usage:
//   final workouts = getMockWorkouts(25); // 25 random workouts for the current month
//
// The generator creates workouts whose `startTime` values are spread randomly
// across *this* calendar month and whose `duration` values vary between 30‑90
// minutes.  Each workout contains 2‑5 exercises with 3 randomised sets each.
//
// Why this matters
// ---------------
// • Flexible `int n` parameter lets you decide how many workouts you need.
// • Randomised date‑times and volumes give your UI something closer to real
//   production data without hand‑coding dozens of samples.
// • Runs entirely in memory – no package dependencies beyond `dart:math`.

import 'dart:math';

import 'package:gym_genius/core/domain/entities/exercise_entity.dart';
import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';
import 'package:gym_genius/core/domain/entities/exercise_set_entity.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';

/// Returns a reproducible collection of [WorkoutEntity]s.
///
/// * [n] – how many workout entries you want (≥ 1).
/// * [seed] – optional seed for deterministic output (handy for golden tests).
List<WorkoutEntity> getMockWorkouts(int n, {int? seed}) {
  assert(n > 0, 'n must be ≥ 1');
  final random = Random(seed);

  // ---- Define catalogue of exercises (static) -----------------------------
  const chestPressInfo = ExerciseInfoEntity(
    id: 1,
    name: 'Barbell Bench Press',
    description: 'Classic compound chest exercise performed on a flat bench.',
    url: 'https://exrx.net/WeightExercises/PectoralSternal/BBBenchPress',
    muscleGroups: [
      MuscleGroup.chest,
      MuscleGroup.triceps,
      MuscleGroup.shoulders,
    ],
  );

  const squatInfo = ExerciseInfoEntity(
    id: 2,
    name: 'Back Squat',
    description: 'High‑bar barbell squat taken from a rack.',
    url: 'https://exrx.net/WeightExercises/Quadriceps/BBSquat',
    muscleGroups: [MuscleGroup.legs],
  );

  const deadliftInfo = ExerciseInfoEntity(
    id: 3,
    name: 'Conventional Deadlift',
    description: 'Pull the barbell from the floor to lock‑out.',
    url: 'https://exrx.net/WeightExercises/ErectorSpinae/BBDeadlift',
    muscleGroups: [MuscleGroup.back, MuscleGroup.legs],
  );

  const overheadPressInfo = ExerciseInfoEntity(
    id: 4,
    name: 'Standing Overhead Press',
    description: 'Press the barbell overhead while standing.',
    url: 'https://exrx.net/WeightExercises/DeltoidAnterior/BBMilitaryPress',
    muscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
  );

  const barbellRowInfo = ExerciseInfoEntity(
    id: 5,
    name: 'Barbell Row',
    description: 'Bent‑over barbell row to the mid‑torso.',
    url: 'https://exrx.net/WeightExercises/BackGeneral/BBBentOverRow',
    muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
  );

  const exercisePool = <ExerciseInfoEntity>[
    chestPressInfo,
    squatInfo,
    deadliftInfo,
    overheadPressInfo,
    barbellRowInfo,
  ];

  // ---- Helper for random ExerciseSet --------------------------------------
  List<ExerciseSetEntity> randomSets() => List.generate(3, (_) {
        final weight = 40 + random.nextInt(81); // 40‑120 kg
        final reps = 5 + random.nextInt(11); // 5‑15 reps
        return ExerciseSetEntity(weight: weight, reps: reps);
      });

  // ---- Generate dates within the current month ---------------------------
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month - 12);
  final nextMonth = now.month == 12
      ? DateTime(now.year + 1)
      : DateTime(now.year, now.month + 1);
  final daysInMonth = nextMonth.difference(monthStart).inDays;

  DateTime randomDateTime() {
    final dayOffset = random.nextInt(daysInMonth);
    final minuteOfDay = random.nextInt(24 * 60);
    return monthStart.add(
      Duration(days: dayOffset, minutes: minuteOfDay),
    );
  }

  // ---- Assemble workouts list --------------------------------------------
  final workouts = <WorkoutEntity>[];
  for (var i = 0; i < n; i++) {
    // pick 2‑5 unique exercises
    final exercisesShuffled = List.of(exercisePool)..shuffle(random);
    final selectedCount = 2 + random.nextInt(4);
    final exercises = exercisesShuffled.take(selectedCount).map((info) {
      return ExerciseEntity(
        exerciseInfo: info,
        sets: randomSets(),
      );
    }).toList();

    workouts.add(
      WorkoutEntity(
        id: 100 + i,
        duration: Duration(minutes: 30 + random.nextInt(61)), // 30‑90 min
        startTime: randomDateTime(),
        weight: 68 + random.nextDouble() * 12, // 68‑80 kg body‑weight
        description: 'Auto‑generated mock workout #${i + 1}',
        exercises: exercises,
      ),
    );
  }

  return workouts;
}
