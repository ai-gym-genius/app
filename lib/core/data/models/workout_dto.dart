import 'dart:convert';
import 'dart:math';

import 'package:gym_genius/core/data/models/exercise_dto.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';

/// Data Transfer Object for a workout.
class WorkoutDTO {
  /// Creates a [WorkoutDTO] with the given properties.
  WorkoutDTO({
    required this.id,
    required this.duration,
    required this.startTime,
    required this.exercises,
    this.description,
    this.weight,
  });

  /// Creates a [WorkoutDTO] from a backend JSON string.
  factory WorkoutDTO.fromBackendJson(String source) =>
      WorkoutDTO.fromBackendMap(json.decode(source) as Map<String, dynamic>);

  /// Generates a fake [WorkoutDTO] with random data.
  factory WorkoutDTO.fake() {
    final rand = Random(DateTime.now().millisecondsSinceEpoch);

    return WorkoutDTO(
      id: rand.nextInt(1 << 31),
      duration: Duration(
        hours: rand.nextInt(4),
        minutes: rand.nextInt(60),
      ),
      // Starttime - around the current year
      startTime: DateTime.now().subtract(Duration(days: rand.nextInt(365))),
      description: 'Random workout ${rand.nextInt(1 << 10)}',
      exercises:
          List.generate(rand.nextInt(5) + 1, (val) => ExerciseDTO.fake()),
    );
  }

  /// Creates a [WorkoutDTO] from a [WorkoutEntity].
  factory WorkoutDTO.fromEntity(WorkoutEntity entity) {
    return WorkoutDTO(
      id: entity.id,
      duration: entity.duration,
      startTime: entity.startTime,
      exercises: entity.exercises.map(ExerciseDTO.fromEntity).toList(),
      description: entity.description,
      weight: entity.weight,
    );
  }

  /// Creates a [WorkoutDTO] from a backend map.
  factory WorkoutDTO.fromBackendMap(Map<String, dynamic> map) {
    return WorkoutDTO(
      id: map['id'] as int,
      duration: Duration(seconds: ((map['duration_ns'] as int) / 1000).round()),
      startTime: DateTime.parse(map['timestamp'] as String),
      exercises: [],
    );
  }

  /// Creates a [WorkoutDTO] from a map with snake_case keys.
  factory WorkoutDTO.fromMap(Map<String, dynamic> map) {
    return WorkoutDTO(
      id: map['id'] as int,
      duration: Duration(seconds: map['duration'] as int),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      weight: map['weight'] != null ? map['weight'] as double : null,
      exercises: (map['exercises'] as List<Map<String, dynamic>>)
          .map(ExerciseDTO.fromMap)
          .toList(),
      description:
          map['description'] != null ? map['description'] as String : null,
    );
  }

  /// Creates a [WorkoutDTO] from a JSON string.
  factory WorkoutDTO.fromJson(String source) =>
      WorkoutDTO.fromMap(json.decode(source) as Map<String, dynamic>);

  /// The unique identifier of the workout.
  final int id;

  /// The duration of the workout.
  final Duration duration;

  /// The start time of the workout.
  final DateTime startTime;

  /// The list of exercises in the workout.
  List<ExerciseDTO> exercises;

  /// The optional description of the workout.
  String? description;

  /// The optional weight associated with the workout.
  double? weight;

  /// Returns a copy of this [WorkoutDTO] with updated fields.
  WorkoutDTO copyWith({
    int? id,
    Duration? duration,
    DateTime? startTime,
    List<ExerciseDTO>? exercises,
    String? description,
    double? weight,
  }) {
    return WorkoutDTO(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      exercises: exercises ?? this.exercises,
      description: description ?? this.description,
      weight: weight ?? this.weight,
    );
  }

  /// Converts this DTO to a [WorkoutEntity].
  WorkoutEntity toEntity() {
    return WorkoutEntity(
      id: id,
      duration: duration,
      startTime: startTime,
      exercises: exercises.map((exercise) => exercise.toEntity()).toList(),
      description: description,
      weight: weight,
    );
  }

  /// Generates a list of fake [WorkoutDTO]s of the given [amount].
  static List<WorkoutDTO> fakeMany(int amount) {
    return List.generate(amount, (_) => WorkoutDTO.fake());
  }

  /// Converts this DTO to a map with snake_case keys.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'duration': duration.inSeconds,
      'start_time': startTime.millisecondsSinceEpoch,
      'exercises': exercises.map((x) => x.toMap()).toList(),
      'description': description,
      'weight': weight,
    };
  }

  /// Converts this DTO to a backend-specific map for API submission.
  Map<String, dynamic> toFuckingShit(int id) {
    final fuckingExercises = <Map<String, num>>[];
    for (final ex in exercises) {
      fuckingExercises.addAll(ex.toShitList());
    }

    return {
      'duration_ns': duration.inMilliseconds,
      'start_time': startTime.toUtc().toIso8601String(),
      'user_id': id,
      'exercise_sets': fuckingExercises
    };
  }

  /// Converts this DTO to a map with camelCase keys.
  Map<String, dynamic> toCamelMap() {
    return <String, dynamic>{
      'id': id,
      'duration': duration.inSeconds,
      'startTime': startTime.millisecondsSinceEpoch,
      'exercises': exercises.map((x) => x.toFuckingShit()).toList(),
      'description': description,
      'weight': weight,
    };
  }

  /// Converts this DTO to a JSON string.
  String toJson() => json.encode(toMap());

  /// Returns a string representation of this DTO.
  @override
  String toString() {
    // reason: easier to read.
    // ignore: lines_longer_than_80_chars
    return 'Workout(id: $id, duration: $duration, startTime: $startTime, exercises: $exercises, description: $description, weight: $weight)';
  }
}
