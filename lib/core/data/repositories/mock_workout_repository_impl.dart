import 'package:gym_genius/core/data/datasources/mock_data.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';
import 'package:gym_genius/core/domain/repositories/workout_repository.dart';

class MockWorkoutRepositoryImpl implements WorkoutRepository {
  @override
  Future<WorkoutEntity?> fetchWorkout(int workoutId) {
    // TODO: implement fetchWorkout
    throw UnimplementedError();
  }

  @override
  Future<List<WorkoutEntity>> fetchWorkouts() async {
    Future.delayed(const Duration(milliseconds: 300));
    return getMockWorkouts(100);
  }

  @override
  Future<String> getAIReview(WorkoutEntity workout) {
    // TODO: implement getAIReview
    throw UnimplementedError();
  }

  @override
  Future<void> saveWorkout(WorkoutEntity entity) {
    // TODO: implement saveWorkout
    throw UnimplementedError();
  }

  @override
  Future<List<WorkoutEntity>> fetchRemoteWorkouts() {
    // TODO: implement fetchRemoteWorkouts
    throw UnimplementedError();
  }
}
