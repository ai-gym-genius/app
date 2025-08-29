import 'dart:convert';
import 'dart:math';

import 'package:gym_genius/core/data/models/exercise_info_dto.dart';
import 'package:gym_genius/core/data/models/exercise_set_dto.dart';
import 'package:gym_genius/core/domain/entities/exercise_entity.dart';

/// DTO for exercises.
class ExerciseDTO {
  /// no-doc.
  ExerciseDTO({
    required this.exerciseInfo,
    this.sets = const [],
  });

  /// Generates random exercise.
  factory ExerciseDTO.fake() {
    final rand = Random();

    return ExerciseDTO(
      exerciseInfo: ExerciseInfoDTO(
        id: rand.nextInt(28) + 1,
        name: 'Random exercise',
      ),
      sets: List.generate(
        rand.nextInt(5) + 1,
        (id) => ExerciseSetDTO(
          weight: rand.nextInt(100) + 1,
          reps: rand.nextInt(20) + 1,
        ),
      ),
    );
  }

  /// no-doc.
  factory ExerciseDTO.fromEntity(ExerciseEntity entity) {
    return ExerciseDTO(
      exerciseInfo: ExerciseInfoDTO.fromEntity(entity.exerciseInfo),
      sets: entity.sets.map(ExerciseSetDTO.fromEntity).toList(),
    );
  }

  /// no-doc.
  factory ExerciseDTO.fromMap(Map<String, dynamic> map) {
    return ExerciseDTO(
      exerciseInfo: ExerciseInfoDTO.fromSQLMap(
        map['exercise_info'] as Map<String, dynamic>,
      ),
      sets: (map['sets'] as List)
          .map((x) => ExerciseSetDTO.fromMap(x as Map<String, dynamic>))
          .toList(),
    );
  }

  /// no-doc.
  factory ExerciseDTO.fromJson(String source) =>
      ExerciseDTO.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Information about exercise.
  final ExerciseInfoDTO exerciseInfo;

  /// Modifiable sets.
  List<ExerciseSetDTO> sets;

  /// no-doc.
  ExerciseDTO copyWith({
    ExerciseInfoDTO? exerciseInfo,
    List<ExerciseSetDTO>? sets,
  }) {
    return ExerciseDTO(
      exerciseInfo: exerciseInfo ?? this.exerciseInfo,
      sets: sets ?? this.sets,
    );
  }

  /// no-doc.
  ExerciseEntity toEntity() {
    return ExerciseEntity(
      exerciseInfo: exerciseInfo.toEntity(),
      sets: sets.map((obj) => obj.toEntity()).toList(),
    );
  }

  /// Maps to SnakeCase.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exercise_info': exerciseInfo.toMap().toString(),
      'sets': sets.map((x) => x.toMap()).toList(),
    };
  }

  /// Maps to backend SnakeCase version.
  Map<String, dynamic> toAnotherFuckingShit() {
    return <String, dynamic>{
      'exercise_id': exerciseInfo.id,
      'reps'
          'sets': sets.map((x) => x.toMap()).toList(),
    };
  }

  /// Backend needs this representation.
  List<Map<String, num>> toShitList() {
    final list = <Map<String, num>>[];

    for (final set in sets) {
      list.add({
        'exercise_id': exerciseInfo.id,
        'reps': set.reps,
        'weight': set.weight,
      });
    }

    return list;
  }

  /// Maps to DB version.
  Map<String, dynamic> toFuckingShit() {
    return <String, dynamic>{
      'exerciseInfo': exerciseInfo.description,
      'sets': sets.map((x) => x.toMap()).toList(),
      'muscleGroup': exerciseInfo.muscleGroups!.first,
      'name': exerciseInfo.name,
    };
  }

  /// Maps to json.
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Exercise(exerciseInfo: $exerciseInfo, sets: $sets)';
}
