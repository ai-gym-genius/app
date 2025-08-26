import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_genius/core/presentation/bloc/training_bloc.dart';
import 'package:gym_genius/core/presentation/bloc/training_event.dart';
import 'package:gym_genius/core/presentation/bloc/training_state.dart';
import 'package:gym_genius/core/presentation/pages/training_page/picking_exercise_page.dart';
import 'package:gym_genius/core/presentation/pages/training_page/widgets/popups.dart';
import 'package:gym_genius/core/presentation/pages/training_page/widgets/stopwatch_widget.dart';
import 'package:gym_genius/core/presentation/pages/training_page/widgets/widgets.dart'
    show ExpandableExerciseTile, StopwatchWidget;
import 'package:gym_genius/core/presentation/shared/warnings.dart';
import 'package:gym_genius/di.dart' show getIt;
import 'package:gym_genius/theme/context_getters.dart';

class TrainingProcessPage extends StatefulWidget {
  const TrainingProcessPage({super.key});

  @override
  State<TrainingProcessPage> createState() => _TrainingProcessPageState();
}

class _TrainingProcessPageState extends State<TrainingProcessPage> {
  late StopwatchController _timerCtrl;

  @override
  void initState() {
    super.initState();
    _timerCtrl = StopwatchController()..start();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightOfPinnedContainer = MediaQuery.of(context).size.height / 5;

    return BlocProvider(
      create: (context) => getIt<TrainingBloc>(),
      child: BlocListener<TrainingBloc, TrainingState>(
        listenWhen: (previous, current) =>
            previous.exercises != current.exercises ||
            previous.submitTrainingStatus != current.submitTrainingStatus,
        listener: (context, state) {
          switch (state.submitTrainingStatus) {
            case SubmitTrainingStatus.failureEmptySets:
              Warnings.showSubmitIncompleteWarning(context);
            case SubmitTrainingStatus.failureWritingDB:
              Warnings.showWritingFailureWarning(context);
            case SubmitTrainingStatus.success:
              Popups.showSubmittedTraining(
                  context,
                  context.read<TrainingBloc>(),
                  context.read<TrainingBloc>().state.workout!);
            default:
              break;
          }
        },
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            final bloc = context.read<TrainingBloc>();

            return Scaffold(
              body: Stack(
                children: [
                  _buildSlivers(
                    StopwatchWidget(controller: _timerCtrl),
                    bloc.state.exercises.isNotEmpty,
                    heightOfPinnedContainer,
                    bloc,
                  ),
                  _buildPinnedContainer(
                    heightOfPinnedContainer,
                    bloc,
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSlivers(
    Widget stopwatch,
    bool hasExercises,
    double height,
    TrainingBloc bloc,
  ) {
    return CustomScrollView(
      slivers: [
        _buildNavBar(stopwatch, hasExercises, bloc),
        _buildTilesGrid(bloc),
        SliverToBoxAdapter(
          child: SizedBox(
            height: height,
          ),
        )
      ],
    );
  }

  Widget _buildNavBar(Widget stopwatch, bool hasExercises, TrainingBloc bloc) {
    return CupertinoSliverNavigationBar(
      largeTitle: Text(
        hasExercises ? 'Your Exercises' : 'No exercises',
        style: context.txt.headline,
      ),
      border: null,
      backgroundColor: context.colors.surface,
      stretch: true,
      middle: stopwatch,
      trailing: BlocProvider.value(
        value: bloc,
        child: BlocBuilder<TrainingBloc, TrainingState>(
          builder: (context, state) {
            const submitWidth = 80.0; // ≈ width of the “Submit” button
            const submitHeight = 44.0; // default cupertino button height

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CupertinoButton(
                //   padding: EdgeInsets.zero,
                //   onPressed: () {},
                //   child: const Text('Random'),
                // ),
                // const SizedBox(width: 16),

                SizedBox(
                  width: submitWidth,
                  height: submitHeight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    child: CupertinoButton(
                      // “Submit”
                      key: const ValueKey(
                        'submitBtn',
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: hasExercises
                          ? () => bloc.add(SubmitTraining(_timerCtrl.elapsed))
                          : null,
                      child: Text(
                        'Submit',
                        style: context.txt.label.copyWith(
                          color: hasExercises
                              ? context.colors.primary
                              : context.colors.inactive,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTilesGrid(TrainingBloc bloc) {
    // Did not use List.builder so state is saved
    // after manipulation with order
    final List<Widget> tiles = bloc.state.exercises
        .map(
          (e) => ExpandableExerciseTile(
            key: ValueKey(e.exerciseInfo.id),
            exercise: e,
            onDeleteCallback: (ex) => bloc.add(
              RemoveExercise(ex.exerciseInfo.id),
            ),
          ),
        )
        .toList();

    return SliverList(
      delegate: SliverChildListDelegate(tiles),
    );
  }

  Widget _buildPinnedContainer(double height, TrainingBloc bloc) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            const Expanded(
              child: SizedBox.shrink(),
            ),
            Expanded(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.secondary.withAlpha(200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CupertinoButton(
                    onPressed: () {
                      showCupertinoModalPopup<dynamic>(
                        context: context,
                        builder: (context) => BlocProvider.value(
                          value: bloc,
                          child: const PickingExercisePage(
                              // addExerciseCallback: (info) => bloc.add(
                              //   AddExercise(info),
                              // ),
                              ),
                        ),
                      );
                    },
                    child: Icon(
                      CupertinoIcons.add_circled,
                      size: height / 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
