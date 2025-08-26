// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:gym_genius/core/data/models/exercise_dto.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';

class WorkoutDTO {
  final int id;
  final Duration duration; // In seconds
  final DateTime startTime;
  List<ExerciseDTO> exercises;
  String? description;
  double? weight;

  WorkoutDTO({
    required this.id,
    required this.duration,
    required this.startTime,
    required this.exercises,
    this.description,
    this.weight,
  });

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

  static List<WorkoutDTO> fakeMany(int amount) {
    return List.generate(amount, (_) => WorkoutDTO.fake());
  }

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

//   [
//   {
//     "id": 153,
//     "duration_ns": 60,
//     "timestamp": "2023-10-01T12:00:00Z",
//     "user_id": 0,
//     "exercise_sets": [
//       {
//         "weight": 10,
//         "reps": 10,
//         "exercise_id": 10
//       }
//     ]
//   }
// ]

  factory WorkoutDTO.fromBackendMap(Map<String, dynamic> map) {
    return WorkoutDTO(
      id: map['id'] as int,
      duration: Duration(seconds: ((map['duration_ns'] as int) / 1000).round()),
      startTime: DateTime.parse(map['timestamp'] as String),
      exercises: [],
    );
  }

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

  String toJson() => json.encode(toMap());

  factory WorkoutDTO.fromJson(String source) =>
      WorkoutDTO.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutDTO.fromBackendJson(String source) =>
      WorkoutDTO.fromBackendMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Workout(id: $id, duration: $duration, startTime: $startTime, exercises: $exercises, description: $description, weight: $weight)';
  }

  @override
  bool operator ==(covariant WorkoutDTO other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.duration == duration &&
        other.startTime == startTime &&
        listEquals(other.exercises, exercises) &&
        other.description == description &&
        other.weight == weight;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        duration.hashCode ^
        startTime.hashCode ^
        exercises.hashCode ^
        description.hashCode ^
        weight.hashCode;
  }
}
