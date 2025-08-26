import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';
import 'package:gym_genius/core/domain/entities/exercise_set_entity.dart';

class ExerciseEntity {
  ExerciseEntity({required this.exerciseInfo, required this.sets});
  final ExerciseInfoEntity exerciseInfo;
  final List<ExerciseSetEntity> sets;
}
