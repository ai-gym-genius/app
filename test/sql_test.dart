import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_genius/core/data/datasources/local/services/exercise_loader.dart';
import 'package:gym_genius/core/data/datasources/local/services/workout_database_provider.dart';
import 'package:gym_genius/core/data/models/workout_dto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late WorkoutDatabaseProvider databaseProvider;
  late Database db;

  databaseFactory = databaseFactoryFfi;

  setUp(() async {
    databaseProvider = WorkoutDatabaseProvider(
      JsonExerciseInfosLoader(),
      databaseFactoryFfi,
    );
    db = await databaseProvider.database;
  });

  tearDown(() async {
    await db.close();
  });

  test('Init works just fine', () async {
    final infos = await db.query('exercise_infos');
    expect(infos, isNotEmpty);

    final groups = await db.query('muscle_groups');
    expect(groups, isNotEmpty);

    final link = await db.query('exercise_info_muscle_groups');
    expect(link, isNotEmpty);
  });

  test('saveWorkout saves workout', () async {
    final workout = WorkoutDTO.fake();
    await db.transaction((txn) async {
      final workoutId = await txn.insert('workouts', {
        'duration': workout.duration.inSeconds,
        'start_time': workout.startTime.millisecondsSinceEpoch,
        'description': workout.description,
        'weight': workout.weight,
      });

      for (final ex in workout.exercises) {
        final info = ex.exerciseInfo;

        final exerciseId = await txn.insert('exercises', {
          'workout_id': workoutId,
          'exercise_info_id': info.id,
        });

        for (final set in ex.sets) {
          await txn.insert('exercise_sets', {
            'weight': set.weight,
            'reps': set.reps,
            'exercise_id': exerciseId,
          });
        }
      }

      print(await txn.query('workouts'));
    });

    return workout;
  });
}
