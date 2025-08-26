import 'dart:convert';
import 'dart:math';
import 'package:equatable/equatable.dart';

import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';

/// Converter.
extension MuscleGroupExtension on MuscleGroup {
  /// Static method to convert string to enum.
  static MuscleGroup fromMap(String value) {
    return MuscleGroup.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw Exception('Unknown muscle group: $value'),
    );
  }

  /// Returns random muscleGroup.
  static MuscleGroup random() {
    return MuscleGroup.values[Random().nextInt(MuscleGroup.values.length)];
  }
}

/// DTO for [ExerciseInfoEntity].
class ExerciseInfoDTO extends Equatable {
  /// no-doc.
  const ExerciseInfoDTO({
    required this.id,
    required this.name,
    this.description,
    this.imagePath,
    this.url,
    this.muscleGroups,
  });

  /// no-doc.
  factory ExerciseInfoDTO.fromEntity(ExerciseInfoEntity entity) {
    return ExerciseInfoDTO(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imagePath: entity.imagePath,
      url: entity.url,
      muscleGroups: entity.muscleGroups?.map((mg) => mg.name).toList(),
    );
  }

  /// no-doc.
  factory ExerciseInfoDTO.fromSQLMap(Map<String, dynamic> map) {
    return ExerciseInfoDTO(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      muscleGroups: (map['muscle_groups'] as List<dynamic>?)
          ?.map((mg) => mg as String)
          .toList(),
    );
  }

  /// no-doc.
  factory ExerciseInfoDTO.fromJson(String source) =>
      ExerciseInfoDTO.fromSQLMap(json.decode(source) as Map<String, dynamic>);

  /// no-doc.
  factory ExerciseInfoDTO.fromJsonMap(Map<String, dynamic> map) {
    return ExerciseInfoDTO(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imagePath: map['imagePath'] as String,
      muscleGroups: (map['muscleGroups'] as List<dynamic>?)
          ?.map((mg) => mg as String)
          .toList(),
    );
  }

  /// ID of exInfo.
  final int id;

  /// Name of exInfo.
  /// 
  /// Example: bench_press.
  final String name;

  /// Description of exInfo.
  final String? description;

  /// ImagePath of exInfo.
  final String? imagePath;

  /// Url of exInfo.
  /// 
  /// Not used at the moment, there might be video or something.
  final String? url;

  /// MuscleGroups that affected.
  final List<String>? muscleGroups;

  /// no-doc.
  ExerciseInfoDTO copyWith({
    int? id,
    String? name,
    String? description,
    String? imagePath,
    List<String>? muscleGroups,
  }) {
    return ExerciseInfoDTO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      muscleGroups: muscleGroups ?? this.muscleGroups,
    );
  }

  /// Converts to entity.
  ExerciseInfoEntity toEntity() {
    return ExerciseInfoEntity(
      id: id,
      name: name,
      description: description,
      imagePath: imagePath,
      url: url,
      muscleGroups: muscleGroups?.map(MuscleGroupExtension.fromMap).toList(),
    );
  }

  @override
  String toString() {
    return 'ExerciseInfoDto(id: $id, name: $name, description: $description, imagePath: $imagePath, muscleGroups: $muscleGroups)';
  }

  /// Converts to SnakeMap.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'muscle_groups': muscleGroups,
    };
  }

  /// Converts to CamelMap.
  Map<String, dynamic> toCamelMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'imagePath': imagePath,
      'muscleGroups': muscleGroups,
    };
  }

  /// Converts to json.
  String toJson() => json.encode(toMap());

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imagePath,
        url,
        muscleGroups,
      ];
}
