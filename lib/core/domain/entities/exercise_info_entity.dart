/// The primary muscle groups targeted by an exercise.
enum MuscleGroup {
  /// Bicep muscle.
  biceps,

  /// Triceps muscle.
  triceps,

  /// Back muscle.
  back,

  /// Chest muscle.
  chest,

  /// Legs muscle.
  legs,

  /// Shoulders muscle.
  shoulders,
}

/// Metadata describing an exercise.
class ExerciseInfoEntity {
  /// Creates an [ExerciseInfoEntity] with the given properties.
  const ExerciseInfoEntity({
    required this.id,
    required this.name,
    this.description,
    this.imagePath,
    this.url,
    this.muscleGroups,
  });

  /// The unique identifier for the exercise.
  final int id;

  /// The name of the exercise.
  final String name;

  /// The description of the exercise.
  final String? description;

  /// The path to an image representing the exercise.
  final String? imagePath;

  /// The URL with more information about the exercise.
  final String? url;

  /// The muscle groups targeted by the exercise.
  final List<MuscleGroup>? muscleGroups;
}
