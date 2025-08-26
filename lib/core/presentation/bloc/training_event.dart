import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';

sealed class TrainingEvent {
  const TrainingEvent();
}

class TestGetRandomWorkout extends TrainingEvent {
  const TestGetRandomWorkout();
}

class AddExercise extends TrainingEvent {
  const AddExercise(this.info);
  final ExerciseInfoEntity info;
}

class RemoveExercise extends TrainingEvent {
  const RemoveExercise(this.exerciseID);
  final int exerciseID;
}

class SubmitTraining extends TrainingEvent {
  const SubmitTraining(this.workoutDuration);
  final Duration workoutDuration;
}

class GetAIReview extends TrainingEvent {
  const GetAIReview(this.workout);
  final WorkoutEntity workout;
}
