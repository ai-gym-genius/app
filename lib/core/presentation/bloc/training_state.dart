import 'package:equatable/equatable.dart';

import 'package:gym_genius/core/domain/entities/exercise_entity.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';

enum SubmitTrainingStatus {
  initial,
  loading,
  success,
  failureEmptySets,
  failureWritingDB
}

enum AddExerciseStatus { initial, success, duplicate }

enum GetAIReviewStatus { initial, loading, failure, success }

final class TrainingState extends Equatable {
  const TrainingState({
    this.exercises = const [],
    this.submitTrainingStatus = SubmitTrainingStatus.initial,
    this.addExerciseStatus = AddExerciseStatus.initial,
    this.getAIReviewStatus = GetAIReviewStatus.initial,
    this.workout,
    this.review,
  });

  final List<ExerciseEntity> exercises;
  final AddExerciseStatus addExerciseStatus;
  final SubmitTrainingStatus submitTrainingStatus;
  final GetAIReviewStatus getAIReviewStatus;
  final WorkoutEntity? workout;
  final String? review;

  @override
  List<Object?> get props => [
        exercises,
        addExerciseStatus,
        submitTrainingStatus,
        getAIReviewStatus,
        workout,
        review,
      ];

  TrainingState copyWith({
    List<ExerciseEntity>? exercises,
    AddExerciseStatus? addStatus,
    SubmitTrainingStatus? submitStatus,
    GetAIReviewStatus? getAIReviewStatus,
    WorkoutEntity? workout,
    String? review,
  }) {
    return TrainingState(
      exercises: exercises ?? this.exercises,
      addExerciseStatus: addStatus ?? addExerciseStatus,
      submitTrainingStatus: submitStatus ?? submitTrainingStatus,
      getAIReviewStatus: getAIReviewStatus ?? this.getAIReviewStatus,
      workout: workout ?? workout,
      review: review ?? review,
    );
  }
}
