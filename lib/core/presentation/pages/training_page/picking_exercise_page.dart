import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_genius/core/data/datasources/local/services/exercise_loader.dart';
import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';
import 'package:gym_genius/core/presentation/bloc/training_bloc.dart';
import 'package:gym_genius/core/presentation/bloc/training_event.dart';
import 'package:gym_genius/core/presentation/bloc/training_state.dart';
import 'package:gym_genius/core/presentation/shared/custom_context_menu.dart';
import 'package:gym_genius/core/presentation/shared/warnings.dart';
import 'package:gym_genius/di.dart';
import 'package:gym_genius/theme/context_getters.dart';

/// Allows user to pick an exercise.
class PickingExercisePage extends StatefulWidget {
  /// no-doc.
  const PickingExercisePage({super.key});

  @override
  State<PickingExercisePage> createState() => _PickingExercisePageState();
}

class _PickingExercisePageState extends State<PickingExercisePage> {
  List<ExerciseInfoEntity> _allExercises = [];
  List<ExerciseInfoEntity> _visibleExercises = [];

  String _query = '';
  Timer? _debounce;

  late TextEditingController _searchController;
  late Future<List<ExerciseInfoEntity>> _fetchExercisesFuture;

  void _onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), _applyFilter);
  }

  void _applyFilter() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _visibleExercises = List.of(_allExercises));
      return;
    }

    final filtered = _allExercises.where((e) {
      final name = e.name.toLowerCase();
      // final desc = (e.description ?? '').toLowerCase();
      final mgs = e.muscleGroups ?? [];

      final containMg = mgs.any((mg) => mg.name.toLowerCase().contains(q));
      return name.contains(q) || containMg;
    }).toList();

    setState(() => _visibleExercises = filtered);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchExercisesFuture = getIt<JsonExerciseInfosLoader>().loadPureEx();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightOfWidget = MediaQuery.of(context).size.height - 150;

    return BlocListener<TrainingBloc, TrainingState>(
      listener: (context, state) {
        switch (state.addExerciseStatus) {
          case AddExerciseStatus.duplicate:
            Warnings.showAlreadyHasExerciseWarning(context);
          case AddExerciseStatus.success:
            Navigator.pop(context);
          case AddExerciseStatus.initial:
            break;
        }
      },
      child: SafeArea(
        bottom: false,
        child: CupertinoPopupSurface(
          child: Material(
            child: CupertinoPageScaffold(
              child: SizedBox(
                height: heightOfWidget,
                child: CustomScrollView(
                  slivers: [
                    _buildNavBar(),
                    _buildSearchingSegment(),
                    _buildGrid(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return CupertinoSliverNavigationBar(
      border: null,
      backgroundColor: context.colors.surface,
      automaticBackgroundVisibility: false,
      largeTitle: Text(
        'Pick an Exercise',
        style: context.txt.headline,
      ),
      // This way animation works fine.
      middle: Text(
        'Pick an Exercise',
        style: context.txt.title,
      ),
      alwaysShowMiddle: false,
    );
  }

  Widget _buildSearchingSegment() {
    return PinnedHeaderSliver(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: context.colors.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 9,
                      child: SizedBox(
                        child: CupertinoSearchTextField(
                          controller: _searchController,
                          onChanged: _onQueryChanged,
                          placeholder: 'Search Exercises...',
                          placeholderStyle: context.txt.body.copyWith(
                            color: context.colors.secondaryLabel,
                          ),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // showCupertinoModalPopup<dynamic>(
                        //   context: context,
                        //   builder: (context) {
                        //     return _buildFilteringSegment();
                        //   },
                        // );
                      },
                      child: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          _buildBorder(),
        ],
      ),
    );
  }

  Widget _buildBorder() => Container(
        height: 1,
        width: double.infinity,
        color: const CupertinoDynamicColor.withBrightness(
          color: Color(0x33000000),
          darkColor: Color(0x33FFFFFF),
        ),
      );

  // TODO: undoc when filtering added.
  // Widget _buildFilteringSegment() {
  //   return Material(
  //     type: MaterialType.transparency,
  //     child: Center(
  //       child: Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12),
  //           color: Colors.transparent.withAlpha(100),
  //         ),
  //         height: 200,
  //         width: 300,
  //         child: DefaultTextStyle(
  //           style: context.txt.body.copyWith(color: Colors.white),
  //           child: const Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: Text('Pick Filtering Options'),
  //               ),
  //               Expanded(
  //                 child: Placeholder(
  //                   child: Text('COMING SOON'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildGrid() {
    final bottomPadding = MediaQuery.of(context).size.width / 4;

    return FutureBuilder(
      future: _fetchExercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return SliverToBoxAdapter(
              child: Center(
                child: SizedBox(
                  height: 500,
                  child: Text('Error: ${snapshot.error}'),
                ),
              ),
            );
          }

          // First launch.
          if (_allExercises.isEmpty) {
            _allExercises = snapshot.data!;
            _visibleExercises = List.of(_allExercises);
          }

          return SliverPadding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: bottomPadding,
            ),
            sliver: SliverGrid.builder(
              itemCount: _visibleExercises.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, val) {
                final exerciseInfo = _visibleExercises[val];
                return _buildExerciseContainer(exerciseInfo);
              },
            ),
          );
        } else {
          return const SliverFillRemaining(
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }

  Widget _buildExerciseContainer(
    ExerciseInfoEntity exerciseInfo,
  ) {
    final bloc = context.read<TrainingBloc>();

    return CustomContextMenu(
      actions: [
        CupertinoContextMenuAction(
          isDefaultAction: true,
          child: Text(
            '${exerciseInfo.name}. ${exerciseInfo.description}',
            style: context.txt.title,
          ),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context); // Close the context menu.
            // Also it should locally add ex to favorite.
          },
          trailingIcon: CupertinoIcons.heart,
          child: Text('Favorite', style: context.txt.body),
        ),
      ],
      // TODO: Fix taps on focused.
      child: GestureDetector(
        onTap: () => bloc.add(AddExercise(exerciseInfo)),

        // Image with exercise name.
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(
                color: CupertinoColors.tertiarySystemFill,
              ),
              if (exerciseInfo.imagePath != null &&
                  exerciseInfo.imagePath!.isNotEmpty)
                Image.asset(
                  fit: BoxFit.cover,
                  exerciseInfo.imagePath!,
                  frameBuilder: (
                    BuildContext context,
                    Widget child,
                    int? frame,
                    bool wasLoaded,
                  ) {
                    if (wasLoaded) {
                      return child;
                    }
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(4),
                          ),
                          color: context.colors.secondary.withAlpha(230),
                        ),
                        child: Text(
                          style: context.txt.bodySmall.copyWith(
                            decoration: TextDecoration.none,
                          ),
                          exerciseInfo.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
