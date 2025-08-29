import 'dart:convert';

import 'package:gym_genius/core/domain/entities/exercise_set_entity.dart';

/// Data Transfer Object for [ExerciseSetEntity].
class ExerciseSetDTO {
  /// Creates an [ExerciseSetDTO] with the given [weight] and [reps].
  ExerciseSetDTO({
    required this.weight,
    required this.reps,
  });

  /// Creates an [ExerciseSetDTO] from an [ExerciseSetEntity].
  factory ExerciseSetDTO.fromEntity(ExerciseSetEntity entity) {
    return ExerciseSetDTO(weight: entity.weight, reps: entity.reps);
  }

  /// Creates an [ExerciseSetDTO] from a map.
  factory ExerciseSetDTO.fromMap(Map<String, dynamic> map) {
    return ExerciseSetDTO(
      weight: map['weight'] as num,
      reps: map['reps'] as int,
    );
  }

  /// Creates an [ExerciseSetDTO] from a JSON string.
  factory ExerciseSetDTO.fromJson(String source) =>
      ExerciseSetDTO.fromMap(json.decode(source) as Map<String, dynamic>);

  /// The weight used in the set.
  num weight;

  /// The number of repetitions performed in the set.
  int reps;

  /// Returns a copy of this [ExerciseSetDTO] with optional new values.
  ExerciseSetDTO copyWith({
    num? weight,
    int? reps,
  }) {
    return ExerciseSetDTO(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  /// Converts this DTO to an [ExerciseSetEntity].
  ExerciseSetEntity toEntity() {
    return ExerciseSetEntity(weight: weight, reps: reps);
  }

  /// Converts this DTO to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'weight': weight, 'reps': reps};
  }

  /// Converts this DTO to a JSON string.
  String toJson() => json.encode(toMap());

  /// Returns a string representation of this DTO.
  @override
  String toString() => 'ExerciseSetDto(weight: $weight, reps: $reps)';
}
