/// Set for an exercise.
class ExerciseSetEntity {
  /// Creates an [ExerciseSetEntity] with the given [weight] and [reps].
  const ExerciseSetEntity({required this.weight, required this.reps});

  /// The weight in kgs used in this set.
  final num weight;

  /// The number of repetitions performed in this set.
  final int reps;
}
