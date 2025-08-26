import 'package:flutter/cupertino.dart';
import 'package:gym_genius/core/presentation/pages/auth_page/auth_page.dart';

import 'package:gym_genius/core/presentation/pages/stats_page/stats_page.dart';
import 'package:gym_genius/core/presentation/pages/training_page/start_workout_page.dart';
import 'package:gym_genius/core/presentation/pages/training_page/training_process_page.dart';
import 'package:gym_genius/theme/context_getters.dart';

final Map<String, Widget Function(dynamic context)> routes = {
  '/': (context) => const TabBarPage(),
  '/training_process': (context) => const TrainingProcessPage(),
  '/auth': (context) => const AuthPage(),
};

class TabBarPage extends StatelessWidget {
  const TabBarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        textTheme: CupertinoTextThemeData(
          tabLabelTextStyle: context.txt.labelSmall
        )
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: context.colors.surfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.flame),
              label: 'Train',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar),
              label: 'Stats',
            ),
          ],
        ),
        tabBuilder: (ctx, i) {
          switch (i) {
            case 0:
              return const StartWorkoutPage();
            case 1:
              return const StatsPage();
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}
