import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';

abstract interface class ExInfosRepository {
  Future<List<ExerciseInfoEntity>> loadInfos();
  Future<List<ExerciseInfoEntity>> loadFavorites();
  Future<void> markInfoFavorite();
  Future<void> unmarkInfoFavorite();
}
