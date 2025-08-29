import 'package:gym_genius/core/data/datasources/local/local_workout_datasource.dart';
import 'package:gym_genius/core/data/datasources/remote/remote_workout_datasource.dart';
import 'package:gym_genius/core/data/models/workout_dto.dart';

import 'package:gym_genius/core/domain/entities/workout_entity.dart';
import 'package:gym_genius/core/domain/repositories/workout_repository.dart';

/// CRUD for workouts and some AI related methods.
class WorkoutRepositoryImpl implements WorkoutRepository {
  /// Creates a [WorkoutRepositoryImpl] with the given local and remote 
  /// datasources.
  WorkoutRepositoryImpl(
    this.localWorkoutDatasource,
    this.remoteWorkoutDatasource,
  );

  /// Handles local db.
  final LocalWorkoutDatasource localWorkoutDatasource;

  /// Handles network operation.
  final RemoteWorkoutDatasource remoteWorkoutDatasource;

  @override
  Future<WorkoutEntity?> fetchWorkout(int workoutId) async {
    final dto = await localWorkoutDatasource.getWorkoutById(workoutId);
    return dto?.toEntity();
  }

  @override
  Future<List<WorkoutEntity>> fetchWorkouts() async {
    final dtos = await localWorkoutDatasource.getAllWorkouts();
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<String> getAIReview(WorkoutEntity workout) async {
    return remoteWorkoutDatasource
        .getAIDescription(WorkoutDTO.fromEntity(workout));
  }

  @override
  Future<void> saveWorkout(WorkoutEntity entity) async {
    final dto = WorkoutDTO.fromEntity(entity);
    await localWorkoutDatasource.saveWorkout(dto);
    await remoteWorkoutDatasource.saveWorkout(dto);
  }

  @override
  Future<List<WorkoutEntity>> fetchRemoteWorkouts() async {
    final dtos = await remoteWorkoutDatasource.fetchWorkouts();
    return dtos.map((dto) => dto.toEntity()).toList();
  }
}
