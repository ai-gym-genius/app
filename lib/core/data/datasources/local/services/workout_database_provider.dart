import 'package:gym_genius/core/data/datasources/local/services/exercise_loader.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


/// Provides access to the workout database and handles its initialization.
class WorkoutDatabaseProvider {
  /// Uses [exerciseLoader] for generating exerciseInfos and [databaseFactory]
  WorkoutDatabaseProvider(this.exerciseLoader, this.databaseFactory);

  /// Loader service for ExerciseInfos.
  final JsonExerciseInfosLoader exerciseLoader;

  /// Factory.
  final DatabaseFactory databaseFactory;

  static const _databaseName = 'workout.db';
  static const _databaseVersion = 1;

  static Database? _database;

  /// Always returns database.
  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    // Enable foreign keys on Android
    return databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Workouts table
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        duration INTEGER NOT NULL,
        start_time INTEGER NOT NULL,
        description TEXT,
        weight REAL
      );
    ''');

    // Exercise Infos
    await db.execute('''
      CREATE TABLE exercise_infos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        image_path TEXT,
        url TEXT
      );
    ''');

    // Enum
    await db.execute('''
      CREATE TABLE muscle_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      );
    ''');

    // Linking enum with infos
    await db.execute('''
      CREATE TABLE exercise_info_muscle_groups (
        exercise_info_id INTEGER NOT NULL,
        muscle_group_id INTEGER NOT NULL,
        PRIMARY KEY (exercise_info_id, muscle_group_id),
        FOREIGN KEY (exercise_info_id) REFERENCES exercise_infos(id) ON DELETE CASCADE,
        FOREIGN KEY (muscle_group_id) REFERENCES muscle_groups(id) ON DELETE CASCADE
      );
    ''');

    // Exercises
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_info_id INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_info_id) REFERENCES exercise_infos(id)
      );
    ''');

    // Sets
    await db.execute('''
      CREATE TABLE exercise_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        reps INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
      );
    ''');

    await _populateExInfos(db);
  }

  Future<void> _populateExInfos(Database db) async {
    // Load them from the source
    final infos = await exerciseLoader.loadDTOEx();

    // For each info we insert basic information, then muscleGroup and then we 
    // link it.
    for (final info in infos) {
      await db.insert(
        'exercise_infos',
        {
          'name': info.name,
          'description': info.description,
          'image_path': info.imagePath,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      final muscleGroups = info.muscleGroups;
      if (muscleGroups != null && muscleGroups.isNotEmpty) {
        for (final mgName in muscleGroups) {
          // Check if muscle group already exists
          final mgRows = await db.query(
            'muscle_groups',
            columns: ['id'],
            where: 'name = ?',
            whereArgs: [mgName.toLowerCase()],
          );

          int mgId;
          if (mgRows.isEmpty) {
            // Insert new muscle Group row
            mgId = await db.insert(
              'muscle_groups',
              {'name': mgName.toLowerCase()},
            );
          } else {
            mgId = mgRows.first['id']! as int;
          }

          // Now link them in exercise_info_muscle_groups
          await db.insert(
            'exercise_info_muscle_groups',
            {
              'exercise_info_id': info.id,
              'muscle_group_id': mgId,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    }
  }
}
