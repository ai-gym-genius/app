import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';
import 'package:gym_genius/core/presentation/bloc/training_bloc.dart';
import 'package:gym_genius/core/presentation/bloc/training_event.dart';
import 'package:gym_genius/core/presentation/bloc/training_state.dart';
import 'package:gym_genius/core/presentation/shared/warnings.dart';
import 'package:gym_genius/theme/context_getters.dart';

class Popups {
  static void showSubmittedTraining(
    BuildContext context,
    TrainingBloc bloc,
    WorkoutEntity workout,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _TrainingSummaryCard(
        bloc: bloc,
        workout: workout,
      ),
    );
  }

  static void showAIReview(BuildContext context, String reviewText) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _AIReviewSheet(text: reviewText),
    );
  }
}

class _TrainingSummaryCard extends StatelessWidget {
  const _TrainingSummaryCard({
    required this.bloc,
    required this.workout,
  });
  final TrainingBloc bloc;
  final WorkoutEntity workout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<TrainingBloc, TrainingState>(
        listenWhen: (previous, current) =>
            previous.getAIReviewStatus != current.getAIReviewStatus,
        listener: (context, state) {
          if (state.getAIReviewStatus == GetAIReviewStatus.failure) {
            Warnings.showAIReviewWarning(context);
          } else if (state.getAIReviewStatus == GetAIReviewStatus.success) {
            Popups.showAIReview(
                context, context.read<TrainingBloc>().state.review!);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
            child: Material(
              borderRadius: BorderRadius.circular(16),
              color: colors.surface,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── header ───────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Workout complete',
                          style: context.txt.headline,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // Readable.
                          // ignore: lines_longer_than_80_chars
                          '${workout.duration.inMinutes} min  •  ${workout.exercises.length} exercises',
                          style: context.txt.body,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // ── list of exercises ────────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemCount: workout.exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (_, i) {
                        final ex = workout.exercises[i];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Exercise title ────────────────────────────────
                            Text(
                              ex.exerciseInfo.name,
                              style: context.txt.title.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // ── One row per set ───────────────────────────────
                            ...ex.sets.map((s) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      'Set ${ex.sets.indexOf(s) + 1}:',
                                      style: context.txt.body.copyWith(
                                        color: colors.onSurface.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${s.reps} reps',
                                      style: context.txt.body,
                                    ),
                                    ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '${s.weight} kg',
                                        style: context.txt.body,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                  // ── actions ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.filled(
                            onPressed: () {
                              // Also should dispose Bloc
                              Navigator.popUntil(
                                context,
                                ModalRoute.withName('/'),
                              );
                            },
                            child: Text(
                              'Leave',
                              style: context.txt.label.copyWith(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoButton(
                            onPressed: state.getAIReviewStatus ==
                                    GetAIReviewStatus.loading
                                ? null
                                : () {
                                    context
                                        .read<TrainingBloc>()
                                        .add(GetAIReview(workout));
                                  },
                            padding: EdgeInsets.zero,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: AnimatedSwitcher(
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    child: state.getAIReviewStatus ==
                                            GetAIReviewStatus.loading
                                        ? const CircularProgressIndicator
                                            .adaptive(
                                            strokeWidth: 2,
                                            key: ValueKey('spinner'),
                                          )
                                        : Image.asset(
                                            'assets/apple_ai.png',
                                            key: const ValueKey('icon'),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // ─── Label ───
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    style: context.txt.label.copyWith(
                                      color: context.colors.primary,
                                    ),
                                    state.getAIReviewStatus ==
                                            GetAIReviewStatus.loading
                                        ? 'Getting…'
                                        : 'Get Feedback',
                                    key: ValueKey(state.getAIReviewStatus),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AIReviewSheet extends StatelessWidget {
  const _AIReviewSheet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  text,
                  style: context.txt.body.copyWith(
                    color: colors.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    child: Text(
                      'Leave',
                      style: context.txt.label.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.popUntil(context, ModalRoute.withName('/')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
