import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';
import 'package:gym_genius/core/domain/repositories/ex_infos_repository.dart';

/// Service for modifying user's copy of json that contains ExerciseInfos.
class ExInfosRepositoryImpl implements ExInfosRepository {
  @override
  Future<List<ExerciseInfoEntity>> loadFavorites() {
    // TODO: implement loadFavorites
    throw UnimplementedError();
  }

  @override
  Future<List<ExerciseInfoEntity>> loadInfos() async {
    throw UnimplementedError();
  }

  @override
  Future<void> markInfoFavorite() {
    // TODO: implement markInfoFavorite
    throw UnimplementedError();
  }

  @override
  Future<void> unmarkInfoFavorite() {
    // TODO: implement unmarkInfoFavorite
    throw UnimplementedError();
  }
}
