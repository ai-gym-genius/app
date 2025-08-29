// This code is mostly fucking shit and should be rewritten.
import 'package:gym_genius/core/data/datasources/local/services/workout_database_provider.dart';
import 'package:gym_genius/core/data/models/exercise_dto.dart';
import 'package:gym_genius/core/data/models/exercise_info_dto.dart';
import 'package:gym_genius/core/data/models/exercise_set_dto.dart';
import 'package:gym_genius/core/data/models/workout_dto.dart';

/// A datasource for local workout operations.
abstract class LocalWorkoutDatasource {
  /// Saves a workout to the local datasource.
  Future<void> saveWorkout(WorkoutDTO workout);

  /// Deletes a workout from the local datasource.
  Future<void> deleteWorkout(int id);

  /// Updates a workout in the local datasource.
  Future<void> updateWorkout(WorkoutDTO workout);

  /// Gets a workout from the local datasource by id.
  Future<WorkoutDTO?> getWorkoutById(int id);

  /// Gets all workouts from the local datasource.
  Future<List<WorkoutDTO>> getAllWorkouts();

  /// Loads all exercise infos from the local datasource.
  Future<List<ExerciseInfoDTO>> loadInfos();

  /// Marks an exercise info as favorite.
  Future<void> markInfoFavorite();

  /// Unmarks an exercise info as favorite.
  Future<void> unmarkInfoFavorite();
}

/// A datasource for local workout operations.
class SqfliteDatabase implements LocalWorkoutDatasource {
  /// Constructor for the [SqfliteDatabase] class.
  SqfliteDatabase(this.dbProvider);

  /// The database provider for the [SqfliteDatabase] class.
  final WorkoutDatabaseProvider dbProvider;

  @override
  Future<List<ExerciseInfoDTO>> loadInfos() async {
    final db = await dbProvider.database;
    final rows = await db.rawQuery(
      '''
      select
	      ei.id,
	      ei.name,
	      ei.description,
	      ei.image_path,
	      ei.url,
	      group_concat(mg.name) as muscle_groups
      from exercise_infos ei
      left JOIN exercise_info_muscle_groups eimg on ei.id = eimg.exercise_info_id
      left join muscle_groups mg on eimg.muscle_group_id = mg.id
      GROUP BY ei.id
      ''',
    );
    return rows.map(
      (row) {
        // Should implicitly cast string like "chest,triceps"
        // into List<String>?, so it can be passed to .fromMap
        final mutableRow = Map<String, dynamic>.from(row);
        final mg = mutableRow['muscle_groups'] as String?;
        // Change problematic field.
        mutableRow['muscle_groups'] = mg != null ? mg.split(',') : <dynamic>[];
        return ExerciseInfoDTO.fromSQLMap(mutableRow);
      },
    ).toList();
  }

  @override
  Future<void> saveWorkout(WorkoutDTO workout) async {
    final db = await dbProvider.database;
    await db.transaction((txn) async {
      // Insert the workout
      final workoutId = await txn.insert('workouts', {
        'duration': workout.duration.inSeconds,
        'start_time': workout.startTime.millisecondsSinceEpoch,
        'description': workout.description,
        'weight': workout.weight,
      });

      // Insert each exercise
      for (final exercise in workout.exercises) {
        final exerciseId = await txn.insert('exercises', {
          'workout_id': workoutId,
          'exercise_info_id': exercise.exerciseInfo.id,
        });

        // For this exercise insert each set
        for (final set in exercise.sets) {
          await txn.insert('exercise_sets', {
            'weight': set.weight,
            'reps': set.reps,
            'exercise_id': exerciseId,
          });
        }
      }
    });
  }

  @override
  Future<List<WorkoutDTO>> getAllWorkouts() async {
    final db = await dbProvider.database;

    return db.transaction<List<WorkoutDTO>>((txn) async {
      // Header rows.
      final workoutRows = await txn.query(
        'workouts',
        orderBy: 'start_time DESC', // newest first (optional)
      );
      if (workoutRows.isEmpty) return const [];
      final workoutIds = workoutRows.map<int>((r) => r['id']! as int).toList();

      // Exercises for all workouts.
      final exerciseRows = await txn.query(
        'exercises',
        where:
            'workout_id IN (${List.filled(workoutIds.length, '?').join(',')})',
        whereArgs: workoutIds,
      );

      // Exercise info ids.
      final exercisesByWorkout = <int, List<Map<String, Object?>>>{};
      final exerciseIds = <int>[];
      final exerciseInfoIds = <int>[];

      for (final r in exerciseRows) {
        final wid = r['workout_id']! as int;
        (exercisesByWorkout[wid] ??= []).add(r);

        exerciseIds.add(r['id']! as int);
        exerciseInfoIds.add(r['exercise_info_id']! as int);
      }

      final infosMap = <int, ExerciseInfoDTO>{};

      if (exerciseInfoIds.isNotEmpty) {
        final infosRows = await txn.query(
          'exercise_infos',
          where:
              'id IN (${List.filled(exerciseInfoIds.length, '?').join(',')})',
          whereArgs: exerciseInfoIds,
        );

        // muscle groups
        final mgRows = await txn.rawQuery('''
        SELECT eimg.exercise_info_id AS infoId, mg.name AS name
        FROM exercise_info_muscle_groups eimg
        JOIN muscle_groups mg ON mg.id = eimg.muscle_group_id
        WHERE eimg.exercise_info_id IN (${List.filled(exerciseInfoIds.length, '?').join(',')})
      ''', exerciseInfoIds);

        final mgsByInfo = <int, List<String>>{};
        for (final row in mgRows) {
          final infoId = row['infoId']! as int;
          (mgsByInfo[infoId] ??= [])
              .add((row['name']! as String).toLowerCase());
        }

        for (final r in infosRows) {
          final infoId = r['id']! as int;
          infosMap[infoId] = ExerciseInfoDTO(
            id: infoId,
            name: r['name']! as String,
            description: r['description'] as String?,
            imagePath: r['image_path'] as String?,
            url: r['url'] as String?,
            muscleGroups: mgsByInfo[infoId],
          );
        }
      }

      // Sets for all exercises.
      final setsByExercise = <int, List<ExerciseSetDTO>>{};
      if (exerciseIds.isNotEmpty) {
        final setRows = await txn.query(
          'exercise_sets',
          where:
              // Reason: query.
              // ignore: lines_longer_than_80_chars
              'exercise_id IN (${List.filled(exerciseIds.length, '?').join(',')})',
          whereArgs: exerciseIds,
        );

        for (final r in setRows) {
          final exId = r['exercise_id']! as int;
          (setsByExercise[exId] ??= []).add(
            ExerciseSetDTO(
              weight: r['weight']! as num,
              reps: r['reps']! as int,
            ),
          );
        }
      }

      final workouts = <WorkoutDTO>[];

      for (final w in workoutRows) {
        final wid = w['id']! as int;

        final exercises = <ExerciseDTO>[
          for (final Map<String, Object?> ex
              in (exercisesByWorkout[wid] ?? const []))
            ExerciseDTO(
              exerciseInfo: infosMap[ex['exercise_info_id']! as int]!,
              sets: setsByExercise[ex['id']! as int] ?? const [],
            ),
        ];

        workouts.add(
          WorkoutDTO(
            id: wid,
            duration: Duration(seconds: w['duration']! as int),
            startTime:
                DateTime.fromMillisecondsSinceEpoch(w['start_time']! as int),
            exercises: exercises,
            description: w['description'] as String?,
            weight:
                (w['weight'] is num) ? (w['weight']! as num).toDouble() : null,
          ),
        );
      }

      return workouts;
    });
  }

  @override
  Future<WorkoutDTO?> getWorkoutById(int id) async {
    final db = await dbProvider.database;

    return db.transaction<WorkoutDTO?>((txn) async {
      final workoutRows = await txn.query(
        'workouts',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (workoutRows.isEmpty) return null;
      final w = workoutRows.first;

      // All exercises for that workout.
      final exerciseRows = await txn.query(
        'exercises',
        where: 'workout_id = ?',
        whereArgs: [id],
      );

      // Exercise ids.
      final exerciseIds = exerciseRows.map((r) => r['id']! as int).toList();
      final exerciseInfoIds =
          exerciseRows.map((r) => r['exercise_info_id']! as int).toList();

      final infosMap = <int, ExerciseInfoDTO>{};
      if (exerciseInfoIds.isNotEmpty) {
        final infosRows = await txn.query(
          'exercise_infos',
          where:
              'id IN (${List.filled(exerciseInfoIds.length, '?').join(',')})',
          whereArgs: exerciseInfoIds,
        );

        final mgRows = await txn.rawQuery('''
          SELECT eimg.exercise_info_id AS infoId, mg.name AS name
          FROM exercise_info_muscle_groups eimg
          JOIN muscle_groups mg ON mg.id = eimg.muscle_group_id
          WHERE eimg.exercise_info_id IN (${List.filled(exerciseInfoIds.length, '?').join(',')})
        ''', exerciseInfoIds);

        final mgsByInfo = <int, List<String>>{};
        for (final row in mgRows) {
          final infoId = row['infoId']! as int;
          (mgsByInfo[infoId] ??= [])
              .add((row['name']! as String).toLowerCase());
        }

        for (final r in infosRows) {
          final id = r['id']! as int;
          infosMap[id] = ExerciseInfoDTO(
            id: id,
            name: r['name']! as String,
            description: r['description'] as String?,
            imagePath: r['image_path'] as String?,
            url: r['url'] as String?,
            muscleGroups: mgsByInfo[id],
          );
        }
      }

      // Load sets for all exercises.
      final setsByExercise = <int, List<ExerciseSetDTO>>{};
      if (exerciseIds.isNotEmpty) {
        final setRows = await txn.query(
          'exercise_sets',
          where:
              // Reason: It's a query.
              // ignore: lines_longer_than_80_chars
              'exercise_id IN (${List.filled(exerciseIds.length, '?').join(',')})',
          whereArgs: exerciseIds,
        );

        for (final r in setRows) {
          final exId = r['exercise_id']! as int;
          (setsByExercise[exId] ??= []).add(
            ExerciseSetDTO(
              weight: r['weight']! as num,
              reps: r['reps']! as int,
            ),
          );
        }
      }

      // Assemble DTO objects.
      final exercises = <ExerciseDTO>[];
      for (final r in exerciseRows) {
        final exId = r['id']! as int;
        final infoId = r['exercise_info_id']! as int;

        exercises.add(
          ExerciseDTO(
            exerciseInfo: infosMap[infoId]!, // always present
            sets: setsByExercise[exId] ?? const [],
          ),
        );
      }

      return WorkoutDTO(
        id: w['id']! as int,
        duration: Duration(seconds: w['duration']! as int),
        startTime: DateTime.fromMillisecondsSinceEpoch(w['start_time']! as int),
        exercises: exercises,
        description: w['description'] as String?,
        weight: (w['weight'] is num) ? (w['weight']! as num).toDouble() : null,
      );
    });
  }

  @override
  Future<void> deleteWorkout(int id) {
    // TODO: implement deleteWorkout
    throw UnimplementedError();
  }

  @override
  Future<void> updateWorkout(WorkoutDTO workout) {
    // TODO: implement updateWorkout
    throw UnimplementedError();
  }

  @override
  Future<void> markInfoFavorite() {
    // TODO: implement markInfoFavourite
    throw UnimplementedError();
  }

  @override
  Future<void> unmarkInfoFavorite() {
    // TODO: implement unmarkInfoFavorite
    throw UnimplementedError();
  }
}
