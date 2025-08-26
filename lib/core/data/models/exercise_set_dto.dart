import 'dart:convert';

import 'package:gym_genius/core/domain/entities/exercise_set_entity.dart';

class ExerciseSetDTO {
  ExerciseSetDTO({
    required this.weight,
    required this.reps,
  });

  factory ExerciseSetDTO.fromEntity(ExerciseSetEntity entity) {
    return ExerciseSetDTO(weight: entity.weight, reps: entity.reps);
  }

  factory ExerciseSetDTO.fromMap(Map<String, dynamic> map) {
    return ExerciseSetDTO(
      weight: map['weight'] as num,
      reps: map['reps'] as int,
    );
  }

  factory ExerciseSetDTO.fromJson(String source) =>
      ExerciseSetDTO.fromMap(json.decode(source) as Map<String, dynamic>);
  num weight;
  int reps;

  ExerciseSetDTO copyWith({
    num? weight,
    int? reps,
  }) {
    return ExerciseSetDTO(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
    );
  }

  ExerciseSetEntity toEntity() {
    return ExerciseSetEntity(weight: weight, reps: reps);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'weight': weight, 'reps': reps};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'ExerciseSetDto(weight: $weight, reps: $reps)';

  @override
  bool operator ==(covariant ExerciseSetDTO other) {
    if (identical(this, other)) return true;

    return other.weight == weight && other.reps == reps;
  }

  @override
  int get hashCode => weight.hashCode ^ reps.hashCode;
}
