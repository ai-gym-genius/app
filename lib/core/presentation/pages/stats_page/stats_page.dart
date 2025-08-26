import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_genius/core/data/datasources/mock_data.dart';
import 'package:gym_genius/core/domain/entities/workout_entity.dart';
import 'package:gym_genius/core/domain/repositories/workout_repository.dart';
import 'package:gym_genius/core/presentation/pages/stats_page/stats_widgets.dart';
import 'package:gym_genius/di.dart';
import 'package:gym_genius/theme/context_getters.dart';
import 'package:gym_genius/theme/tokens/colors.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late Future<List<WorkoutEntity>> _workoutsF;

  @override
  void initState() {
    super.initState();
    _workoutsF = getIt<WorkoutRepository>().fetchWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: CupertinoNavigationBar.large(
        border: null,
        backgroundColor: colors.surface,
        largeTitle: Text(
          'Statistics',
          style: context.txt.headline.copyWith(color: colors.primary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CupertinoButton(
            //   padding: EdgeInsets.zero,
            //   onPressed: addMocks,
            //   child: const Icon(
            //     CupertinoIcons.add,
            //   ),
            // ),
            // CupertinoButton(
            //   padding: EdgeInsets.zero,
            //   onPressed: refresh,
            //   child: const Icon(CupertinoIcons.refresh),
            // ),
          ],
        ),
      ),
      body: FutureBuilder<List<WorkoutEntity>>(
        future: _workoutsF,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final workouts = snap.data!;

          // Normalize each startTime to a pure date
          final workoutDays = workouts
              .map((w) => DateTime(
                    w.startTime.year,
                    w.startTime.month,
                    w.startTime.day,
                  ))
              .toSet();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityGrid(workoutDays: workoutDays),
                const SizedBox(height: 52),
                _buildWorkoutDurationChart(workouts, colors),
              ],
            ),
          );
        },
      ),
    );
  }

  void addMocks() {
    setState(() {
      _workoutsF = Future.value(getMockWorkouts(100));
    });
  }

  void refresh() {
    setState(() {
      _workoutsF = getIt<WorkoutRepository>().fetchRemoteWorkouts();
    });
  }

  Widget _buildWorkoutDurationChart(
      List<WorkoutEntity> workouts, AppColors colors) {
    if (workouts.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No workout data available')),
      );
    }

    // Sort workouts by date
    final sortedWorkouts = List<WorkoutEntity>.from(workouts)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Create data points for the chart
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedWorkouts.length; i++) {
      final workout = sortedWorkouts[i];
      final durationMinutes = workout.duration.inMinutes.toDouble();
      spots.add(FlSpot(i.toDouble(), durationMinutes));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is your workout duration over time',
            style: context.txt.title,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 15,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colors.onSurface!.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: spots.length > 10
                          ? (spots.length / 5).floorToDouble()
                          : 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sortedWorkouts.length) {
                          final date = sortedWorkouts[index].startTime;
                          return SideTitleWidget(
                            meta: meta, // Add the meta parameter here
                            child: Text(
                              '${date.month}/${date.day}',
                              style: context.txt.labelSmall.copyWith(
                                color: context.colors.inactive,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 30,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          meta: meta, // Add the meta parameter here
                          child: Text(
                            '${value.toInt()}m',
                            style: context.txt.labelSmall.copyWith(
                              color: context.colors.inactive,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: colors.onSurface!.withOpacity(0.3)),
                ),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY:
                    spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withOpacity(0.8),
                        colors.primary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: colors.primary,
                          strokeWidth: 2,
                          strokeColor: colors.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colors.primary.withOpacity(0.1),
                          colors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
