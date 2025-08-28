import 'dart:convert';

import 'package:gym_genius/core/data/models/workout_dto.dart';
import 'package:gym_genius/core/network/dio_service.dart';

/// A datasource for remote workout operations.
abstract class RemoteWorkoutDatasource {
  /// Saves a workout to the remote datasource.
  Future<void> saveWorkout(WorkoutDTO workout);

  /// Gets a description of the workout from the remote datasource.
  ///
  /// Might be removed to separate feature (AI).
  ///
  /// TODO: Remove this method.
  Future<String> getAIDescription(WorkoutDTO workout);

  /// Fetches all workouts from the remote datasource.
  Future<List<WorkoutDTO>> fetchWorkouts();
}

/// A datasource for remote workout operations.
class APIWorkoutDatasource implements RemoteWorkoutDatasource {
  /// Constructor for the [APIWorkoutDatasource] class.
  const APIWorkoutDatasource(this.client);

  /// The client for the [APIWorkoutDatasource] class.
  final DioService client;

  @override
  Future<String> getAIDescription(WorkoutDTO workout) async {
    // Unimplemented since will be handled on backend.
    throw UnimplementedError();
  }

  @override
  Future<void> saveWorkout(WorkoutDTO workout) async {
    // First fetch id;
    final data = await client.get('/users/me') as Map;
    final id = data['id'] as int;

    await client.post(
      '/workouts',
      data: json.encode(workout.toFuckingShit(id)),
    );
  }

  @override
  Future<List<WorkoutDTO>> fetchWorkouts() async {
    final dynamic workouts = await client.get('/workouts/my');
    if (workouts == null) {
      return [];
    }

    final parsedShit = (workouts as List<Map<String, dynamic>>)
        .map(WorkoutDTO.fromBackendMap)
        .toList();

    return parsedShit;
  }
}
