import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';
import 'package:gym_genius/core/domain/entities/exercise_set_entity.dart';

/// Represents an exercise performed in a workout, including its info and sets.
class ExerciseEntity {
  /// Creates an [ExerciseEntity] with the given [exerciseInfo] and [sets].
  ExerciseEntity({required this.exerciseInfo, required this.sets});

  /// The metadata describing the exercise.
  final ExerciseInfoEntity exerciseInfo;

  /// The list of sets performed for this exercise.
  final List<ExerciseSetEntity> sets;
}
