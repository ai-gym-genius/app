import 'package:get_it/get_it.dart';
import 'package:gym_genius/core/data/datasources/local/local_workout_datasource.dart';
import 'package:gym_genius/core/data/datasources/local/services/exercise_loader.dart';
import 'package:gym_genius/core/data/datasources/local/services/workout_database_provider.dart';
import 'package:gym_genius/core/data/datasources/remote/remote_workout_datasource.dart';
import 'package:gym_genius/core/data/repositories/ex_infos_repository_impl.dart';
import 'package:gym_genius/core/data/repositories/user_repository_impl.dart';
import 'package:gym_genius/core/data/repositories/workout_repository_impl.dart';
import 'package:gym_genius/core/domain/repositories/ex_infos_repository.dart';
import 'package:gym_genius/core/domain/repositories/workout_repository.dart';
import 'package:gym_genius/core/network/data/user_credentials.dart';
import 'package:gym_genius/core/network/dio_service.dart';
import 'package:gym_genius/core/presentation/bloc/training_bloc.dart';
import 'package:sqflite/sqflite.dart';

final GetIt getIt = GetIt.instance;

/// Indicates whether to use mock versions or not.
enum LaunchingType {
  development,
  production,
}

Future<void> setUpLocator(LaunchingType type) async {
  // Database related.
  getIt.registerSingleton<JsonExerciseInfosLoader>(
    JsonExerciseInfosLoader(),
  );
  getIt.registerLazySingleton<DatabaseFactory>(() => databaseFactory);
  getIt.registerLazySingleton<WorkoutDatabaseProvider>(
      () => WorkoutDatabaseProvider(getIt(), getIt()));

  // Register Datasources
  // For local - dbProvider
  // For remote - apiProvider
  getIt.registerLazySingleton<LocalWorkoutDatasource>(
    () => SqfliteDatabase(getIt<WorkoutDatabaseProvider>()),
  );

  getIt.registerLazySingleton(DioService.new);
  getIt.registerLazySingleton<RemoteWorkoutDatasource>(
    () => APIWorkoutDatasource(getIt<DioService>()),
  );
  getIt.registerLazySingleton(UserCredentials.new);
  getIt.registerLazySingleton(
      () => UserRepositoryImpl(getIt<UserCredentials>(), getIt<DioService>()));

  // Register Repositories
  getIt.registerLazySingleton<WorkoutRepository>(
    () {
      // switch (type) {
      // case LaunchingType.development:
      //   return MockWorkoutRepositoryImpl();
      // case LaunchingType.production:
      return WorkoutRepositoryImpl(
          getIt<LocalWorkoutDatasource>(), getIt<RemoteWorkoutDatasource>());
      // }
    },
  );
  getIt.registerLazySingleton<ExInfosRepository>(
    ExInfosRepositoryImpl.new,
  );

  // Blocs
  getIt.registerFactory<TrainingBloc>(
    () => TrainingBloc(workoutRepository: getIt<WorkoutRepository>()),
  );
}
