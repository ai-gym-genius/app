import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:gym_genius/core/domain/entities/exercise_entity.dart';
import 'package:gym_genius/core/domain/entities/exercise_set_entity.dart';
import 'package:gym_genius/theme/context_getters.dart';

class ExpandableExerciseTile extends StatefulWidget {
  const ExpandableExerciseTile({
    required this.exercise,
    required this.onDeleteCallback,
    super.key,
  });
  final ExerciseEntity exercise;
  final void Function(ExerciseEntity) onDeleteCallback;

  @override
  State<ExpandableExerciseTile> createState() => _ExpandableExerciseTileState();
}

class _ExpandableExerciseTileState extends State<ExpandableExerciseTile> {
  final Duration _duration = Durations.short3;
  static const double _padding = 16.0 + 8;
  bool isExpanded = false;

  void addSetToExercise(ExerciseSetEntity exerciseSet) {
    setState(() {
      widget.exercise.sets.add(exerciseSet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _padding),
      child: Column(
        children: [
          _buildMainContent(),
          _buildExpandablePart(),
        ],
      ),
    );
  }

  /// Main content of tile, that is always visible
  /// TODO: make more adaptive
  Widget _buildMainContent() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        curve: Curves.easeIn,
        duration: _duration,
        height: 80,
        margin: isExpanded
            ? const EdgeInsets.only(top: 16, bottom: 8)
            : const EdgeInsets.symmetric(vertical: 16),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          child: Stack(
            children: [
              if (widget.exercise.exerciseInfo.imagePath != '')
                Image.asset(
                  widget.exercise.exerciseInfo.imagePath!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: context.colors.surfaceVariant,
                  child: Icon(
                    CupertinoIcons.photo,
                    size: 64,
                    color: context.colors.white.withValues(alpha: 0.54),
                  ),
                ),
              // Blur effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: context.colors.surfaceVariant.withAlpha(150),
                ),
              ),
              // Content
              _buildMainContentLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContentLayout() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text with Exercise name.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.exercise.exerciseInfo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.txt.title.copyWith(fontSize: 24),
                  ),
                  Text(
                    '${widget.exercise.sets.length} Set(s)',
                    style: context.txt.body,
                  ),
                ],
              ),
            ),
            // Row with small icons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => widget.onDeleteCallback(widget.exercise),
                  child: const Icon(CupertinoIcons.trash),
                ),
                // Animated chevron
                if (isExpanded)
                  const Icon(CupertinoIcons.chevron_down)
                else
                  const Icon(CupertinoIcons.chevron_forward),
              ],
            ),
          ],
        ),
      );

  /// Part which expands on tap
  Widget _buildExpandablePart() {
    return Column(
      children: [
        SetAdder(
          duration: _duration,
          isExpanded: isExpanded,
          setAdderCallback: addSetToExercise,
        ),
        _buildAmountText(),
        ...List.generate(
          widget.exercise.sets.length,
          (value) {
            final exerciseSet = widget.exercise.sets[value];
            return _buildExerciseSetCard(exerciseSet, value);
          },
        ),
        // This widget is just cooking.
        AnimatedContainer(
          duration: _duration,
          height: isExpanded ? 8 : 0,
        )
      ],
    );
  }

  /// Text showing if sets added in Expandable part
  Widget _buildAmountText() {
    return AnimatedContainer(
      duration: _duration,
      alignment: Alignment.bottomLeft,
      height: isExpanded ? 32 : 0,
      child: AnimatedCrossFade(
        duration: _duration,
        firstChild: const SizedBox.shrink(),
        secondChild: Padding(
          padding: const EdgeInsets.only(),
          child: Text(
            widget.exercise.sets.isEmpty
                ? 'No Sets Completed'
                : 'Sets Completed',
            style: context.txt.bodySmall.copyWith(
              color: context.colors.inactive,
            ),
          ),
        ),
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
    );
  }

  /// Small Orange Card that shows set information
  Widget _buildExerciseSetCard(ExerciseSetEntity exerciseSet, int index) {
    return AnimatedContainer(
      curve: Curves.decelerate,
      margin: isExpanded
          ? const EdgeInsets.symmetric(vertical: 8)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      duration: _duration,
      height: isExpanded ? 40 : 0,
      child: AnimatedCrossFade(
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: _duration,
        firstChild: const SizedBox.shrink(),
        secondChild: Center(
          child: DefaultTextStyle(
            style: context.txt.bodySmall.copyWith(color: context.colors.white),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Set ${index + 1}'),
                      Text('${exerciseSet.reps} time(s)'),
                      Text(
                        '${exerciseSet.weight} kg(s)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      widget.exercise.sets.removeAt(index);
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.delete,
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

/// Two Fields + Button that adds set
class SetAdder extends StatefulWidget {
  /// Builds expandable animated container where sets can be added via
  /// [setAdderCallback].
  const SetAdder({
    required Duration duration,
    required this.isExpanded,
    required this.setAdderCallback,
    super.key,
  }) : _duration = duration;

  final Duration _duration;

  /// Whether container is expanded or not.
  ///
  /// Controlled via outer layer, so have to pass.
  final bool isExpanded;

  /// Callback when sets are added.
  ///
  /// Used in outer-layer for adding sets.
  final void Function(ExerciseSetEntity) setAdderCallback;

  @override
  State<SetAdder> createState() => _SetAdderState();
}

class _SetAdderState extends State<SetAdder> {
  late TextEditingController repsController;
  late TextEditingController weightController;

  bool repsControllerHasError = false;
  bool weightControllerHasError = false;

  @override
  void initState() {
    super.initState();
    repsController = TextEditingController();
    weightController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget._duration,
      height: widget.isExpanded ? 40 : 0,
      child: widget.isExpanded
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          onChanged: (value) {
                            setState(() {
                              repsControllerHasError = false;
                            });
                          },
                          decoration: getTextFieldDecoration(
                            hasError: repsControllerHasError,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                          ],
                          controller: repsController,
                          keyboardType: TextInputType.number,
                          placeholder: 'Reps',
                          placeholderStyle: context.txt.body.copyWith(
                            color: context.colors.inactive,
                          ),
                          style: context.txt.body.copyWith(
                            color: context.colors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CupertinoTextField(
                          onChanged: (value) {
                            setState(() {
                              weightControllerHasError = false;
                            });
                          },
                          decoration: getTextFieldDecoration(
                            hasError: weightControllerHasError,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                          ],
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          placeholder: 'Weight (kg)',
                          placeholderStyle: context.txt.body.copyWith(
                            color: context.colors.inactive,
                          ),
                          style: context.txt.body.copyWith(
                            color: context.colors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(7),
                    borderRadius: BorderRadius.circular(7),
                    color: context.colors.primary,
                    onPressed: () {
                      var isValid = true;

                      final repsString = repsController.text;
                      final weightString = weightController.text;

                      if (repsString.isEmpty) {
                        repsControllerHasError = true;
                        isValid = false;
                      }
                      if (weightString.isEmpty) {
                        weightControllerHasError = true;
                        isValid = false;
                      }
                      if (!isValid) {
                        setState(() {});
                      } else {
                        final reps = int.parse(repsController.text);
                        final weight = int.parse(weightController.text);
                        final exerciseSet = ExerciseSetEntity(
                          weight: weight,
                          reps: reps,
                        );
                        widget.setAdderCallback(exerciseSet);
                      }
                    },
                    minimumSize: const Size(0, 0),
                    child: Text(
                      'Add Set',
                      style: context.txt.body.copyWith(
                        color: context.colors.surfaceVariant,
                      ),
                    ),
                  ),
                )
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  /// Get decoration for CupertinoStyled TextField
  BoxDecoration getTextFieldDecoration({required bool hasError}) {
    return BoxDecoration(
      color: context.colors.surface,
      border: Border.all(
        color: hasError
            ? context.colors.danger
            : context.colors.onSurface.withOpacity(0.2),
        width: 0,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(5)),
    );
  }
}
