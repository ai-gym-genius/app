import 'package:gym_genius/core/domain/entities/workout_entity.dart';

abstract interface class WorkoutRepository {
  Future<void> saveWorkout(WorkoutEntity entity);
  Future<List<WorkoutEntity>> fetchWorkouts();
  Future<List<WorkoutEntity>> fetchRemoteWorkouts();
  Future<WorkoutEntity?> fetchWorkout(int workoutId);
  Future<String> getAIReview(WorkoutEntity workout);
}
